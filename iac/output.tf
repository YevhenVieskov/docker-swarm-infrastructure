output "swarm_manager_1_public_ip" {
  value = aws_instance.swarm-manager.0.public_ip
}

output "swarm_manager_1_private_ip" {
  value = aws_instance.swarm-manager.0.private_ip
}

output "swarm_manager_elastic_ip" {
  value = aws_eip.swarm-manager-eip.public_ip
}

/*
output "swarm_manager_2_public_ip" {
  value = "${aws_instance.swarm-manager.1.public_ip}"
}

output "swarm_manager_2_private_ip" {
  value = "${aws_instance.swarm-manager.1.private_ip}"
}

output "swarm_manager_3_public_ip" {
  value = "${aws_instance.swarm-manager.2.public_ip}"
}

output "swarm_manager_3_private_ip" {
  value = "${aws_instance.swarm-manager.2.private_ip}"
}
*/