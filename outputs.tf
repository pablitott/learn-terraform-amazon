output "aws_key_pair"{
  value = aws_instance.terraformInstance.key_name
}

output "aws_instance" {
  value = var.image_id
}

output "public_dns" {
  value = aws_eip.terraformElasticIp.public_dns
}

output "connection"{
  value = "ssh -i .ssh\\${aws_instance.terraformInstance.key_name} ec2-user@${aws_eip.terraformElasticIp.public_dns}"
}
