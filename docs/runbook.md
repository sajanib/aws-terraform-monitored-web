# Runbook: monitored-web

Every alarm emails the SNS topic and links to a section below. Open a shell with
`terraform output -raw ssm_session_command` (no SSH key needed).

## cpu-high

**Meaning:** average CPU above the threshold for 10 minutes.

1. Check the dashboard (`terraform output dashboard_url`): is it a spike or sustained?
2. On the instance: `top -o %CPU` or `ps aux --sort=-%cpu | head` to find the process.
3. If it is a known job (e.g. the incident drill), let it finish and confirm the OK email.
4. If nginx: check request volume in the `/monitored-web/nginx` log group (CloudWatch Logs Insights:
   `stats count() by bin(1m)`).
5. Mitigate: stop the runaway process, or scale up `instance_type` and `terraform apply`.
6. Record what happened using `docs/postmortem-template.md`.

## status-check-failed

**Meaning:** EC2 system or instance status check failing for 2 minutes.

1. Console: EC2 > Instances > Status checks. System check = AWS host; instance check = OS.
2. Instance check failing: get the system log (`aws ec2 get-console-output --instance-id <id>`).
3. Try a reboot. If it persists, stop/start (moves to new hardware) or `terraform apply -replace=aws_instance.web`.

## memory-high

**Meaning:** memory used above the threshold for 10 minutes (CloudWatch agent metric).

1. `free -m` and `ps aux --sort=-%mem | head`.
2. Check for leaks or too many nginx workers; restart the service if safe: `sudo systemctl restart nginx`.
3. Longer term: right-size the instance.

## disk-high

**Meaning:** root volume above the threshold.

1. `df -h /` then `sudo du -xh / --max-depth=2 | sort -h | tail`.
2. Usual culprits: `/var/log`, package cache (`sudo dnf clean all`), old journals (`sudo journalctl --vacuum-time=3d`).
3. Longer term: log rotation, or increase `volume_size` and apply.

## No metrics for memory/disk

The CloudWatch agent is not running. `sudo systemctl status amazon-cloudwatch-agent` and check
`/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log`.
