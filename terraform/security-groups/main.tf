# Security Group:
resource "aws_security_group" "jenkins_server" {
  name        = "jenkins_server"
  description = "Jenkins Server: created by Terraform for ann_jekins"

  # legacy name of VPC ID
  vpc_id = data.aws_vpc.default_vpc.id

  tags = {
    Name = "jenkins_server"
    env  = "dev"
  }

}

# ssh
resource "aws_security_group_rule" "jenkins_server_from_source_ingress_ssh" {
  type              = "ingress"
  from_port         = var.server_tcp
  to_port           = var.server_tcp
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_server.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ssh to jenkins_server"
}


# web
resource "aws_security_group_rule" "jenkins_server_from_source_ingress_webui" {
  type              = "ingress"
  from_port         = var.server_web
  to_port           = var.server_web
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_server.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "jenkins web server"
}


// Outgoing Connections


resource "aws_security_group_rule" "jenkins_server_to_other_machines_ssh" {
  type              = "egress"
  from_port         = var.server_tcp
  to_port           = var.server_tcp
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_server.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers to ssh to other machines"
}

resource "aws_security_group_rule" "jenkins_server_outbound_all_80" {
  type              = "egress"
  from_port         = var.server_http
  to_port           = var.server_http
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_server.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}

resource "aws_security_group_rule" "jenkins_server_outbound_all_443" {
  type              = "egress"
  from_port         = var.server_https
  to_port           = var.server_https
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_server.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow jenkins servers for outbound yum"
}
