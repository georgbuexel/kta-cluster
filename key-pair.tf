#####################
## Key Pair - Main ##
#####################

# Generates a secure private key and encodes it as PEM
# resource "tls_private_key" "key_pair" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${lower(local.name_prefix)}-windows-${lower(var.aws_region)}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCWvQD8Vw/3JxPvRjJbBrs1o1leNAUMKspMmR2w9MD4esW+P4Qo0v9pp6uNStXKfTSKH4cmp7LJZOa0Gmxck0NQS4j7kmV39Vgv7sfflD447+xD8FRwUE7iAdzbOLNfJh/Rw319ik+XzLYbpHDh1kD+Y3h/mbXOdcGY7lAHD9vZRgBhA3i40WjFZdT9qrMhnbfsZ223z4jGCEde9RELc33625T9D4xOA4i7ncNIEBRW7s/6C1WCKg2/Rah7VJz4mBWPBV4LjlZJ5g7aAaWwY190x6v3VLQ4oJUE0uWtzUaaamEf6fTHjSglAXFZqxMS1gMUE9Ghk3k/dfrFmf3/wdKD1qVfYnFnb6bvmKFfGdQ/EAWT3tpPRyBRxEJuoc+ithh4pIdtWYDRMzsFjGgQnfBuq6/Dg4EQQNNMpWM7eF4WmmO5NR02epRCBlhN9XQoYnoqrhuXhMNcgum7Wl04GzIrK7XqlUcrYgjMwEtLb/LENGRhpXrnS30SbF5Jci2S6fY+rEelvEnx/+s9FGUjvsStjORRTCTJyMcKSEMA5JRUKPrUGCjbLRc2SU4ExX/b0ElVA1gp3DydzZN3/jNvBgf307F4/BukSmHlvZZdEDfGNEBNkqPVp5zExlQDYVDv60DH2cJ15My8+ZQu2zfrw1NXEtBJmRFoRIMHuyDyrH+M7w== admin@example.com"
  #  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file
# resource "local_file" "ssh_key" {
#   filename = "${aws_key_pair.key_pair.key_name}.pem"
#   content  = tls_private_key.key_pair.private_key_pem
# }
