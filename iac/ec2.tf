
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
      associate_public_ip_address = false
      user_data = "${file("bootstrap.sh")}" #base64encode(file("${path.module}/${var.udata_path}"))
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
      associate_public_ip_address = false
      user_data =  "${file("bootstrap.sh")}" #base64encode(file("${path.module}/${var.udata_path}"))
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

 


/*
module "ec2_manager" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "docker-swarm-manager"
  ami  = var.ami
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [module.dswsg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0].id

  tags =  merge(var.tags, { Name = "docker-swarm manager" })
}

module "ec2_worker" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["worker1", "worker2"])

  name = "docker-swarm-${each.key}"
  ami
  instance_type          = var.instance_type
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = [module.dswsg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0].id

  tags =  merge(var.tags, { Name = "docker-swarm worker" })
}
*/
