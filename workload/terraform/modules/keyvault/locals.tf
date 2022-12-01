locals {
kv_name = lower("kv-avd-${var.prefix}-${random_string.random.id}")
}