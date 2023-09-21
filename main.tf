provider "aws" {
  region = "us-east-1"  # Cambia esto a tu región AWS deseada
}

terraform {
  required_version = ">=0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.6"
    }
  }
}

locals {
  env_name = lower(terraform.workspace)
}

# Crear una VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Crear dos subnets en la VPC
resource "aws_subnet" "example_subnet_1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "example_subnet_2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Crear un grupo de seguridad
resource "aws_security_group" "example_security_group" {
  name        = "example-security-group"
  description = "Example security group"
  vpc_id      = aws_vpc.example_vpc.id

  # Regla de entrada para permitir el tráfico SSH desde cualquier IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Crear una instancia EC2 en cada subnet y asignarles el grupo de seguridad
resource "aws_instance" "example_instance_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # ID de imagen de Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet_1.id
  security_groups = [aws_security_group.example_security_group.name]
}

resource "aws_instance" "example_instance_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # ID de imagen de Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet_2.id
  security_groups = [aws_security_group.example_security_group.name]
}

# Crear un balanceador de carga
resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.example_subnet_1.id, aws_subnet.example_subnet_2.id]

  enable_deletion_protection = false
}

# Crear una base de datos RDS
resource "aws_db_instance" "example_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.example_security_group.id]
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "DevOps_cloudprofiles_kp_${local.env_name}"
  public_key = tls_private_key.pk.public_key_openssh
}

module "ami_from_instance" {
  source                  = "./modules/ami_from_instance"
  for_each                = var.aws_instances[local.env_name]
  source_instance_id      = module.aws_instance[each.key].id
  snapshot_without_reboot = true
  name                    = "${each.key}-${module.aws_instance[each.key].id}"
  depends_on              = [module.aws_instance]
}

module "aws_instance" {
  source                                         = "./modules/ec2_instance"
  for_each                                       = var.aws_instances[local.env_name]
  aws_ami_filter_name_values                     = each.value.aws_ami_filter_name
  aws_ami_owners                                 = each.value.aws_ami_filter_owners
  availability_zone                              = each.value.availability_zone
  instance_type                                  = each.value.instance_type
  iam_instance_profile                           = each.value.instance_profile
  ebs_optimized                                  = each.value.ebs_optimized
  cpu_options_core_count                         = each.value.core_count
  cpu_options_threads_per_core                   = each.value.threads_per_core
  root_block_device_iops                         = each.value.block_device_iops
  root_block_device_kms_key_id                   = each.value.block_device_kms_key_id
  root_block_device_volume_size                  = each.value.block_device_volume_size
  root_block_device_volume_type                  = each.value.block_device_volume_type
  key_name                                       = aws_key_pair.kp.key_name
  name                                           = each.key
  private_key                                    = tls_private_key.pk.private_key_pem
  provisioner_user                               = each.value.provisioner_user
  github_token                                   = var.github_token
  instance_market_options_spot_options_max_price = each.value.instance_market_options_spot_options_max_price
  subnet_id                                      = each.value.subnet_id
  vpc_security_group_ids                         = [each.value.vpc_security_group_id]
  user_data_file                                 = each.value.user_data_file
  tags                                           = var.tags[local.env_name]
}