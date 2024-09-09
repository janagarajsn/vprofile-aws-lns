variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-east-2a"
}

variable "ami_id" {
  description = "The ami id"
  type        = string
  default     = "ami-09cf4d6bbb9a66eab"
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t2.micro"
}

variable "security_group_id" {
  description = "The security group id"
  type        = string
  default     = "sg-0e4372ad423f5df01"
}

variable "key_name" {
  description = "The key name"
  type        = string
  default     = "vprofile-key"
}

variable "bucket_name" {
  description = "The bucket name"
  type        = string
  default     = "vprofile-arts-j2"
}

variable "min_size" {
  description = "The min size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The max size"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "The desired capacity"
  type        = number
  default     = 1
}

variable "elb_security_group_id" {
  description = "The elb security group id"
  type        = string
  default     = "sg-0cd2e838d49fefdfd"
}

variable "certificate_arn" {
  description = "The certificate arn"
  type        = string
  default     = "arn:aws:acm:us-east-1:307873435526:certificate/065ae8b3-e675-49b4-acf7-88ebce3669d9"
}
