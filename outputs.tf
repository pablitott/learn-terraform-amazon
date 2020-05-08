output "aws_key_pair"{
  value = aws_instance.example-terraform.key_name
}

output "aws_instance" {
  value = var.image_id
}

output "public_dns"{
  value = aws_instance.example-terraform.public_dns
}

output "ip" {
  value = aws_eip.ip.public_ip
}
