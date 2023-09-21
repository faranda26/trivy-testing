resource "aws_ami_from_instance" "this" {
  lifecycle {
    create_before_destroy = true
  }
  name                    = var.name
  source_instance_id      = var.source_instance_id
  snapshot_without_reboot = var.snapshot_without_reboot
}