provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "sg-besu" {
  name        = "tf-hyperledger-besu"
  description = "Hyperledger Besu Nodes"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }
  ingress {
    from_port   = 8545
    to_port     = 8545
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RPC over HTTP"
  }
  ingress {
    from_port   = 8645
    to_port     = 8645
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RPC over WS"
  }
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "P2P PORTS"
  }
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "P2P PORTS"
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
	description = "TRAFFIC OUTSIDE"
  }
}
resource "aws_instance" "tf-example" {
  count                  = 4
  ami                    = "ami-07dfba995513840b5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg-besu.id]
  key_name               = "besu"
  tags = {
    Name = "terraform-example-${count.index}"
  }
    connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./besu.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y groupinstall 'Development tools'",
      "sudo yum -y install java-11-openjdk-devel",
      "sudo mkdir -p /opt/besu-data/IBFT-Network/Node/data",
      "sudo chown -R $(id --name -u):$(id --name -u) /opt/besu-data",
	  "sudo yum install wget",
	  "sudo yum install tree",
	  "sudo mkdir -p /bin/besu"
    ]
  }
}
output "instance_public_ip_addresses" {
  value = {
    for instance in aws_instance.tf-example:
    instance.id => instance.public_ip
    if instance.associate_public_ip_address
  }
}