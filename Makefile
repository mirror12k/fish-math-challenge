
include .env
export

configure:
	@aws configure set aws_access_key_id ${AWS_ACCESS_ID}
	@aws configure set aws_secret_access_key ${AWS_ACCESS_KEY}

bash: configure
	bash

build_package:
	rm -f infrastructure/package.zip
	zip infrastructure/package.zip -r python_executor/ python_math/ bin/ chrome_docker/
