provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "example-terraform" {
  provisioner "local-exec" {
    command = "echo instance public ip: ${aws_instance.example-terraform.public_ip} > instance_settings.txt"
  }
  provisioner "local-exec" {
    command = "echo instance public dns: ${aws_instance.example-terraform.public_dns} >> instance_settings.txt"
  }
  provisioner "local-exec" {
    command = "echo instance KeyPair: ${aws_key_pair.ec2_KeyPair.key_name} >> instance_settings.txt" 
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo yum update -y",
      "sudo yum install -y awslogs",
      "sudo mv /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.bak",
      "sudo cp ~/awslogs.conf /etc/awslogs/awslogs.conf",
      "sudo systemctl start awslogsd",
      "sudo chkconfig awslogsd on",
      "sudo systemctl enable awslogsd.service"
    ]
  }

}