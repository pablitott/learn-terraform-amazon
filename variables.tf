# to use this file use 
# terraform <command> -var-file=example.tfvars
variable "image_id" {
  #description    = "The id for the image to use from Amazon ami list availables"
  default        = "ami-0323c3dd2da7fb37d"
  }
variable "publicKeyPairFile" {
  #description    = "public ssh key file full path"
  default        = "~/.ssh/terraform_KeyPair.pub"
}
 variable "privateKeyPairFile" {
   #description   = "private ssh key file full path"
   default       = "~/.ssh/terraform_KeyPair"
 }

