
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_instance" {
  ami           = "ami-09d9029d9fc5e5238"
  instance_type = "t2.micro" 
  key_name      = "efs_key"
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "Public Instance"
  }
  security_groups = [aws_security_group.ec2_sg.id]
}

resource "aws_instance" "private_instance" {
  ami           = "ami-09d9029d9fc5e5238"
  instance_type = "t2.micro" 
  subnet_id = aws_subnet.private_subnet.id
  key_name = "efs_key"
  tags = {
    Name = "Private Instance"
  }
  security_groups = [aws_security_group.ec2_sg.id]
}
