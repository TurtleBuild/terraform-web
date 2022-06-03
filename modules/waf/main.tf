locals {
  # TODO edit ipset.csv
  ip_list = [for ip in csvdecode(file("${path.module}/ipset/${var.environment}/ipset.csv")) : "${ip.IP_Address}"]
}
resource "aws_waf_ipset" "main" {
  name = "${var.waf_name}-${var.environment}-waf-ipset"
  dynamic "ip_set_descriptors" {
    for_each = local.ip_list
    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }
}
resource "aws_waf_rule" "main" {
  name        = "${var.waf_name}-${var.environment}-waf-rule"
  metric_name = "Metric"
  predicates {
    negated = false
    data_id = aws_waf_ipset.main.id
    type    = "IPMatch"
  }
}
resource "aws_waf_web_acl" "main" {
  name        = "${var.waf_name}-${var.environment}-web-acl"
  metric_name = "Metric"
  default_action {
    type = "BLOCK"
  }
  rules {
    priority = 0
    action {
      type = "ALLOW"
    }
    rule_id = aws_waf_rule.main.id
  }
}
