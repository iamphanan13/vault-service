packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.2.0"
    }
  }
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "golden-vault-ami-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "ap-southeast-1"

source_ami_filter {
  filters = {
    name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  owners      = ["099720109477"]
  most_recent = true
}

  tags = {
    Name = "Golden Standard AMI for Bastion Host"
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  // Install Dependencies
  provisioner "shell" {
    script = "scripts/standard-ami.sh"
  }

  
}