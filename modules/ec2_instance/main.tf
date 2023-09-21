data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = var.aws_ami_filter_name_values
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = var.aws_ami_owners
}

resource "aws_instance" "ec2_cloud_profiles" {
  ami = data.aws_ami.ubuntu.id

  cpu_options {
    core_count       = try(var.cpu_options_core_count, null)
    threads_per_core = try(var.cpu_options_threads_per_core, null)
  }
  get_password_data = length(regexall("windows", var.name)) > 0 ? true : false
  key_name          = var.key_name
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = try(var.root_block_device_iops, null)
    kms_key_id            = var.root_block_device_kms_key_id
    volume_size           = var.root_block_device_volume_size
    volume_type           = var.root_block_device_volume_type
  }
  iam_instance_profile = var.iam_instance_profile

  private_dns_name_options {
    enable_resource_name_dns_a_record    = var.private_dns_name_options_enable_resource_name_dns_a_record
    enable_resource_name_dns_aaaa_record = var.private_dns_name_options_enable_resource_name_dns_aaaa_record
  }

  availability_zone                    = try(var.availability_zone, null)
  monitoring                           = try(var.monitoring, null)
  ebs_optimized                        = try(var.ebs_optimized, null)
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = var.instance_type
  subnet_id                            = var.subnet_id
  vpc_security_group_ids               = var.vpc_security_group_ids

  provisioner "remote-exec" {
    connection {
      type            = "ssh"
      user            = var.provisioner_user
      password        = aws_instance.ec2_cloud_profiles.get_password_data ? rsadecrypt(aws_instance.ec2_cloud_profiles.password_data, var.private_key) : null
      host            = aws_instance.ec2_cloud_profiles.private_ip
      insecure        = true
      private_key     = length(regexall("windows", var.name)) > 0 ? null : var.private_key
      target_platform = length(regexall("windows", var.name)) > 0 ? "windows" : "unix"
      timeout         = "10m"
    }
    ## IF computer name contains windows
    inline = length(regexall("windows", var.name)) > 0 ? [
      "powershell.exe while (-not (Test-Path \"C:\\Users\\Administrator\\user-data-status.txt\")) { Start-Sleep -Seconds 6;};",
      "C:\\\"Program Files\"\\Git\\mingw64\\bin\\git config --global url.\"https://oauth2:${var.github_token}@github.com\".insteadOf https://github.com"
      ] : [
      # else
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done;",
      "sudo -u devops sh -c 'git config --global url.\"https://oauth2:${var.github_token}@github.com\".insteadOf https://github.com'"
    ]
  }

  user_data = filebase64(var.user_data_file)
  user_data_replace_on_change = true
  tags = merge({
    Name = var.name
    },
    var.tags
  )
}

resource "aws_ec2_instance_state" "stop_instance" {
  instance_id = aws_instance.ec2_cloud_profiles.id
  state       = "stopped"
}