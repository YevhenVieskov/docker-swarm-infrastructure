resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}a"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_instance" "swarm-manager" {
  count = "${var.swarm_managers}"
  ami = "${var.swarm_ami_id}"
  instance_type = "${var.swarm_instance_type}"
  subnet_id     = aws_default_subnet.default_az1.id
  #user_data                   = "${file("bootstrap.sh")}"
  tags = {
    Name = "swarm-manager"
  }
  vpc_security_group_ids = [
    "${aws_security_group.docker.id}"
  ]
  key_name = var.private_key_name

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host        = aws_instance.swarm-manager[count.index].public_ip
  }

  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/home/ubuntu/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/bootstrap.sh",
      "sh /home/ubuntu/bootstrap.sh"      
    ]
  }

  
  provisioner "remote-exec" {
    inline = [      
      "docker swarm init", 
      "docker swarm join-token --quiet worker > /home/ubuntu/token",
      "docker node ls",
      "docker node update --label-add manager=yes  ip-${aws_instance.swarm-manager[count.index].private_ip//./-}"
    ]
      
  }
  
}

resource "aws_instance" "swarm-worker" {
  count = "${var.swarm_workers}"
  ami = "${var.swarm_ami_id}"
  instance_type = "${var.swarm_instance_type}"
  subnet_id     = aws_default_subnet.default_az1.id
  #user_data                   = "${file("bootstrap_bash.sh")}"
  tags = {
    Name = "swarm-worker"
  }
  vpc_security_group_ids = [
    "${aws_security_group.docker.id}"
  ]
  key_name = var.private_key_name
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host        = aws_instance.swarm-worker[count.index].public_ip
  }
 
   provisioner "file" {
    source = var.private_key_path
    destination = "/home/ubuntu/attract_key.pem"
  }

  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/home/ubuntu/bootstrap.sh"
  }

  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/bootstrap.sh",
      "sh /home/ubuntu/bootstrap.sh"      
    ]
  }

  provisioner "remote-exec" {
    inline = [      
      "sudo chmod 400 /home/ubuntu/attract_key.pem",
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i attract_key.pem ubuntu@${aws_instance.swarm-manager[count.index].private_ip}:/home/ubuntu/token .",
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${aws_instance.swarm-manager[count.index].private_ip}:2377",
      "docker node ls",
      "docker node update --label-add worker=yes ip-${aws_instance.swarm-manager[count.index].private_ip//./-}"
    ]
  }
  
}

resource "aws_eip" "swarm-manager-eip" {
  instance = aws_instance.swarm-manager.0.id
  domain   = "vpc"
}

resource "aws_eip_association" "swarm-manager-association" {
  instance_id   = aws_instance.swarm-manager.0.id
  allocation_id = aws_eip.swarm-manager-eip.id
}




