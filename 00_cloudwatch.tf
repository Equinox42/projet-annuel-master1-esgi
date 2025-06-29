resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent configuration"
  name        = "AmazonCloudWatch-agent-configuration"
  type        = "String"
  value       = file("cw_agent_config.json")
}