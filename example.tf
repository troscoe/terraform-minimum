provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami             = "ami-00068cd7555f543d5"
  instance_type   = "t2.micro"
}
