# Get aws ami

data "aws_ami" "jenkins_server" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["amazon-linux-for-jenkins*"]
  }

}



data "aws_security_group" "jenkins_server" {
  filter {
    name   = "group-name"
    values = ["jenkins_server*"]
  }
}



# the Jenkins server itself
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.jenkins_server.image_id
  instance_type          = "t2.small"
  key_name               = "ann_jenkins"
  subnet_id              = tolist(data.aws_subnet_ids.default_public.ids)[0]
  vpc_security_group_ids = [data.aws_security_group.jenkins_server.id]
  iam_instance_profile   = "jenkins_server"

  provisioner "file" {
    source      = "scripts/setup_jenkins.sh"
    destination = "/tmp/setup_jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_jenkins.sh",
      "sudo /tmp/setup_jenkins.sh ${var.jenkins_admin_password}"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("ann_jenkins.pem")
  }

  tags = {
    "Name" = "jenkins_server"
  }

  root_block_device {
    delete_on_termination = true
  }
}
