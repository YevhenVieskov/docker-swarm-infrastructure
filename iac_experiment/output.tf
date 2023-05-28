# EC2 Multiple
output "ec2_multiple" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple
}

output "ec2_manager" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["manager"]
}

output "swarm_manager_public_ip" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["manager"].public_ip
}

output "swarm_worker1_public_ip" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["worker1"].public_ip
}

output "swarm_worker2_public_ip" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["worker2"].public_ip
}

output "swarm_manager_private_ip" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["manager"].private_ip
}

output "swarm_worker1_private_ip" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["worker1"].private_ip
}

output "swarm_worker2_private_ip" {
  description = "The full output of the `ec2_module` module"
  value       = module.ec2_multiple["worker2"].private_ip
}

output "swarm_manager_elastic_ip" {
  description = "The full output of the `ec2_module` module"
  value       = aws_eip.app_ip.public_ip
}


