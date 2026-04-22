data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "novasphere" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.novasphere.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-bastion"
    Role = "bastion"
  })
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.novasphere.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web"
    Role = "web"
  })
}

resource "aws_instance" "private_service" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.novasphere.key_name
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_service.id]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-service"
    Role = "internal"
  })
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    bastion_ip = aws_instance.bastion.public_ip
    web_ip     = aws_instance.web.public_ip
    ssh_user   = "ubuntu"
    ssh_key    = pathexpand(var.ssh_private_key_path)
  })

  filename = "${path.module}/../../ansible/inventory/hosts_generated.yml"
}