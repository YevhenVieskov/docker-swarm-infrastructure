module "inetsg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "internet-sg"
  description = "Security group that allows traffic between docker swarm nodes"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [

    {
      rule        = "http-80-tcp"
      description = "http"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      rule        = "https-443-tcp"
      description = "https"
      cidr_blocks = module.vpc.vpc_cidr_block
    }

  ]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "internet access security group" })

}


module "dswsg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "docker-swarm-sg"
  description = "Security group that allows traffic between docker swarm nodes"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [

    {
      from_port   = 2375
      to_port     = 2375
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    
    {
      from_port   = 2376
      to_port     = 2376
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      from_port   = 2377
      to_port     = 2377
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

    {
      rule        = "ssh-tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      rule        = "all-icmp"
      description = "icmp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },

  ]

  egress_rules = ["all-all"]


  # Tags
  tags = merge(var.tags, { Name = "docker-swarm security group" })
}



