provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

variable "key_name" {}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "aws_instance" "example" {
  ami             = "ami-00068cd7555f543d5"
  instance_type   = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  provisioner "remote-exec" {
                inline = ["sudo hostname"]

                connection {
                        host = self.public_ip
                        type        = "ssh"
                        user        = "ec2-user"
                        private_key = "${tls_private_key.example.private_key_pem}"
                }
        }  
}
