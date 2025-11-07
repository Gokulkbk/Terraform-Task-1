variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


