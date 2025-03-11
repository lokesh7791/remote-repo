resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "terraform-vpc"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/25"
    map_public_ip_on_launch = false
    availability_zone = "us-east-1a"
    tags = {
        Name = "priavte_subnet"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/25"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "terraform.igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "ec2_sg" {
    name = "ec2-security-group"
    description = "security group for ec2"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "alb_sg" {
    name = "alb-security-group"
    description = "security group for ALB"
    vpc_id = aws_vpc.main.id
     
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.ec2_sg.id]
    }
}