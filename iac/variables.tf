variable "swarm_manager_token" {
  default = ""
}
variable "swarm_worker_token" {
  default = ""
}
variable "swarm_ami_id" {
  default = "ami-03f65b8614a860c29"
}
variable "swarm_manager_ip" {
  default = ""
}
variable "swarm_managers" {
  default = 1
}
variable "swarm_workers" {
  default = 1
}
variable "swarm_instance_type" {
  default = "t2.micro"
}
variable "swarm_init" {
  default = false
}

variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "vieskovtf"
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
  default     = "us-west-2"
}

variable "private_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = "attract_key"
}

variable "udata_path" {
  description = "Name to be used for the Jenkins master instance"
  type        = string
  default     = "./bootsrap.sh"
}

variable "private_key_path" {
  description = "The path to an EC2 Key Pair"
  type        = string
  default     = "~/attract_key.pem"
}

variable "dest_private_key_path" {
  description = "The path to an EC2 Key Pair"
  type        = string
  default     = "/home/ubuntu/attract_key.pem"
}