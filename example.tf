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

resource "aws_security_group" "port_22_ingress_globally_accessible" {
    name = "port_22_ingress_globally_accessible"

    ingress { 
        from_port = 22    
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "example" {
  ami             = "ami-00068cd7555f543d5"
  instance_type   = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.port_22_ingress_globally_accessible.id}"]
  provisioner "local-exec" {
    command = "yum -y install ansible"
  }
  provisioner "remote-exec" {
                inline = ["sudo hostname"]

                connection {
                        host = self.public_ip
                        type        = "ssh"
                        user        = "ec2-user"
                        private_key = "${tls_private_key.example.private_key_pem}"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i \"${self.public_ip},\" --private-key ${tls_private_key.example.private_key_pem} httpd.yml"
  }
}
