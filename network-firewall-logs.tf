locals {
  enable_networkfirewall_logs = var.create_vpc && var.enable_networkfirewall && var.enable_networkfirewall_logs
}

########################
# Network Firewall Logs
########################
resource "aws_networkfirewall_logging_configuration" "this" {
  count = var.enable_networkfirewall && local.enable_networkfirewall_logs && length(var.networkfirewall_log_types) > 0 ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.this[0].arn

  logging_configuration {
    dynamic "log_destination_config" {
      for_each = var.networkfirewall_log_types

      content {
        log_destination = {
          logGroup = aws_cloudwatch_log_group.networkfirewall_log[log_destination_config.key].id
        }
        log_destination_type = "CloudWatchLogs"
        log_type             = log_destination_config.value
      }
    }
  }
}

###################################
# Network Firewall Logs Cloudwatch
###################################
resource "aws_cloudwatch_log_group" "networkfirewall_log" {
  count = local.enable_networkfirewall_logs ? length(var.networkfirewall_log_types) : 0

  name              = "${var.networkfirewall_log_cloudwatch_log_group_name_prefix}${local.vpc_id}-${lower(element(var.networkfirewall_log_types, count.index))}"
  retention_in_days = var.networkfirewall_log_cloudwatch_log_group_retention_in_days
  kms_key_id        = var.networkfirewall_log_cloudwatch_log_group_kms_key_id

  tags = merge(var.tags, var.networkfirewall_log_tags)
}
