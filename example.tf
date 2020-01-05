provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

variable "key_name" {}
variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/id_dsa"
}

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
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress { 
      from_port = 22    
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress { 
      from_port = 80    
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "example" {
  ami                    = "ami-a8d369c0"
  instance_type          = "t2.medium"
  key_name               = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.port_22_ingress_globally_accessible.id}"]

  provisioner "remote-exec" {
    inline = ["sudo hostname"]
    
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.example.private_key_pem}"
    }
  }
  
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "httpd.yml"
      }
      hosts = ["self.public_ip"]
    }
  }
}
