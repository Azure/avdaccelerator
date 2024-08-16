variable "monitor_data_collection_rule_association_target_resource_id" {
  type        = string
  description = "(Required) The ID of the Azure Resource which to associate to a Data Collection Rule or a Data Collection Endpoint. Changing this forces a new resource to be created."
  nullable    = false
}

variable "monitor_data_collection_rule_data_flow" {
  type = list(object({
    built_in_transform = optional(string)
    destinations       = list(string)
    output_stream      = optional(string)
    streams            = list(string)
    transform_kql      = optional(string)
  }))
  description = <<-EOT
 - `built_in_transform` - (Optional) The built-in transform to transform stream data.
 - `destinations` - (Required) Specifies a list of destination names. A `azure_monitor_metrics` data source only allows for stream of kind `Microsoft-InsightsMetrics`.
 - `output_stream` - (Optional) The output stream of the transform. Only required if the data flow changes data to a different stream.
 - `streams` - (Required) Specifies a list of streams. Possible values include but not limited to `Microsoft-Event`, `Microsoft-InsightsMetrics`, `Microsoft-Perf`, `Microsoft-Syslog`, `Microsoft-WindowsEvent`, and `Microsoft-PrometheusMetrics`.
 - `transform_kql` - (Optional) The KQL query to transform stream data.
EOT
  nullable    = false
}

variable "monitor_data_collection_rule_destinations" {
  type = object({
    azure_monitor_metrics = optional(object({
      name = string
    }))
    event_hub = optional(object({
      event_hub_id = string
      name         = string
    }))
    event_hub_direct = optional(object({
      event_hub_id = string
      name         = string
    }))
    log_analytics = optional(object({
      name                  = string
      workspace_resource_id = string
    }))
    monitor_account = optional(list(object({
      monitor_account_id = string
      name               = string
    })))
    storage_blob = optional(list(object({
      container_name     = string
      name               = string
      storage_account_id = string
    })))
    storage_blob_direct = optional(list(object({
      container_name     = string
      name               = string
      storage_account_id = string
    })))
    storage_table_direct = optional(list(object({
      name               = string
      storage_account_id = string
      table_name         = string
    })))
  })
  description = <<-EOT

 ---
 `azure_monitor_metrics` block supports the following:
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.

 ---
 `event_hub` block supports the following:
 - `event_hub_id` - (Required) The resource ID of the Event Hub.
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.

 ---
 `event_hub_direct` block supports the following:
 - `event_hub_id` - (Required) The resource ID of the Event Hub.
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.

 ---
 `log_analytics` block supports the following:
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.
 - `workspace_resource_id` - (Required) The ID of a Log Analytic Workspace resource.

 ---
 `monitor_account` block supports the following:
 - `monitor_account_id` - (Required) The resource ID of the Monitor Account.
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.

 ---
 `storage_blob` block supports the following:
 - `container_name` - (Required) The Storage Container name.
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.
 - `storage_account_id` - (Required) The resource ID of the Storage Account.

 ---
 `storage_blob_direct` block supports the following:
 - `container_name` - (Required) The Storage Container name.
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.
 - `storage_account_id` - (Required) The resource ID of the Storage Account.

 ---
 `storage_table_direct` block supports the following:
 - `name` - (Required) The name which should be used for this destination. This name should be unique across all destinations regardless of type within the Data Collection Rule.
 - `storage_account_id` - (Required) The resource ID of the Storage Account.
 - `table_name` - (Required) The Storage Table name.
EOT
  nullable    = false
}

variable "monitor_data_collection_rule_location" {
  type        = string
  description = "(Required) The Azure Region where the Data Collection Rule should exist. Changing this forces a new Data Collection Rule to be created."
  nullable    = false
}

variable "monitor_data_collection_rule_name" {
  type        = string
  description = "(Required) The name which should be used for this Data Collection Rule. Changing this forces a new Data Collection Rule to be created."
  nullable    = false
}

variable "monitor_data_collection_rule_resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group where the Data Collection Rule should exist. Changing this forces a new Data Collection Rule to be created."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."

  validation {
    condition     = can(regex("^[a-z0-9-]{5,50}$", var.name))
    error_message = "The name must be between 5 and 50 characters long and can only contain lowercase letters, numbers and dashes."
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "target_resource_id" {
  type        = string
  description = "(Required) The ID of the Azure Resource which to associate to a Data Collection Rule or a Data Collection Endpoint. Changing this forces a new resource to be created."
  nullable    = false
}

variable "create_workspace" {
  type        = bool
  default     = true
  description = "Whether to create a new Log Analytics workspace"
}

variable "description" {
  type        = string
  default     = null
  description = "(Optional) The description of the Data Collection Rule Association."
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:
  
  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
}

variable "monitor_data_collection_rule_association_data_collection_endpoint_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Data Collection Endpoint which will be associated to the target resource."
}

variable "monitor_data_collection_rule_association_data_collection_rule_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Data Collection Rule which will be associated to the target resource."
}

variable "monitor_data_collection_rule_association_description" {
  type        = string
  default     = null
  description = "(Optional) The description of the Data Collection Rule Association."
}

variable "monitor_data_collection_rule_association_name" {
  type        = string
  default     = null
  description = "(Optional) The name which should be used for this Data Collection Rule Association. Changing this forces a new Data Collection Rule Association to be created. Defaults to `configurationAccessEndpoint`."
}

variable "monitor_data_collection_rule_association_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Data Collection Rule Association.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Data Collection Rule Association.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Data Collection Rule Association.
 - `update` - (Defaults to 30 minutes) Used when updating the Data Collection Rule Association.
EOT
}

variable "monitor_data_collection_rule_data_collection_endpoint_id" {
  type        = string
  default     = null
  description = "(Optional) The resource ID of the Data Collection Endpoint that this rule can be used with."
}

variable "monitor_data_collection_rule_data_sources" {
  type = object({
    data_import = optional(object({
      event_hub_data_source = list(object({
        consumer_group = optional(string)
        name           = string
        stream         = string
      }))
    }))
    extension = optional(list(object({
      extension_json     = optional(string)
      extension_name     = string
      input_data_sources = optional(list(string))
      name               = string
      streams            = list(string)
    })))
    iis_log = optional(list(object({
      log_directories = optional(list(string))
      name            = string
      streams         = list(string)
    })))
    log_file = optional(list(object({
      file_patterns = list(string)
      format        = string
      name          = string
      streams       = list(string)
      settings = optional(object({
        text = object({
          record_start_timestamp_format = string
        })
      }))
    })))
    performance_counter = optional(list(object({
      counter_specifiers            = list(string)
      name                          = string
      sampling_frequency_in_seconds = number
      streams                       = list(string)
    })))
    platform_telemetry = optional(list(object({
      name    = string
      streams = list(string)
    })))
    prometheus_forwarder = optional(list(object({
      name    = string
      streams = list(string)
      label_include_filter = optional(set(object({
        label = string
        value = string
      })))
    })))
    syslog = optional(list(object({
      facility_names = list(string)
      log_levels     = list(string)
      name           = string
      streams        = optional(list(string))
    })))
    windows_event_log = optional(list(object({
      name           = string
      streams        = list(string)
      x_path_queries = list(string)
    })))
    windows_firewall_log = optional(list(object({
      name    = string
      streams = list(string)
    })))
  })
  default     = null
  description = <<-EOT

 ---
 `data_import` block supports the following:

 ---
 `event_hub_data_source` block supports the following:
 - `consumer_group` - (Optional) The Event Hub consumer group name.
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `stream` - (Required) The stream to collect from Event Hub. Possible value should be a custom stream name.

 ---
 `extension` block supports the following:
 - `extension_json` - (Optional) A JSON String which specifies the extension setting.
 - `extension_name` - (Required) The name of the VM extension.
 - `input_data_sources` - (Optional) Specifies a list of data sources this extension needs data from. An item should be a name of a supported data source which produces only one stream. Supported data sources type: `performance_counter`, `windows_event_log`,and `syslog`.
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible values include but not limited to `Microsoft-Event`, `Microsoft-InsightsMetrics`, `Microsoft-Perf`, `Microsoft-Syslog`, `Microsoft-WindowsEvent`.

 ---
 `iis_log` block supports the following:
 - `log_directories` - (Optional) Specifies a list of absolute paths where the log files are located.
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible value is `Microsoft-W3CIISLog`.

 ---
 `log_file` block supports the following:
 - `file_patterns` - (Required) Specifies a list of file patterns where the log files are located. For example, `C:\\JavaLogs\\*.log`.
 - `format` - (Required) The data format of the log files. possible value is `text`.
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible value should be custom stream names.

 ---
 `settings` block supports the following:

 ---
 `text` block supports the following:
 - `record_start_timestamp_format` - 

 ---
 `performance_counter` block supports the following:
 - `counter_specifiers` - (Required) Specifies a list of specifier names of the performance counters you want to collect. To get a list of performance counters on Windows, run the command `typeperf`. Please see [this document](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-sources-performance-counters#configure-performance-counters) for more information.
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `sampling_frequency_in_seconds` - (Required) The number of seconds between consecutive counter measurements (samples). The value should be integer between `1` and `300` inclusive. `sampling_frequency_in_seconds` must be equal to `60` seconds for counters collected with `Microsoft-InsightsMetrics` stream.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible values include but not limited to `Microsoft-InsightsMetrics`,and `Microsoft-Perf`.

 ---
 `platform_telemetry` block supports the following:
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible values include but not limited to `Microsoft.Cache/redis:Metrics-Group-All`.

 ---
 `prometheus_forwarder` block supports the following:
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible value is `Microsoft-PrometheusMetrics`.

 ---
 `label_include_filter` block supports the following:
 - `label` - (Required) The label of the filter. This label should be unique across all `label_include_fileter` block. Possible value is `microsoft_metrics_include_label`.
 - `value` - (Required) The value of the filter.

 ---
 `syslog` block supports the following:
 - `facility_names` - (Required) Specifies a list of facility names. Use a wildcard `*` to collect logs for all facility names. Possible values are `auth`, `authpriv`, `cron`, `daemon`, `kern`, `lpr`, `mail`, `mark`, `news`, `syslog`, `user`, `uucp`, `local0`, `local1`, `local2`, `local3`, `local4`, `local5`, `local6`, `local7`,and `*`.
 - `log_levels` - (Required) Specifies a list of log levels. Use a wildcard `*` to collect logs for all log levels. Possible values are `Debug`, `Info`, `Notice`, `Warning`, `Error`, `Critical`, `Alert`, `Emergency`,and `*`.
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Optional) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible values include but not limited to `Microsoft-Syslog`,and `Microsoft-CiscoAsa`, and `Microsoft-CommonSecurityLog`.

 ---
 `windows_event_log` block supports the following:
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to. Possible values include but not limited to `Microsoft-Event`,and `Microsoft-WindowsEvent`, `Microsoft-RomeDetectionEvent`, and `Microsoft-SecurityEvent`.
 - `x_path_queries` - (Required) Specifies a list of Windows Event Log queries in XPath expression. Please see [this document](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent?tabs=cli#filter-events-using-xpath-queries) for more information.

 ---
 `windows_firewall_log` block supports the following:
 - `name` - (Required) The name which should be used for this data source. This name should be unique across all data sources regardless of type within the Data Collection Rule.
 - `streams` - (Required) Specifies a list of streams that this data source will be sent to. A stream indicates what schema will be used for this data and usually what table in Log Analytics the data will be sent to.
EOT
}

variable "monitor_data_collection_rule_description" {
  type        = string
  default     = null
  description = "(Optional) The description of the Data Collection Rule."
}

variable "monitor_data_collection_rule_identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-EOT
 - `identity_ids` - (Optional) A list of User Assigned Managed Identity IDs to be assigned to this Data Collection Rule. Currently, up to 1 identity is supported.
 - `type` - (Required) Specifies the type of Managed Service Identity that should be configured on this Data Collection Rule. Possible values are `SystemAssigned` and `UserAssigned`.
EOT
}

variable "monitor_data_collection_rule_kind" {
  type        = string
  default     = null
  description = "(Optional) The kind of the Data Collection Rule. Possible values are `Linux`, `Windows`, `AgentDirectToStore` and `WorkspaceTransforms`. A rule of kind `Linux` does not allow for `windows_event_log` data sources. And a rule of kind `Windows` does not allow for `syslog` data sources. If kind is not specified, all kinds of data sources are allowed."
}

variable "monitor_data_collection_rule_stream_declaration" {
  type = set(object({
    stream_name = string
    column = list(object({
      name = string
      type = string
    }))
  }))
  default     = null
  description = <<-EOT
 - `stream_name` - (Required) The name of the custom stream. This name should be unique across all `stream_declaration` blocks.

 ---
 `column` block supports the following:
 - `name` - (Required) The name of the column.
 - `type` - (Required) The type of the column data. Possible values are `string`, `int`, `long`, `real`, `boolean`, `datetime`,and `dynamic`.
EOT
}

variable "monitor_data_collection_rule_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to the Data Collection Rule."
}

variable "monitor_data_collection_rule_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Data Collection Rule.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Data Collection Rule.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Data Collection Rule.
 - `update` - (Defaults to 30 minutes) Used when updating the Data Collection Rule.
EOT
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - The description of the role assignment.
  - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - The condition which will be used to scope the role assignment.
  - `condition_version` - The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  
  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
