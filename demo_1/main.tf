provider "aws" {
  region  = "us-east-1"
  #access_key = "xxxxxxxxxxxxxxxxxxxxxxxxx"
  #secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxx"
}



resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "terra"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo-igv"
  }
}

resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "demo-rt"
  }
}

resource "aws_subnet" "demo-pub-1a" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.20.30.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "demo-pub-1a"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.demo-pub-1a.id
  route_table_id = aws_route_table.demo-rt.id
}

resource "aws_security_group" "demo-ec2-sg" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SHH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "demo-ec2-sg"
  }
}
resource "aws_network_interface" "demo-nic" {
  subnet_id       = aws_subnet.demo-pub-1a.id
  private_ips     = ["10.20.30.50"]
  security_groups = [aws_security_group.demo-ec2-sg.id]

}

resource "aws_eip" "demo-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.demo-nic.id
  associate_with_private_ip = "10.20.30.50"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_instance" "demo-server" {
  ami           = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "key"
  network_interface {
    network_interface_id = aws_network_interface.demo-nic.id
    device_index         = 0
  }
  tags = {
    Name = "demo-server"
  }
}



resource "aws_elb" "demo-elb" {
  name = "terraform-example-elb"

  # The same availability zone as our instances
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_autoscaling_group" "demo-asg" {
  availability_zones   = local.availability_zones
  name                 = "demo-asg"
  max_size             = var.asg_max
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  force_delete         = true
  launch_configuration = aws_launch_configuration.demo-lc.name
  load_balancers       = [aws_elb.demo-elb.name]

  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  tag {
    key                 = "Name"
    value               = "demo-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "demo-lc" {
  name          = "demo-lc"
  image_id      = var.aws_amis[var.aws_region]
  instance_type = var.instance_type

  # Security group
  security_groups = [aws_security_group.demo-ec2-sg.id]
  user_data       = file("userdata.sh")
  key_name        = "key"
}


