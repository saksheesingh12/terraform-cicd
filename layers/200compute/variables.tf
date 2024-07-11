variable "layer" {
  description = "Name of the layer to propagate to resources."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account Number"
  type        = string
}

variable "aws_region" {
  description = "AWS Account Number"
  type        = string
  default     = "ap-south-1"
}
  