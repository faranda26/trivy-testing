variable "aws_ami_filter_name_values" {
  description = "AMI name"
  type        = list(string)
}

variable "aws_ami_owners" {
  description = "AMI owner"
  type        = list(string)
}

variable "root_block_device_kms_key_id" {
  description = "(Optional) The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
  type        = string
}

variable "root_block_device_volume_size" {
  description = "(Optional) The size of the volume in gigabytes"
  type        = number
}

variable "root_block_device_volume_type" {
  description = "(Optional) The volume type"
  type        = string
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = true
}

variable "cpu_options_core_count" {
  description = "Sets the number of CPU cores for an instance"
  type        = number
}

variable "cpu_options_threads_per_core" {
  description = "(Optional - has no effect unlees core_count is also set) if set to 1, hyperthreading is disabled on the launched instance. Defaults to 2 if not set"
  type        = number
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled"
  type        = bool
}

variable "iam_instance_profile" {
  description = " IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
}

variable "root_block_device_iops" {
  description = "The amount of provisioned IOPS. This must be set with a volume_type of 'io1/io2/gp3'"
  type        = number
}

variable "instance_market_options_spot_options_max_price" {
  description = "(Optional) The maximum hourly price that you're willing to pay for a Spot Instance."
  type        = number
}

variable "instance_market_options_spot_options_spot_instance_type" {
  description = "(Optional) The Spot Instance request type. Valid values include one-time, persistent. Persistent Spot Instance requests are only supported when the instance interruption behavior is either hibernate or stop. The default is one-time"
  default     = "one-time"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use for the instance"
  type        = string
}

variable "availability_zone" {
  description = "(Optional) The Availability Zone for the instance"
  type        = string
}

variable "key_name" {
  description = "(Optional) The key name to use for the instance"
  type        = string
}

variable "private_dns_name_options_enable_resource_name_dns_a_record" {
  default     = false
  description = "(Optional) Indicates whether to respond to DNS queries for instance hostnames with DNS A records"
  type        = bool
}

variable "private_dns_name_options_enable_resource_name_dns_aaaa_record" {
  default     = false
  description = "(Optional) Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records"
  type        = bool
}


variable "tags" {
  description = "Map of tags to assign to the resource"
  type        = map(any)
}

variable "user_data_file" {
  description = "The location of the user data script to provide when launching the instance"
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID to launch in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "(Optional, VPC only) List of security group IDs to associate with."
  type        = list(string)
}

variable "name" {
  description = "EC2 name"
  type        = string
}

variable "provisioner_user" {
  type        = string
  description = "Remote user"
}

variable "private_key" {
  description = "Ssh private key connection"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "Github PAT named Teamcity External Github Feed used for Terraform Remote Module pulls"
  type        = string
  sensitive   = true
}