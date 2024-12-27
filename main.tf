terraform { 
  cloud { 
    
    organization = "0xdod_org" 

    workspaces { 
      name = "0xdod_wrkspc" 
    } 
  } 
}


resource "aws_instance" "web_server" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.eip == null
  user_data                   = <<-EOF
    #!/bin/bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
    newgrp docker
    curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o docker-compose
    sudo chmod +x docker-compose
    sudo mv docker-compose /usr/local/bin/docker-compose
  EOF

  tags = {
    Name = "cv-challenge03-server"
    Environment = "Dev"
  }

}

resource "aws_eip_association" "eip_assoc" {
  instance_id         = aws_instance.web_server.id
  allow_reassociation = true
  allocation_id       = var.eip
}

output "instance_id" {
  value = aws_instance.web_server.id
}

output "public_ip" {
  value = var.eip != null ? aws_eip_association.eip_assoc.public_ip : aws_instance.web_server.public_ip
}
