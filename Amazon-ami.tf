
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

# this is the JSON policy to have access to the logs
# review if the Resource should be "*" or as it is now
resource "aws_iam_policy" "terraformPolicy" {
  name        = "terraformPolicy"
  path        = "/"
  description = "Automated TerraForm Test Policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource":[
          "arn:aws:logs:*:*:*"
      ]

    }
  ]
}
EOF
}

#define the main aws_iam_role and named as terraformRole
resource "aws_iam_role" "terraformRole" {
  name = "terraformRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]    
}
EOF

   tags = {
     project = "terraformCloudWatch"
     Name    = "terraformRole"
     Owner   = "Pablo Trujillo"
   }
}

# I think this resource is doing nothing, check before remove it
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.terraformRole.name}"
  policy_arn = "${aws_iam_policy.terraformPolicy.arn}"
}

#Creates the Role profile
resource "aws_iam_instance_profile" "terraformProfile" {
  name = "terraformProfile"
  role = "${aws_iam_role.terraformRole.name}"
}

# Define aws EC2 instance
resource "aws_instance" "terraformInstance" {
  ami        = var.image_id
  key_name   = aws_key_pair.ec2_KeyPair.key_name
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.terraformProfile.name}"

  # define tags for the resource
  tags = {
    Name    = "terraformInstance"
    Owner   = "Pablo Trujillo"
    distro  = "Amazon"
    project = "terraformCloudWatch"
  }  

  #define conection values
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.privateKeyPairFile)
    host        = self.public_ip
  }

   provisioner "file" {
     source       = "./Docker/Dockerfile"
     destination  = "~/Dockerfile"
   }
  
  provisioner "file" {
    source       = "./Docker/installDocker"
    destination  = "~/installDocker"
  }

  provisioner "file" {
    source       = "./awslogs.conf"
    destination  = "~/awslogs.conf"
  }

  #Execute a command in the Local environment
  provisioner "local-exec" {
    command = "echo instance public ip: ${aws_instance.terraformInstance.public_ip} > instance_settings.txt"
  }
  provisioner "local-exec" {
    command = "echo instance public dns: ${aws_instance.terraformInstance.public_dns} >> instance_settings.txt"
  }
  provisioner "local-exec" {
    command = "echo instance KeyPair: ${aws_key_pair.ec2_KeyPair.key_name} >> instance_settings.txt" 
  }

  provisioner "remote-exec" {
    inline = [
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

#define an eip resource and assign to EC2 above
resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.terraformInstance.id
}

