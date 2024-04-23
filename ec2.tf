# Create a security group for allowing SSH and HTTP traffic
resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


# Launch an EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami                    = "ami-007020fd9c84e18c7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id] # Use the security group ID
  key_name               = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install nginx -y
sudo service nginx start
EOF

  tags = {
    Name = "Public Instance"
  }
}

# Launch an EC2 instance in the private subnet
resource "aws_instance" "private_instance" {
  ami                    = "ami-007020fd9c84e18c7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id] # Use the security group ID
  key_name               = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Private Instance"
  }
}

output "public_ip" {
  value = aws_instance.public_instance.public_ip
}

