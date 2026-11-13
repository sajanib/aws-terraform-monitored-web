data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/${var.project_name}/nginx"
  retention_in_days = 7
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.web.name

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    project_name  = var.project_name
    log_group     = aws_cloudwatch_log_group.nginx.name
    metrics_space = "CWAgent"
  })
  user_data_replace_on_change = true

  # Require IMDSv2 (blocks SSRF-style metadata theft)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  monitoring = false

  tags = {
    Name = "${var.project_name}-web"
  }
}
