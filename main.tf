resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"  
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.my_vpc.id  
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
}

resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.subnet.id
    route_table_id = aws_route_table.route.id  
}
resource "aws_security_group" "asg" {
  name   = "security_group"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
    ami = var.ami
    instance_type = var.inst_type
    vpc_security_group_ids = [aws_security_group.asg.id]
    subnet_id = aws_subnet.subnet.id
    availability_zone = "us-east-1a"
    user_data = base64encode(file("userdata.sh"))
    # user_data = file("${path.module}/userdata1.sh")
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}