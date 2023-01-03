provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "${local.fullname}"
    }
  }
}

locals {
  fullname = "fish-math"
  ssh_keypath = "./instance_ssh_key"
  ingress_ports = [8651, 22]
}

resource "random_id" "apikey_random" { byte_length = 16 }
resource "aws_instance" "instance" {
  ami           = "ami-0e14491966b97e8bc"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.instance_security_group.name]
  key_name = aws_key_pair.instance_aws_key.id

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo env DEBIAN_FRONTEND=noninteractive apt -y update",
      "sudo env DEBIAN_FRONTEND=noninteractive apt install -y awscli python2 unzip curl docker.io php-cli",
      "sudo mkdir /app",
      "sudo chown ubuntu:ubuntu /app",
      "echo 's3://${aws_s3_bucket.deploy_bucket.id}/'",
      "curl https://s3.amazonaws.com/${aws_s3_bucket.deploy_bucket.id}/package.zip > /app/package.zip",
      "unzip /app/package.zip -d /app",
      "sudo usermod -aG docker ubuntu",
      "mkdir /app/temp_files",
      "cd /app && ./bin/build.sh",
      "echo -n '${file("../flag.txt")}' > /app/chrome_docker/flag.txt",
      "echo -n '${random_id.apikey_random.hex}' | md5sum | awk '{ printf $1 }' > /app/apikey.txt",
      "cd /app && ./bin/daemonize.sh ubuntu \"php ./bin/fish-server.php\" /app/fish-server.log /dev/null",
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${local.ssh_keypath}")
  }
}

resource "aws_key_pair" "instance_aws_key" {
  key_name_prefix = "${local.fullname}-aws_key-"
  public_key = file("${local.ssh_keypath}.pub")
}

resource "aws_security_group" "instance_security_group" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    for_each = local.ingress_ports
    iterator = port

    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}


resource "random_id" "deploy_bucket_random_id" { byte_length = 8 }
resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "${local.fullname}-package-${random_id.deploy_bucket_random_id.hex}"
  force_destroy = true
}
resource "aws_s3_bucket_acl" "deploy_bucket_acl" {
  bucket = aws_s3_bucket.deploy_bucket.id
  acl           = "public-read"
}
resource "aws_s3_bucket_policy" "deploy_bucket_policy" {
  bucket = aws_s3_bucket.deploy_bucket.id
  policy = templatefile("package_bucket_policy.json", { bucket = aws_s3_bucket.deploy_bucket.id })
}

resource "aws_s3_object" "build_file" {
  bucket = aws_s3_bucket.deploy_bucket.id
  key    = "package.zip"
  source = "package.zip"
  etag   = filemd5("package.zip")
}



output "server_ip" { value = "${aws_instance.instance.public_ip}" }
output "server_address" { value = "http://${aws_instance.instance.public_ip}:8651/#apikey_${random_id.apikey_random.hex}" }


