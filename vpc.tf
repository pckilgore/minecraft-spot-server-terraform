data http "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_vpc" "server-vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "MinecraftServerVPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.server-vpc.id}"
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "MinecraftServerSubnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.server-vpc.id}"
  tags = {
    Name = "MinecraftServerGateway"
  }
}

resource "aws_route_table" "minecraft" {
  vpc_id = "${aws_vpc.server-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags = {
    Name = "MinecraftServerRouteTable"
  }

}

resource "aws_route_table_association" "minecraftsubnet" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.minecraft.id}"
}


resource "aws_security_group" "mc-server-sg" {
  name        = "MinecraftSecurityGroup"
  description = "Allows minecraft-necessary traffic, including SSH"
  vpc_id      = "${aws_vpc.server-vpc.id}"
  tags = {
    Name = "MinecraftSecurityGroup"
  }
  ingress {
    description = "Allows SSH from the ip where terraform is run."
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows all tcp minecraft traffic."
    protocol    = "tcp"
    from_port   = 25565
    to_port     = 25565
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows all udp minecraft traffic."
    protocol    = "udp"
    from_port   = 25565
    to_port     = 25565
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allows all traffic out."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
