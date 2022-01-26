//This Terraform Template creates five Compose enabled Docker Machines on EC2 Instances
//which are ready for Docker Swarm operations, using the AMI of Clarusway (ami-0858bef4ba3225b69).
//The AMI of Clarusway Compose enabled Docker Machine (clarusway-docker-machine-with-compose-amazon-linux-2)
//is published on North Virginia Region for educational purposes.
//Docker Machines will run on Amazon Linux 2 with custom security group
//allowing SSH (22), HTTP (80) and TCP(2377, 8080) connections from anywhere.
//User needs to select appropriate key name when launching the template.

provider "aws" {
  region = "us-east-1"
  //  access_key = ""
  //  secret_key = ""
  //  If you have entered your credentials in AWS CLI before, you do not need to use these arguments.
}

resource "aws_instance" "manager" {
  ami             = "ami-0858bef4ba3225b69"
  instance_type   = "t2.micro"
  key_name        = "key"
  //  Write your pem file name
  security_groups = ["docker-swarm-sec-gr"]
  #count = 5
  tags = {
    Name = "Leader-Manager"
  }
  user_data = <<-EOF
          #! /bin/bash
          yum update -y
          yum install git -y
          amazon-linux-extras install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
          -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          cd /home/ec2-user
          git clone https://github.com/skoc10/phonebook_Dockerswarm_ECR.git
          cd /home/ec2-user/phonebook_Dockerswarm_ECR
          EOF

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = "${file("/Users/koc/Desktop/key_AWS/key.pem")}"
  }
  provisioner "local-exec" {
    # Keep in a local file the swarm manager IP address
    command = "echo Manager IP: ${self.public_ip} > manager_ip.txt"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sleep 240",
      "docker swarm init --advertise-addr ${self.private_ip}",
      "docker swarm join-token manager --quiet > /home/ec2-user/manager-token.txt",
      "docker swarm join-token worker --quiet > /home/ec2-user/worker-token.txt",
      "docker service create --name=viz --publish=8080:8080/tcp --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamples/visualizer",
      "cd /home/ec2-user/phonebook_Dockerswarm_ECR",
      "docker image build -t skoc10/phonebookswarm:latest .",
      "docker stack deploy -c ./docker-compose.yml phonebook"
    ]
  }        
}

resource "aws_instance" "manager2" {
    count           = 2
    ami             = "ami-0858bef4ba3225b69"
    instance_type   = "t2.micro"
    key_name        = "key"
    //  Write your pem file name
    security_groups = ["docker-swarm-sec-gr"]

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("/Users/koc/Desktop/key_AWS/key.pem")}"
    }
  
    tags = {
        Name = "Manager ${count.index} "
    }
    
    provisioner "file" {
        source = "key.pem"
        destination = "/home/ec2-user/key.pem"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y docker",
            "sudo usermod -aG docker ec2-user",
            "sudo chmod 400 /home/ec2-user/key.pem",
            "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i key.pem ec2-user@${aws_instance.manager.private_ip}:/home/ec2-user/manager-token.txt .",
            "docker swarm join --token $(cat /home/ec2-user/manager-token.txt) ${aws_instance.manager.private_ip}:2377"
        
        ]
    }

    depends_on = [
      aws_instance.manager,
    ]
}
resource "aws_instance" "worker" {
    count           = 2
    ami             = "ami-0858bef4ba3225b69"
    instance_type   = "t2.micro"
    key_name        = "key"
    //  Write your pem file name
    security_groups = ["docker-swarm-sec-gr"]

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("/Users/koc/Desktop/key_AWS/key.pem")}"
    }
  
    tags = {
        Name = "Worker ${count.index} "
    }
    
    provisioner "file" {
        source = "key.pem"
        destination = "/home/ec2-user/key.pem"
  }

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y docker",
            "sudo usermod -aG docker ec2-user",
            "sudo chmod 400 /home/ec2-user/key.pem",
            "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i key.pem ec2-user@${aws_instance.manager.private_ip}:/home/ec2-user/worker-token.txt .",
            "docker swarm join --token $(cat /home/ec2-user/worker-token.txt) ${aws_instance.manager.private_ip}:2377"
        ]
    }

    depends_on = [
      aws_instance.manager,
    ]
}
resource "aws_security_group" "tf-docker-sec-gr" {
  name = "docker-swarm-sec-gr"
  tags = {
    Name = "docker-swarm-sec-group"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2377
    protocol    = "tcp"
    to_port     = 2377
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "manager_ip" {
  description = "Swarm Manager IP"
  value = "${aws_instance.manager.public_ip}"
}

output "workers_ip" {
  description = "Swarm Worker IP"
  value = "${aws_instance.worker.*.public_ip}"
  
}