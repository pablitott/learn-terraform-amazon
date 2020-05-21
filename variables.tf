# to use this file use 
# terraform <command> -var-file=example.tfvars
variable "image_id" {
  #description    = "The id for the image to use from Amazon ami list availables"
  default        = "ami-0323c3dd2da7fb37d"
  }
variable "publicKeyPairFile" {
  #description    = "public ssh key file full path"
  default        = "~/.ssh/terraform_KeyPair.pem"
}
variable "privateKeyPairFile" {
   #description   = "private ssh key file full path"
   default       = "~/.ssh/terraform_KeyPair"
 }
variable "workingRegion" {
  default = "us-east-1"
}

variable "terraformSubnet" {
  # pre-existing resource
  description = "Specific for terraform use; actually is being used by MailServer in us-east-1b"
  default = "subnet-0a7fc996e151873a0"
}

variable "terraformSecurityGroup"{
  description = "Security group used for NextCloud ECs"
  default     = "sg-0d182a036ffe6b214"
}
