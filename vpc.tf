resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "terraform-VPC"
    } 
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  availability_zone = "us-east-2a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "Private Subnet"
  }
}


resource "aws_internet_gateway" "ig_2tier" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Igw-tf"
  }
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"
    depends_on = [ aws_internet_gateway.ig_2tier ]
}

resource "aws_nat_gateway" "natgw_tf" {
    subnet_id = aws_subnet.public_subnet.id
    allocation_id = aws_eip.nat_eip.id
    tags = {
    Name = "Nat Gateway-tf"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Public route_table"
  }
}


# Creating route in the public route table for Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_2tier.id
}

# Associating public route table with public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Private route_table"
  }
}

# Creating route in the private route table for NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw_tf.id
}

# Associating private route table with private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}