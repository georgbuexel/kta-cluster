##################################################################################
# DATA
##################################################################################

# Get Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250305"]
  }
}

# Get latest Windows Server 2019 AMI
data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}

# Get latest Windows Server 2022 AMI
data "aws_ami" "windows-2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

##################################################################################
# RESOURCES
##################################################################################

# # PASSWORD #
# resource "random_string" "admin_pwd" {
#   length  = 16
#   special = false
#   #special          = true
#   #override_special = "_+?!-"
# }

# INSTANCES #
# # Create Control Plane node
# resource "aws_instance" "control_plane_node" {
#   count         = var.control_plane_node_count
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.instance_type
#   subnet_id     = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
#   private_ip    = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 5)
#   source_dest_check = false

#   vpc_security_group_ids = [aws_security_group.control_plane_sg.id]
#   # user_data              = templatefile("${path.module}/startup_script.tpl", {})

# #   user_data = templatefile("${path.module}/startup_linux_script.tpl", {
# #     hostname = "c1-cp${count.index + 1}"
# #   })

#   tags = {
#     Name = "${local.name_prefix}-node-${count.index}"
#   }

# }

# # Create Linux worker nodes
# resource "aws_instance" "linux_worker_node" {
#   count         = var.linux_worker_node_count
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.instance_type
#   subnet_id     = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
#   private_ip    = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 128)
#   source_dest_check = false

#   vpc_security_group_ids = [aws_security_group.linux_node_sg.id]
#   # user_data              = templatefile("${path.module}/startup_script.tpl", {})

# #   user_data = templatefile("${path.module}/startup_linux_script.tpl", {
# #     hostname = "c1-lin-node${count.index + 1}"
# #   })

#   tags = {
#     Name = "${local.name_prefix}-lin-node-${count.index + 1}"
#   }

# }





# Create Windows license server
resource "aws_instance" "license_server" {
  count                  = var.license_server_count
  ami                    = data.aws_ami.windows-2022.id
  # instance_type          = var.instance_type
  # ami                    = data.aws_ami.windows-2019.id
  instance_type          = "t2.xlarge"
  network_interface {
    network_interface_id = aws_network_interface.lic_ser_eni.id
    device_index         = 0  # 0 is for the primary network interface
  }
  # subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
  # private_ip             = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 192)
  # vpc_security_group_ids = [aws_security_group.aws_windows_sg.id]
  # source_dest_check = false
  
  #  associate_public_ip_address = var.windows_associate_public_ip_address
  #  source_dest_check           = false
  key_name          = aws_key_pair.key_pair.key_name
  get_password_data = true
  # user_data         = templatefile("${path.module}/startup_windows_script.tpl", {})
  # user_data = templatefile("${path.module}/startup_windows_script.tpl", {
  #   hostname = "c1-win-node${count.index + 1}"
  #   configfile = file("./tmp/config")
  # })

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "license-server-${count.index + 1}"
  }

}

# Create Windows webapp server
resource "aws_instance" "webapp_server" {
  count                  = var.webapp_server_count
  ami                    = data.aws_ami.windows-2022.id
  # instance_type          = var.instance_type
  # ami                    = data.aws_ami.windows-2019.id
  instance_type          = "t2.xlarge"
  # network_interface {
  #   network_interface_id = aws_network_interface.lic_ser_eni.id
  #   device_index         = 0  # 0 is for the primary network interface
  # }
  subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
  private_ip             = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 197)
  vpc_security_group_ids = [aws_security_group.aws_windows_sg.id]
  source_dest_check = false
  
   associate_public_ip_address = var.windows_associate_public_ip_address
  #  source_dest_check           = false
  key_name          = aws_key_pair.key_pair.key_name
  get_password_data = true
  # user_data         = templatefile("${path.module}/startup_windows_script.tpl", {})
  # user_data = templatefile("${path.module}/startup_windows_script.tpl", {
  #   hostname = "c1-win-node${count.index + 1}"
  #   configfile = file("./tmp/config")
  # })

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "webapp-server-${count.index + 1}"
  }

}

resource "aws_eip_association" "webapp_eip_ass" {
  count = var.webapp_server_count > 0 ? 1 : 0  # Only associate if there's at least one instance 
  instance_id = aws_instance.webapp_server[0].id  # Associate the EIP with the EC2 instance
  allocation_id         = aws_eip.webapp_ser_eip.id  # Associate the EIP to the EC2 instance
}


# Create Windows transformation server
resource "aws_instance" "transformation_server" {
  count                  = var.transformation_server_count
  ami                    = data.aws_ami.windows-2022.id
  # instance_type          = var.instance_type
  # ami                    = data.aws_ami.windows-2019.id
  instance_type          = "t2.xlarge"
  # network_interface {
  #   network_interface_id = aws_network_interface.lic_ser_eni.id
  #   device_index         = 0  # 0 is for the primary network interface
  # }
  subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
  private_ip             = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 202)
  vpc_security_group_ids = [aws_security_group.aws_windows_sg.id]
  source_dest_check = false
  
   associate_public_ip_address = var.windows_associate_public_ip_address
  #  source_dest_check           = false
  key_name          = aws_key_pair.key_pair.key_name
  get_password_data = true
  # user_data         = templatefile("${path.module}/startup_windows_script.tpl", {})
  # user_data = templatefile("${path.module}/startup_windows_script.tpl", {
  #   hostname = "c1-win-node${count.index + 1}"
  #   configfile = file("./tmp/config")
  # })

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "transformation-server-${count.index + 1}"
  }

}
# Create Windows reporting server
resource "aws_instance" "reporting_server" {
  count                  = var.reporting_server_count
  ami                    = data.aws_ami.windows-2022.id
  # instance_type          = var.instance_type
  # ami                    = data.aws_ami.windows-2019.id
  instance_type          = "t2.xlarge"
  # network_interface {
  #   network_interface_id = aws_network_interface.lic_ser_eni.id
  #   device_index         = 0  # 0 is for the primary network interface
  # }
  subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
  private_ip             = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 207)
  vpc_security_group_ids = [aws_security_group.aws_windows_sg.id]
  source_dest_check = false
  
   associate_public_ip_address = var.windows_associate_public_ip_address
  #  source_dest_check           = false
  key_name          = aws_key_pair.key_pair.key_name
  get_password_data = true
  # user_data         = templatefile("${path.module}/startup_windows_script.tpl", {})
  # user_data = templatefile("${path.module}/startup_windows_script.tpl", {
  #   hostname = "c1-win-node${count.index + 1}"
  #   configfile = file("./tmp/config")
  # })

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "reporting-server-${count.index + 1}"
  }

}
# Create Windows integration server
resource "aws_instance" "integration_server" {
  count                  = var.integration_server_count
  ami                    = data.aws_ami.windows-2022.id
  # instance_type          = var.instance_type
  # ami                    = data.aws_ami.windows-2019.id
  instance_type          = "t2.xlarge"
  # network_interface {
  #   network_interface_id = aws_network_interface.lic_ser_eni.id
  #   device_index         = 0  # 0 is for the primary network interface
  # }
  subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].id
  private_ip             = cidrhost(aws_subnet.public_subnets[(count.index % var.vpc_subnets_count)].cidr_block, floor(count.index / var.vpc_subnets_count) + 212)
  vpc_security_group_ids = [aws_security_group.aws_windows_sg.id]
  source_dest_check = false
  
   associate_public_ip_address = var.windows_associate_public_ip_address
  #  source_dest_check           = false
  key_name          = aws_key_pair.key_pair.key_name
  get_password_data = true
  # user_data         = templatefile("${path.module}/startup_windows_script.tpl", {})
  # user_data = templatefile("${path.module}/startup_windows_script.tpl", {
  #   hostname = "c1-win-node${count.index + 1}"
  #   configfile = file("./tmp/config")
  # })

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "integration-server-${count.index + 1}"
  }

}
