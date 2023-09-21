variable "github_token" {
  sensitive = true
  type = string
}

variable "aws_instances" {
  type = map(any)
}

variable "tags" {
  
}