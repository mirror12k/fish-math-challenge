#!/usr/bin/env perl
package PythonMathValidator;
use strict;
use warnings;

use feature 'say';





##############################
##### variables and settings
##############################



our $tokens = [
	'string' => qr/"(?:[^"\\]|\\["\\\/bfnrt])*"|'(?:[^'\\]|\\['\\\/bfnrt])*'/s,
	'symbol' => qr/!=|==|<=|>=|(?:\*\*|\/\/)=|\*\*|\/\/|[+\-*\/%\^\|\&]=|[+\-*\/%\^\|\&<>,:\(\)\[\]\{\}=!\.]/,
	'identifier' => qr/[a-zA-Z_][a-zA-Z0-9_]*+/,
	'number' => qr/-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][\+\-]?[0-9]+)?/,
	'whitespace' => qr/\s++/s,
	'comment' => qr/#[^\n]*(?=\n|\Z)/s,
];

our $ignored_tokens = [
	'whitespace',
	'comment',
];

our $contexts = {
	root => 'context_root',
	python_statement_block => 'context_python_statement_block',
	python_statement => 'context_python_statement',
	python_variable_list => 'context_python_variable_list',
	python_expression_list => 'context_python_expression_list',
	python_expression => 'context_python_expression',
	python_extended_expression => 'context_python_extended_expression',
	python_value_literal => 'context_python_value_literal',
	python_list_constructor => 'context_python_list_constructor',
	python_object_constructor => 'context_python_object_constructor',
};



##############################
##### api
##############################



sub new {
	my ($class, %opts) = @_;
	my $self = bless {}, $class;

	$self->{filepath} = Sugar::IO::File->new($opts{filepath}) if defined $opts{filepath};
	$self->{text} = $opts{text} if defined $opts{text};

	$self->{token_regexes} = $tokens // die "token_regexes argument required for Sugar::Lang::Tokenizer";
	$self->{ignored_tokens} = $ignored_tokens;

	$self->compile_tokenizer_regex;

	return $self
}

sub parse {
	my ($self) = @_;
	return $self->parse_from_context("context_root");
}

sub parse_from_context {
	my ($self, $context) = @_;
	$self->parse_tokens;

	$self->{syntax_tree} = $self->$context($self->{syntax_tree});
	$self->confess_at_current_offset("more tokens after parsing complete") if $self->{tokens_index} < @{$self->{tokens}};

	return $self->{syntax_tree};
}

sub compile_tokenizer_regex {
	my ($self) = @_;
	use re 'eval';
	my $token_pieces = join '|',
			map "($self->{token_regexes}[$_*2+1])(?{'$self->{token_regexes}[$_*2]'})",
				0 .. $#{$self->{token_regexes}} / 2;
	$self->{tokenizer_regex} = qr/$token_pieces/s;

# 	# optimized selector for token names, because %+ is slow
# 	my @index_names = map $self->{token_regexes}[$_*2], 0 .. $#{$self->{token_regexes}} / 2;
# 	my @index_variables = map "\$$_", 1 .. @index_names;
# 	my $index_selectors = join "\n\tels",
# 			map "if (defined $index_variables[$_]) { return '$index_names[$_]', $index_variables[$_]; }",
# 			0 .. $#index_names;

# 	$self->{token_selector_callback} = eval "
# sub {
# 	$index_selectors
# }
# ";
}

sub parse_tokens {
	my ($self) = @_;

	my $text;
	$text = $self->{filepath}->read if defined $self->{filepath};
	$text = $self->{text} unless defined $text;

	die "no text or filepath specified before parsing" unless defined $text;

	return $self->parse_tokens_in_text($text)
}


sub parse_tokens_in_text {
	my ($self, $text) = @_;
	$self->{text} = $text;
	
	my @tokens;

	my $line_number = 1;
	my $offset = 0;

	# study $text;
	while ($text =~ /\G$self->{tokenizer_regex}/gc) {
		# despite the absurdity of this solution, this is still faster than loading %+
		# my ($token_type, $token_text) = each %+;
		# my ($token_type, $token_text) = $self->{token_selector_callback}->();
		my ($token_type, $token_text) = ($^R, $^N);

		push @tokens, [ $token_type => $token_text, $line_number, $offset ];
		$offset = pos $text;
		# amazingly, this is faster than a regex or an index count
		# must be because perl optimizes out the string modification, and just performs a count
		$line_number += $token_text =~ y/\n//;
	}

	die "parsing error on line $line_number:\nHERE ---->" . substr ($text, pos $text // 0, 200) . "\n\n\n"
			if not defined pos $text or pos $text != length $text;

	if (defined $self->{ignored_tokens}) {
		foreach my $ignored_token (@{$self->{ignored_tokens}}) {
			@tokens = grep $_->[0] ne $ignored_token, @tokens;
		}
	}

	# @tokens = $self->filter_tokens(@tokens);

	$self->{tokens} = \@tokens;
	$self->{tokens_index} = 0;
	$self->{save_tokens_index} = 0;

	return $self->{tokens}
}

sub confess_at_current_offset {
	my ($self, $msg) = @_;

	my $position;
	my $next_token = '';
	if ($self->{tokens_index} < @{$self->{tokens}}) {
		$position = 'line ' . $self->{tokens}[$self->{tokens_index}][2];
		my ($type, $val) = @{$self->{tokens}[$self->{tokens_index}]};
		$next_token = " (next token is $type => <$val>)";
	} else {
		$position = 'end of file';
	}

	# say $self->dump_at_current_offset;

	die "error on $position: $msg$next_token";
}
sub confess_at_offset {
	my ($self, $msg, $offset) = @_;

	my $position;
	my $next_token = '';
	if ($offset < @{$self->{tokens}}) {
		$position = 'line ' . $self->{tokens}[$offset][2];
		my ($type, $val) = ($self->{tokens}[$offset][0], $self->{tokens}[$offset][1]);
		$next_token = " (next token is $type => <$val>)";
	} else {
		$position = 'end of file';
	}

	# say $self->dump_at_current_offset;

	die "error on $position: $msg$next_token";
}



##############################
##### sugar contexts functions
##############################

sub context_root {
	my ($self) = @_;
	my $context_value = {};
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected !python_statement_block', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (($tokens[0] = $self->context_python_statement_block([])) and (($context_value = $tokens[0]) or do { 1 })));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_statement_block {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected ( ( /elif|else/ ),  or /.*/ ), !python_statement', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; while (((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] =~ /\A(elif|else)\Z/));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and (return $context_value)) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] =~ /\A(.*)\Z/));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and (($tokens[1] = $self->context_python_statement) and do { push @$context_value, $tokens[1]; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }));
	return $context_value;
}
sub context_python_statement {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected \'if\', !python_expression, \':\', !python_statement_block, , \'elif\', !python_expression, \':\', , [ \'else\', \':\',  ] or \'def\', identifier token, \'(\', !python_variable_list, \')\', \':\', !python_statement_block, ,  or \'while\', !python_expression, \':\', !python_statement_block,  or \'for\', identifier token, \'in\', !python_expression, \':\', !python_statement_block, ,  or identifier token, \'=\', !python_expression_list,  or \'import\', \'math\' or \'import\',  or !python_expression,  or ', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'if' and ($tokens[1] = $self->context_python_expression) and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and ((($tokens[3] = $self->context_python_statement_block([])) and do { $context_value->{block} = $tokens[3]; 1 }) and $context_value->{type} = 'if_statement') and (1 and do { $context_value->{expression} = $tokens[1]; 1 }) and (do { my $save_tokens_index = $self->{tokens_index}; while (((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[5] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'elif' and ($tokens[6] = $self->context_python_expression) and ($tokens[7] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and (1 and do { push @{$context_value->{branch}}, { type => 'elif_statement', line_number => $tokens[0][2], expression => $tokens[6], block => $self->context_python_statement_block([]), }; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }) and (do { my $save_tokens_index = $self->{tokens_index}; if (((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[6] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'else' and ($tokens[7] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and (1 and do { push @{$context_value->{branch}}, { type => 'else_statement', line_number => $tokens[0][2], block => $self->context_python_statement_block([]), }; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; })) 
				or ((($self->{tokens_index} = $save_tokens_index) + 5 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'def' and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '(' and ($tokens[3] = $self->context_python_variable_list([])) and ($tokens[4] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ')' and ($tokens[5] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and ((($tokens[6] = $self->context_python_statement_block([])) and do { $context_value->{block} = $tokens[6]; 1 }) and $context_value->{type} = 'function_definition_statement') and (1 and do { $context_value->{identifier} = $tokens[1][1]; 1 }) and (1 and do { $context_value->{arguments} = $tokens[3]; 1 })) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'while' and ($tokens[1] = $self->context_python_expression) and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and ((($tokens[3] = $self->context_python_statement_block([])) and do { $context_value->{block} = $tokens[3]; 1 }) and $context_value->{type} = 'whilee_statement') and (1 and do { $context_value->{expression} = $tokens[1]; 1 })) 
				or ((($self->{tokens_index} = $save_tokens_index) + 4 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'for' and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'in' and ($tokens[3] = $self->context_python_expression) and ($tokens[4] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and ((($tokens[5] = $self->context_python_statement_block([])) and do { $context_value->{block} = $tokens[5]; 1 }) and $context_value->{type} = 'for_statement') and (1 and do { $context_value->{identifier} = $tokens[1][1]; 1 }) and (1 and do { $context_value->{expression} = $tokens[3]; 1 })) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '=' and ((($tokens[2] = $self->context_python_expression_list) and do { $context_value->{expression_list} = $tokens[2]; 1 }) and $context_value->{type} = 'assignment_statement') and (1 and do { $context_value->{identifier} = $tokens[0][1]; 1 })) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'import' and ((($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'math' and do { $context_value->{identifier} = $tokens[1][1]; 1 }) and $context_value->{type} = 'import_statement')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'import' and $self->confess_at_current_offset('only "math" is allowed to be imported in EMC')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and ($tokens[0] = $self->context_python_expression) and ((1 and do { $context_value->{expression} = $tokens[0]; 1 }) and $context_value->{type} = 'expression_statement')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and $self->confess_at_current_offset('expected python statement'));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_variable_list {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected ( \')\' ),  or identifier token, \',\', identifier token', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ')'));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and (return $context_value)) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and (($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and do { push @$context_value, $tokens[0][1]; 1 }) and (do { my $save_tokens_index = $self->{tokens_index}; while (((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ',' and (($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and do { push @$context_value, $tokens[2][1]; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_expression_list {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected ( \')\' ),  or !python_expression, \',\', !python_expression', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ')'));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and (return $context_value)) 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (($tokens[0] = $self->context_python_expression) and do { push @$context_value, $tokens[0]; 1 }) and (do { my $save_tokens_index = $self->{tokens_index}; while (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ',' and (($tokens[2] = $self->context_python_expression) and do { push @$context_value, $tokens[2]; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_expression {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected !python_extended_expression', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (($tokens[0] = $self->context_python_extended_expression($self->context_python_value_literal)) and (($context_value = $tokens[0]) or do { 1 })));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_extended_expression {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected /!=|==|<=|>=|(?:\\*\\*|\\/\\/)=|\\*\\*|\\/\\/|[+\\-*\\/%\\^\\|\\&]=|[+\\-*\\/%\\^\\|\\&<>]|or|and/, !python_value_literal,  or \'.\', ( /__\\S+__/ ),  or \'.\', identifier token,  or \'[\', !python_expression, [ \':\', !python_expression, [ \':\', !python_expression ] ], \']\',  or \'(\', !python_expression_list, \')\',  or ', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] =~ /\A(!=|==|<=|>=|(?:\*\*|\/\/)=|\*\*|\/\/|[+\-*\/%\^\|\&]=|[+\-*\/%\^\|\&<>]|or|and)\Z/ and ($tokens[1] = $self->context_python_value_literal) and (1 and (($context_value = $self->context_python_extended_expression({ type => 'binary_expression', line_number => $tokens[0][2], operator => $tokens[0][1], left_expression => $context_value, right_expression => $tokens[1], })) or do { 1 }))) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '.' and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] =~ /\A(__\S+__)\Z/));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and $self->confess_at_current_offset('stop that! magic accessors are forbidden in EMC')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '.' and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and (1 and (($context_value = $self->context_python_extended_expression({ type => 'access_expression', line_number => $tokens[0][2], expression => $context_value, identifier => $tokens[1][1], })) or do { 1 }))) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '[' and ($tokens[1] = $self->context_python_expression([])) and (do { my $save_tokens_index = $self->{tokens_index}; if (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and (($tokens[3] = $self->context_python_expression) and do { $context_value->{end_expression} = $tokens[3]; 1 }) and (do { my $save_tokens_index = $self->{tokens_index}; if (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[4] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and (($tokens[5] = $self->context_python_expression) and do { $context_value->{step_expression} = $tokens[5]; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }) and ($tokens[3] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ']' and (1 and (($context_value = $self->context_python_extended_expression({ type => 'array_access_expression', line_number => $tokens[0][2], expression => $context_value, access_expression => $tokens[1], })) or do { 1 }))) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '(' and ($tokens[1] = $self->context_python_expression_list([])) and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ')' and (1 and (($context_value = $self->context_python_extended_expression({ type => 'function_call_expression', line_number => $tokens[0][2], expression => $context_value, expression_list => $tokens[1], })) or do { 1 }))) 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (return $context_value));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_value_literal {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected ( string token ),  or ( \'chr\' ),  or ( \'str\' ),  or number token or /True|False/ or \'None\' or identifier token or \'[\', \']\',  or \'[\', !python_list_constructor, \']\' or \'{\', \'}\',  or \'{\', !python_object_constructor, \'}\' or \'(\', !python_expression, \')\' or ', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'string'));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and $self->confess_at_current_offset('strings are forbidden in EMC')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'chr'));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and $self->confess_at_current_offset('`chr` function is forbidden in EMC')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (do { my $save_tokens_index = $self->{tokens_index}; my $lookahead_result = (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'str'));
								$self->{tokens_index} = $save_tokens_index; $lookahead_result; }) and $self->confess_at_current_offset('`str` function is forbidden in EMC')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ((($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'number' and do { $context_value->{value} = $tokens[0][1]; 1 }) and $context_value->{type} = 'number_value')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ((($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] =~ /\A(True|False)\Z/ and do { $context_value->{value} = $tokens[0][1]; 1 }) and $context_value->{type} = 'boolean_value')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ((($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq 'None' and do { $context_value->{value} = $tokens[0][1]; 1 }) and $context_value->{type} = 'none_value')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ((($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'identifier' and do { $context_value->{identifier} = $tokens[0][1]; 1 }) and $context_value->{type} = 'variable_value')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '[' and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ']' and ((1 and do { $context_value->{value} = []; 1 }) and $context_value->{type} = 'list_value')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '[' and ((($tokens[1] = $self->context_python_list_constructor([])) and do { $context_value->{value} = $tokens[1]; 1 }) and $context_value->{type} = 'list_value') and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ']') 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '{' and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '}' and ((1 and do { $context_value->{value} = []; 1 }) and $context_value->{type} = 'object_value')) 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '{' and ((($tokens[1] = $self->context_python_object_constructor([])) and do { $context_value->{value} = $tokens[1]; 1 }) and $context_value->{type} = 'object_value') and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '}') 
				or ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and ($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[1] eq '(' and ((($tokens[1] = $self->context_python_expression) and do { $context_value->{expression} = $tokens[1]; 1 }) and $context_value->{type} = 'parenthesis_expression') and ($tokens[2] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ')') 
				or ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and $self->confess_at_current_offset('expected python value literal'));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_list_constructor {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected !python_value_literal, \',\', !python_value_literal', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 0 <= @{$self->{tokens}}) and (($tokens[0] = $self->context_python_value_literal) and do { push @$context_value, $tokens[0]; 1 }) and (do { my $save_tokens_index = $self->{tokens_index}; while (((($self->{tokens_index} = $save_tokens_index) + 1 <= @{$self->{tokens}}) and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ',' and (($tokens[2] = $self->context_python_value_literal) and do { push @$context_value, $tokens[2]; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}
sub context_python_object_constructor {
	my ($self, $context_value) = @_;
	my @tokens;
	my $save_tokens_index = $self->{tokens_index};

	$save_tokens_index = $self->{tokens_index};
	$self->confess_at_offset('expected string token, \':\', , \',\', string token, \':\', ', $save_tokens_index)
		unless ((($self->{tokens_index} = $save_tokens_index) + 2 <= @{$self->{tokens}}) and (($tokens[0] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'string' and do { push @$context_value, $tokens[0][1]; 1 }) and ($tokens[1] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and (1 and do { push @$context_value, $self->context_python_value_literal; 1 }) and (do { my $save_tokens_index = $self->{tokens_index}; while (((($self->{tokens_index} = $save_tokens_index) + 3 <= @{$self->{tokens}}) and ($tokens[3] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ',' and (($tokens[4] = $self->{tokens}[$self->{tokens_index}++])->[0] eq 'string' and do { push @$context_value, $tokens[4][1]; 1 }) and ($tokens[5] = $self->{tokens}[$self->{tokens_index}++])->[1] eq ':' and (1 and do { push @$context_value, $self->context_python_value_literal; 1 })))
								{ $save_tokens_index = $self->{tokens_index}; }
								$self->{tokens_index} = $save_tokens_index; 1; }));
	$save_tokens_index = $self->{tokens_index};
	return $context_value;
}


##############################
##### native perl functions
##############################

sub string_tree {
	my ($self, $tree) = @_;
	my $s = '';
	if (ref $tree eq 'HASH') {
		return join "\n", map { "$_ => " . $self->maybe_indent($self->string_tree($tree->{$_})) } reverse sort keys %$tree;
	} elsif (ref $tree eq 'ARRAY') {
		return join "\n", map { "[] => " . $self->maybe_indent($self->string_tree($_)) } @$tree;
	} else {
		return $tree;
	}
}

sub maybe_indent {
	my ($self, $string) = @_;

	$string //= '';

	if ($string =~ /\n/) {
		$string =~ s/(\A|\n)/$1\t/gs;
		$string =~ s/\A/\n/gs;
	}
	return $string;
}

sub main {

	my $parser = __PACKAGE__->new;
	eval {
		foreach my $file (@_) {
			local $/ = undef;
			$parser->{text} = <>;
			my $tree = $parser->parse;
			# say $parser->string_tree($tree);
		}
	};
	if ($@) {
		say "$@";
		exit 1;
	} else {
		say "good";
	}
}

caller or main(@ARGV);



1;


