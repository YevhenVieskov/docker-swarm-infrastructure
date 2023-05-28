
/*
resource "aws_key_pair" "mysshkey" {
   key_name = var.ssh_key_name
   public_key = var.ssh_key_path
}
*/

locals {
  name = "docker-swarm"
}

locals {
  multiple_instances = {
    manager = {
      instance_type               = var.instance_type
      availability_zone           = element(module.vpc.azs, 0)
      subnet_id                   = element(module.vpc.public_subnets, 0)
      vpc_security_group_ids      = [module.dswsg.security_group_id, module.inetsg.security_group_id]
      associate_public_ip_address = true
      #user_data       = var.udata_asg != "" ? base64encode(var.udata_asg) : base64encode(file(var.udata_asg))
      #udata_asg               = file("${path.module}/${var.udata_dev}")
      user_data = "${file("bootstrap.sh")}" #base64encode(file("${path.module}/${var.udata_path}"))
      root_block_device = [
        {
          encrypted   = false
          volume_type = "gp3"
          throughput  = 200
          volume_size = 20
          tags = {
            Name = "manager-root-block"
          }
        }
      ]
    }

    worker1 = {
      instance_type               = var.instance_type
      availability_zone           = element(module.vpc.azs, 0)
      subnet_id                   = element(module.vpc.private_subnets, 0)
      vpc_security_group_ids      = [module.dswsg.security_group_id]
      associate_public_ip_address = true
      user_data                   = "${file("bootstrap.sh")}" #base64encode(file("${path.module}/${var.udata_path}"))
      root_block_device = [
        {
          encrypted   = false
          volume_type = "gp2"
          volume_size = 20
        }
      ]
    }

    worker2 = {
      instance_type               = var.instance_type
      availability_zone           = element(module.vpc.azs, 0)
      subnet_id                   = element(module.vpc.private_subnets, 0)
      vpc_security_group_ids      = [module.dswsg.security_group_id]
      associate_public_ip_address = true
      user_data                   = "${file("bootstrap.sh")}"
      root_block_device = [
        {
          encrypted   = false
          volume_type = "gp2"
          volume_size = 20
        }
      ]
    }
  }
}

module "ec2_multiple" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = local.multiple_instances

  name = "${local.name}-${each.key}"

  instance_type               = each.value.instance_type
  availability_zone           = each.value.availability_zone
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  user_data                   = each.value.user_data


  enable_volume_tags = false
  root_block_device  = lookup(each.value, "root_block_device", [])

  tags = var.tags
}

resource "aws_eip" "app_ip" {
  instance = module.ec2_multiple["manager"].id
  vpc      = true
}

# https://www.reddit.com/r/Terraform/comments/pac1fv/how_to_use_remoteexec_if_instance_is_created/
# https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/issues/48
# https://stackoverflow.com/questions/59308739/how-to-pass-docker-swarm-manager-token-to-worker-nodes-in-aws-using-terraform

/*
resource "null_resource" "manager" {

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = module.ec2_multiple["manager"].id
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["echo Hello World"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = module.ec2_multiple["manager"].public_ip
  }
  
  
    provisioner "file" {
    source      = var.private_key_path
    destination = var.dest_private_key_path
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ${var.dest_private_key_path}",
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token"
    ]
  }
}


resource "null_resource" "worker1" {

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = module.ec2_multiple["worker1"].id
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["echo Hello World"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = module.ec2_multiple["worker1"].public_ip
  }

  
  provisioner "file" {
    source      = var.private_key_path
    destination = var.dest_private_key_path
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ${var.dest_private_key_path}",
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${module.ec2_multiple["manager"].private_ip}:2377"
    ]
  }
}


resource "null_resource" "worker2" {

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = module.ec2_multiple["manager"].id
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["echo Hello World"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = module.ec2_multiple["manager"].public_ip
  }

  
  provisioner "file" {
    source      = var.private_key_path
    destination = var.dest_private_key_path
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ${var.dest_private_key_path}",
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${module.ec2_multiple["manager"].private_ip}:2377"
    ]
  }
}*/


//Ressource Definition

resource "aws_instance" "swarm" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.small"

  count = var.swarm_manager_node_count + var.swarm_worker_node_count

  key_name = "MY-SSH-KEY"

  vpc_security_group_ids = var.swarm_security_group_ids
  subnet_id              = var.swarm_subnet_id


  tags = {
    Name = "swarm-node-${count.index}"
  }

  # Use a file template to configure the user_data
  # by declaring vars we can inject these into the final script
  # that will be run.
  user_data = templatefile("${path.module}/user_data.tftpl", {
    node_number                 = count.index
    node_name                   = "swarm-node-${count.index}"
    WORKER_TOKEN                = ""
    MANAGER_TOKEN               = ""
    SWARM_AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    SWARM_AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    SWARM_AWS_REGION            = "us-east-1"
    SWARM_MANAGER_NODE_COUNT    = var.swarm_manager_node_count
    }
  )
}

# https://stackoverflow.com/questions/59308739/how-to-pass-docker-swarm-manager-token-to-worker-nodes-in-aws-using-terraform

/*

user_data

I have a script user_data.tftpl

#!/bin/bash -xe

# Install the docker
yum update -y

# install Docker
yum install docker -y

# add ec2-user to docker group
usermod -a -G docker ec2-user

# Start / enable docker
systemctl enable docker.service
systemctl start docker.service


# If we are NODE0 we are a manager

echo ${node_number}
export AWS_DEFAULT_REGION=${SWARM_AWS_REGION}
export AWS_ACCESS_KEY_ID=${SWARM_AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${SWARM_AWS_SECRET_ACCESS_KEY}


aws configure set aws_access_key_id ${SWARM_AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${SWARM_AWS_SECRET_ACCESS_KEY}
aws configure set default_region ${SWARM_AWS_REGION}

if [[ "${node_number}" == "0" ]]; then
    docker swarm init
    export MANAGER_TOKEN=$(docker swarm join-token manager | grep token | xargs echo -n)
    export WORKER_TOKEN=$(docker swarm join-token worker | grep token | xargs echo -n)

    echo "Storing Manager Token [$MANAGER_TOKEN]"
    echo "Storing Worker Token [$WORKER_TOKEN]"

    aws ssm put-parameter \
    --region us-east-1 \
    --name '/swarm/token/worker' \
    --type String \
    --overwrite \
    --value "$WORKER_TOKEN"

    aws ssm put-parameter \
    --region us-east-1 \
    --name '/swarm/token/manager' \
    --type String \
    --overwrite \
    --value "$MANAGER_TOKEN"
elif [[ "${node_number}" -le "${SWARM_MANAGER_NODE_COUNT}" ]]; then

    JOIN_STATUS=1
    while [ $JOIN_STATUS -ne 0 ]; do
        docker swarm leave || true
        $(aws ssm get-parameter \
        --region us-east-1 \
        --name '/swarm/token/manager' \
        --query 'Parameter.Value' --output text)
        JOIN_STATUS=$?
        echo $JOIN_STATUS was

        if [[ $JOIN_STATUS -ne 0 ]]; then
            echo "Unable to join swarm ... retrying in 10 seconds"
            sleep 10
        else
            echo "Maybe the join worked?"
        fi
    done
else
    JOIN_STATUS=1
    while [ $JOIN_STATUS -ne 0 ]; do
        docker swarm leave || true
        $(aws ssm get-parameter \
        --region us-east-1 \
        --name '/swarm/token/worker' \
        --query 'Parameter.Value' --output text)
        JOIN_STATUS=$?
        if [[ $JOIN_STATUS -ne 0 ]]; then
            echo "Unable to join swarm ... retrying in 10 seconds"
            sleep 10
        else
            echo "Maybe the join worked?"
        fi
    done
fi


*/



