#__________________MY VPC CREATION______________________
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
 
  tags = merge(var.tags, {
    Name = "My_VPC"
  })
}
#___________MY SUBNETS AND SUBNET GROUPS__________
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.public_subnet_ava_zone
  
   tags = merge(var.tags, {
    Name    = "Public_subnet"
  })
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_block2
  availability_zone = var.private_subnet1_ava_zone
  
   tags = merge(var.tags, {
    Name    = "Public_subnet"
  })
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet1_cidr_block
  availability_zone = var.private_subnet1_ava_zone
   tags = merge(var.tags, {
   Name    = "Private_Subnet"
  })
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet2_cidr_block
  availability_zone = var.private_subnet2_ava_zone
  tags = merge(var.tags, {
   Name    = "Private_Subnet2"
  })
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet.id]

  tags = {
    Name    = "My_DB_subnet_group"
    Creator = "Sana Rahman"
    Project = "Sprint 2"
  }
}

#__________________GATEWAY CREATION____________________

#making an internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(var.tags, {
   Name    = "Internet_gateway"
  }) 
}

#elastic ip
resource "aws_eip" "eip" {
  vpc = true
   tags = merge(var.tags, {
   Name    = "Elastic_ip"
  })
}
#nat gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = merge(var.tags, {
   Name    = "Nat_Gateway"
  })

}

#_______________ROUTE TABLES AND ASSOCIATIONS______________
#Routing table description
resource "aws_route_table" "my_public_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(var.tags, {
   Name    = "Public_Route_table"
  })

}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_public_route.id
}

resource "aws_route_table_association" "public_subnet_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.my_public_route.id
}

resource "aws_route_table" "my_private_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(var.tags, {
   Name    = "Private_Route_Table"
  })
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.my_private_route.id
}