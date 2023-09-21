variable "name" {
  description = "(Required) Region-unique name for the AMI"
  type        = string
}

variable "source_instance_id" {
  description = "(Required) ID of the instance to use as the basis of the AMI"
  type        = string
}

variable "snapshot_without_reboot" {
  description = "(Optional) Boolean that overrides the behavior of stopping the instance before snapshotting."
  default     = false
  type        = bool
}
