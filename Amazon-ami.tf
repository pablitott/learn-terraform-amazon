
#Script from 
# https://learn.hashicorp.com/terraform/getting-started/provision

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_key_pair" "ec2_KeyPair" {
  #description    = "KeyPair to be used to connect via SSH to the EC2"
  key_name       = "terraform_KeyPair"
  public_key     = file(var.publicKeyPairFile)
}
# Define aws EC2 instance
resource "aws_instance" "example-terraform" {
  ami        = var.image_id
  key_name   = aws_key_pair.ec2_KeyPair.key_name
  instance_type = "t2.micro"
  
  # define tags for the resource
  tags = {
    Name   = "example-terraform"
    Owner  = "Pablo Trujillo"
    distro = "Amazon"
  }  

  #define conection values
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.privateKeyPairFile)
    host        = self.public_ip
  }

  #Execute a command in the Local environment
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
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "kubectl version --client"
    ]
  }
}

#define an eip resource and assign to EC2 above
resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example-terraform.id
}

output "ip" {
  value = aws_eip.ip.public_ip
}
