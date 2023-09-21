aws_instances = {
  dev = {
    devops_ubuntu_cloudprofile = {
      aws_ami_filter_name                            = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-*"],
      aws_ami_filter_owners                          = ["099720109477"], #canonical
      availability_zone                              = "",
      subnet_id                                      = "",
      device_name                                    = "/dev/sda1",
      block_device_iops                              = 5000,
      block_device_kms_key_id                        = "",
      block_device_volume_size                       = 100,
      block_device_volume_type                       = "io2",
      ebs_volume                                     = {}
      core_count                                     = 8,
      threads_per_core                               = 2,
      description                                    = "",
      ebs_optimized                                  = true,
      instance_market_options_spot_options_max_price = 0.3,
      instance_profile                               = "",
      instance_type                                  = "c5.4xlarge",
      vpc_security_group_id                          = "",
      instance_tags = {
        "Owner"      = "",
        "Department" = "DevOps",
        "CreatedBy"  = "CloudProfile"
      },
      provisioner_user = "ubuntu"
      tags = {
        "Owner"      = "",
        "Department" = "DevOps",
        "CreatedBy"  = "Terraform"
      },
      user_data_file = "user_data.sh"
    }
  }
}