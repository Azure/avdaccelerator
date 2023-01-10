locals {
  kv_name = lower("kv-avd-${var.prefix}-${random_string.random.id}")
  allow_list_ip      = var.allow_list_ip
}