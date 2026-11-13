# No SSH: the instance is managed through AWS Systems Manager Session Manager,
# so port 22 stays closed and no key pair is needed.
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP in, all traffic out"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound (package installs, SSM, CloudWatch)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
