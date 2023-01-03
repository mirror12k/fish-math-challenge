
all:
	env PERL5LIB="." ./Sugar/Lang/SugarGrammarCompiler.pm --standalone python_math_parser.synth > PythonMathValidator.pm
	chmod +x PythonMathValidator.pm


run-python:
	~/src/perl/repo/Sugar/Lang/SugarGrammarCompiler.pm --standalone python_math_parser.synth > PythonMathValidator.pm
	./PythonMathValidator.pm tests/python_input.py
	python3 tests/python_input.py

docker-compile:
	docker build -t python_math . && docker run -it python_math
