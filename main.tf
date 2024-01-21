provider "aws" {
    region = "eu-west-2"

}

# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create custom route table 
# 4. Create a subnet 
# 5. Associate subnet with route table 
# 6. Create security group to allow port 22 80 443
# 7. Create a network interface  with an ip in the subnet that was created in step 4 
# 8. Assign an elastic IP To the network interface created in step  7
# 9. create ubuntu server and install / enable apache2

resource "aws_security_group" "allow-web" {

    name = "allow_web_trafic"
    description = "Allow web inbound traffic"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  

    tags = {
      Name =  "Allow web trafic"
    }
    


  
}
resource "aws_eip" "one" {
    network_interface = aws_network_interface.web-server-nic.id
    associate_with_private_ip = aws_network_interface.web-server-nic.private_ip
    depends_on = [ aws_internet_gateway.internet-gateway ]

  
}


resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web.id]


}


resource "aws_instance" "root-instance" {
    ami = "ami-0e5f882be1900e43b"
    instance_type = "t2.nano"
    availability_zone =  "eu-west-2a"

    key_name = "main-key"


    network_interface {
      device_index = 0
      network_interface_id =  aws_network_interface.web-server-nic.id
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y 
                sudo apt-get install apache2 -y 
                sudo bash -c 'echo my very first web sever ' > /var/www/html/index.html
                EOF

    tags = {
      Name  = "Ubuntu-1"
    }

}

resource "aws_route_table" "production-route-table" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id

    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }


  
}

resource "aws_route_table_association" "association-a" {
    subnet_id = aws_subnet.subnet.id
    route_table_id = aws_route_table.production-route-table.id
  
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-2a"
    tags = {
      Name = "production-subnet"
    }
  
}

resource "aws_internet_gateway" "internet-gateway" {
    vpc_id =  aws_vpc.vpc.id

    tags = {
      Name = "production"
    }
    
  
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production"
    }
  
}