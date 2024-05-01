# Create DCR for AVD resources
resource "azurerm_monitor_data_collection_rule" "this" {
  location                    = var.monitor_data_collection_rule_location
  name                        = var.monitor_data_collection_rule_name
  resource_group_name         = var.monitor_data_collection_rule_resource_group_name
  data_collection_endpoint_id = var.monitor_data_collection_rule_data_collection_endpoint_id
  description                 = var.monitor_data_collection_rule_description
  kind                        = var.monitor_data_collection_rule_kind
  tags                        = var.monitor_data_collection_rule_tags

  dynamic "data_flow" {
    for_each = var.monitor_data_collection_rule_data_flow
    content {
      destinations       = data_flow.value.destinations
      streams            = data_flow.value.streams
      built_in_transform = data_flow.value.built_in_transform
      output_stream      = data_flow.value.output_stream
      transform_kql      = data_flow.value.transform_kql
    }
  }
  dynamic "destinations" {
    for_each = [var.monitor_data_collection_rule_destinations]
    content {
      dynamic "azure_monitor_metrics" {
        for_each = lookup(destinations.value, "azure_monitor_metrics", null) == null ? [] : [destinations.value.azure_monitor_metrics]
        content {
          name = azure_monitor_metrics.value.name
        }
      }
      dynamic "event_hub" {
        for_each = lookup(destinations.value, "event_hub", null) == null ? [] : [destinations.value.event_hub]
        content {
          event_hub_id = event_hub.value.event_hub_id
          name         = event_hub.value.name
        }
      }
      dynamic "event_hub_direct" {
        for_each = lookup(destinations.value, "event_hub_direct", null) == null ? [] : [destinations.value.event_hub_direct]
        content {
          event_hub_id = event_hub_direct.value.event_hub_id
          name         = event_hub_direct.value.name
        }
      }
      dynamic "log_analytics" {
        for_each = lookup(destinations.value, "log_analytics", null) == null ? [] : [destinations.value.log_analytics]
        content {
          name                  = log_analytics.value.name
          workspace_resource_id = log_analytics.value.workspace_resource_id
        }
      }
      dynamic "monitor_account" {
        for_each = lookup(destinations.value, "monitor_account", null) == null ? [] : [destinations.value.monitor_account]
        content {
          monitor_account_id = monitor_account.value.monitor_account_id
          name               = monitor_account.value.name
        }
      }
      dynamic "storage_blob" {
        for_each = lookup(destinations.value, "storage_blob", null) == null ? [] : [destinations.value.storage_blob]
        content {
          container_name     = storage_blob.value.container_name
          name               = storage_blob.value.name
          storage_account_id = storage_blob.value.storage_account_id
        }
      }
      dynamic "storage_blob_direct" {
        for_each = lookup(destinations.value, "storage_blob_direct", null) == null ? [] : [destinations.value.storage_blob_direct]
        content {
          container_name     = storage_blob_direct.value.container_name
          name               = storage_blob_direct.value.name
          storage_account_id = storage_blob_direct.value.storage_account_id
        }
      }
      dynamic "storage_table_direct" {
        for_each = lookup(destinations.value, "storage_table_direct", null) == null ? [] : [destinations.value.storage_table_direct]
        content {
          name               = storage_table_direct.value.name
          storage_account_id = storage_table_direct.value.storage_account_id
          table_name         = storage_table_direct.value.table_name
        }
      }
    }
  }
  dynamic "data_sources" {
    for_each = var.monitor_data_collection_rule_data_sources == null ? [] : [var.monitor_data_collection_rule_data_sources]
    content {
      dynamic "data_import" {
        for_each = data_sources.value.data_import == null ? [] : [data_sources.value.data_import]
        content {
          dynamic "event_hub_data_source" {
            for_each = data_import.value.event_hub_data_source
            content {
              name           = event_hub_data_source.value.name
              stream         = event_hub_data_source.value.stream
              consumer_group = event_hub_data_source.value.consumer_group
            }
          }
        }
      }
      dynamic "extension" {
        for_each = data_sources.value.extension == null ? [] : data_sources.value.extension
        content {
          extension_name     = extension.value.extension_name
          name               = extension.value.name
          streams            = extension.value.streams
          extension_json     = extension.value.extension_json
          input_data_sources = extension.value.input_data_sources
        }
      }
      dynamic "iis_log" {
        for_each = data_sources.value.iis_log == null ? [] : data_sources.value.iis_log
        content {
          name            = iis_log.value.name
          streams         = iis_log.value.streams
          log_directories = iis_log.value.log_directories
        }
      }
      dynamic "log_file" {
        for_each = data_sources.value.log_file == null ? [] : data_sources.value.log_file
        content {
          file_patterns = log_file.value.file_patterns
          format        = log_file.value.format
          name          = log_file.value.name
          streams       = log_file.value.streams

          dynamic "settings" {
            for_each = log_file.value.settings == null ? [] : [log_file.value.settings]
            content {
              dynamic "text" {
                for_each = [settings.value.text]
                content {
                  record_start_timestamp_format = text.value.record_start_timestamp_format
                }
              }
            }
          }
        }
      }
      dynamic "performance_counter" {
        for_each = data_sources.value.performance_counter == null ? [] : data_sources.value.performance_counter
        content {
          counter_specifiers            = performance_counter.value.counter_specifiers
          name                          = performance_counter.value.name
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
          streams                       = performance_counter.value.streams
        }
      }
      dynamic "platform_telemetry" {
        for_each = data_sources.value.platform_telemetry == null ? [] : data_sources.value.platform_telemetry
        content {
          name    = platform_telemetry.value.name
          streams = platform_telemetry.value.streams
        }
      }
      dynamic "prometheus_forwarder" {
        for_each = data_sources.value.prometheus_forwarder == null ? [] : data_sources.value.prometheus_forwarder
        content {
          name    = prometheus_forwarder.value.name
          streams = prometheus_forwarder.value.streams

          dynamic "label_include_filter" {
            for_each = prometheus_forwarder.value.label_include_filter == null ? [] : prometheus_forwarder.value.label_include_filter
            content {
              label = label_include_filter.value.label
              value = label_include_filter.value.value
            }
          }
        }
      }
      dynamic "syslog" {
        for_each = data_sources.value.syslog == null ? [] : data_sources.value.syslog
        content {
          facility_names = syslog.value.facility_names
          log_levels     = syslog.value.log_levels
          name           = syslog.value.name
          streams        = syslog.value.streams
        }
      }
      dynamic "windows_event_log" {
        for_each = data_sources.value.windows_event_log == null ? [] : data_sources.value.windows_event_log
        content {
          name           = windows_event_log.value.name
          streams        = windows_event_log.value.streams
          x_path_queries = windows_event_log.value.x_path_queries
        }
      }
      dynamic "windows_firewall_log" {
        for_each = data_sources.value.windows_firewall_log == null ? [] : data_sources.value.windows_firewall_log
        content {
          name    = windows_firewall_log.value.name
          streams = windows_firewall_log.value.streams
        }
      }
    }
  }
  dynamic "identity" {
    for_each = var.monitor_data_collection_rule_identity == null ? [] : [var.monitor_data_collection_rule_identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "stream_declaration" {
    for_each = var.monitor_data_collection_rule_stream_declaration == null ? [] : var.monitor_data_collection_rule_stream_declaration
    content {
      stream_name = stream_declaration.value.stream_name

      dynamic "column" {
        for_each = stream_declaration.value.column
        content {
          name = column.value.name
          type = column.value.type
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = var.monitor_data_collection_rule_timeouts == null ? [] : [var.monitor_data_collection_rule_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  target_resource_id      = var.target_resource_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
  description             = var.description
  name                    = var.name

  dynamic "timeouts" {
    for_each = var.monitor_data_collection_rule_association_timeouts == null ? {} : var.monitor_data_collection_rule_association_timeouts
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
