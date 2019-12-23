provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami             = "ami-00785474df0ceb957"
  instance_type   = "c5.large"
  instance_state  =  var.is
}
