#!/usr/bin/env perl
use strict;
use warnings;

use feature 'say';

use Sugar::Test::Barrage;



Sugar::Test::Barrage->new(
	test_files_dir => 'tests',
	test_files_regex => qr/\.py$/,
	test_processor => "./PythonMathValidator.pm \$testfile",
	control_processor => "cat \$testfile.res",
)->run;


