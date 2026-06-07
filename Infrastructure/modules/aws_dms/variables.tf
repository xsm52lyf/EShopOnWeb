    variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "replication_instance_class" {
  description = "Instance class for DMS replication instance."
  type        = string
  default     = "dms.r5.xlarge"
}

variable "replication_instance_id" {
  description = "Identifier for the DMS replication instance."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB for the replication instance."
  type        = number
  default     = 100
}

variable "engine_version" {
  description = "DMS engine version."
  type        = string
  default     = "3.5.2"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for the replication instance."
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DMS subnet group (must be in different AZs)."
  type        = list(string)
}

variable "multi_az" {
  description = "Enable Multi-AZ for the replication instance."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Whether the replication instance is publicly accessible."
  type        = bool
  default     = false
}

variable "preferred_maintenance_window" {
  description = "Weekly maintenance window."
  type        = string
  default     = "sun:03:00-sun:05:00"
}

variable "source_endpoint_id" {
  description = "Identifier for the source endpoint."
  type        = string
  default     = "corecommerce-source-rds"
}

variable "source_engine_name" {
  description = "Source database engine."
  type        = string
  default     = "postgres"
}

variable "source_server_name" {
  description = "Source RDS endpoint address."
  type        = string
}

variable "source_port" {
  description = "Source database port."
  type        = number
  default     = 5432
}

variable "source_username" {
  description = "Source database username (must have replication privileges)."
  type        = string
}

variable "source_password" {
  description = "Source database password (fetched from Secrets Manager)."
  type        = string
  sensitive   = true
}

variable "source_database_name" {
  description = "Source database name."
  type        = string
}

variable "source_ssl_mode" {
  description = "SSL mode for source connection."
  type        = string
  default     = "require"
}

variable "target_endpoint_id" {
  description = "Identifier for the target endpoint."
  type        = string
  default     = "corecommerce-target-azure-psql"
}

variable "target_engine_name" {
  description = "Target database engine."
  type        = string
  default     = "postgres"
}

variable "target_server_name" {
  description = "Target Azure PostgreSQL server FQDN."
  type        = string
}

variable "target_port" {
  description = "Target database port."
  type        = number
  default     = 5432
}

variable "target_username" {
  description = "Target database admin username."
  type        = string
}

variable "target_password" {
  description = "Target database admin password."
  type        = string
  sensitive   = true
}

variable "target_database_name" {
  description = "Target database name."
  type        = string
}

variable "target_ssl_mode" {
  description = "SSL mode for target connection."
  type        = string
  default     = "require"
}

variable "replication_task_id" {
  description = "Identifier for the replication task."
  type        = string
  default     = "corecommerce-cdc-task"
}

variable "migration_type" {
  description = "Migration type: full-load, cdc, or full-load-and-cdc."
  type        = string
  default     = "full-load-and-cdc"
}

variable "table_mappings" {
  description = "JSON table mapping rules for DMS."
  type        = string
  default     = <<-JSON
{
  "rules": [
    {
      "rule-type": "selection",
      "rule-id": "1",
      "rule-name": "select-all",
      "object-locator": {
        "schema-name": "%",
        "table-name": "%"
      },
      "rule-action": "include",
      "filters": []
    },
    {
      "rule-type": "transformation",
      "rule-id": "2",
      "rule-name": "convert-to-lowercase",
      "rule-action": "convert-lowercase",
      "rule-target": "schema",
      "object-locator": {
        "schema-name": "%"
      }
    },
    {
      "rule-type": "transformation",
      "rule-id": "3",
      "rule-name": "convert-to-lowercase-table",
      "rule-action": "convert-lowercase",
      "rule-target": "table",
      "object-locator": {
        "schema-name": "%",
        "table-name": "%"
      }
    }
  ]
}
JSON
}

variable "replication_task_settings" {
  description = "JSON task settings for the replication task."
  type        = string
  default     = <<-JSON
{
  "TargetMetadata": {
    "TargetSchema": "",
    "SupportLobs": true,
    "FullLobMode": false,
    "LobChunkSize": 64,
    "LimitedSizeLobMode": true,
    "LobMaxSize": 32,
    "InlineLobMaxSize": 0,
    "LoadMaxFileSize": 0,
    "ParallelLoadThreads": 0,
    "ParallelLoadBufferSize": 0,
    "BatchApplyEnabled": false,
    "TaskRecoveryTableEnabled": false,
    "ParallelLoadQueuesPerThread": 0,
    "ParallelApplyThreads": 0,
    "ParallelApplyBufferSize": 0
  },
  "FullLoadSettings": {
    "TargetTablePrepMode": "DROP_AND_CREATE",
    "CreatePkAfterFullLoad": false,
    "StopTaskCachedChangesApplied": false,
    "StopTaskCachedChangesNotApplied": false,
    "MaxFullLoadSubTasks": 8,
    "TransactionConsistencyTimeout": 600,
    "CommitRate": 10000
  },
  "Logging": {
    "EnableLogging": true,
    "LogComponents": [
      {
        "Id": "TRANSFORMATION",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "SOURCE_UNLOAD",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "IO",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "TARGET_LOAD",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "PERFORMANCE",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      }
    ]
  },
  "ControlTablesSettings": {
    "ControlSchema": "",
    "HistoryTimeslotInMinutes": 5,
    "HistoryTableEnabled": true,
    "SuspendedTablesTableEnabled": true,
    "StatusTableEnabled": true
  },
  "StreamBufferSettings": {
    "StreamBufferCount": 3,
    "StreamBufferSizeInMB": 8,
    "CtrlStreamBufferSizeInMB": 5
  },
  "ChangeProcessingDdlHandlingPolicy": {
    "HandleSourceTableDropped": true,
    "HandleSourceTableTruncated": true,
    "HandleSourceTableAltered": true
  },
  "ChangeProcessingTuning": {
    "BatchApplyPreserveTransaction": true,
    "BatchApplyTimeoutMin": 1,
    "BatchApplyTimeoutMax": 30,
    "BatchApplyMemoryLimit": 500,
    "BatchSplitSize": 0,
    "MinTransactionSize": 1000,
    "CommitTimeout": 1,
    "MemoryLimitTotal": 1024,
    "MemoryKeepTime": 60,
    "StatementCacheSize": 50
  },
  "ErrorBehavior": {
    "DataErrorPolicy": "LOG_ERROR",
    "DataTruncationErrorPolicy": "LOG_ERROR",
    "DataErrorEscalationPolicy": "SUSPEND_TABLE",
    "DataErrorEscalationCount": 50,
    "TableErrorPolicy": "SUSPEND_TABLE",
    "TableErrorEscalationPolicy": "STOP_TASK",
    "TableErrorEscalationCount": 50,
    "RecoverableErrorCount": -1,
    "RecoverableErrorInterval": 5,
    "RecoverableErrorThrottling": true,
    "RecoverableErrorThrottlingMax": 1800,
    "ApplyErrorDeletePolicy": "IGNORE_RECORD",
    "ApplyErrorInsertPolicy": "LOG_ERROR",
    "ApplyErrorUpdatePolicy": "LOG_ERROR",
    "ApplyErrorEscalationPolicy": "LOG_ERROR",
    "ApplyErrorEscalationCount": 0,
    "FullLoadIgnoreConflicts": true
  },
  "ValidationSettings": {
    "EnableValidation": true,
    "ValidationMode": "ROW_LEVEL",
    "ThreadCount": 5,
    "PartitionSize": 10000,
    "FailureMaxCount": 1000,
    "TableFailureMaxCount": 1000,
    "SkipLobValidation": false,
    "HandleCollationDiff": true,
    "ValidationOnly": false,
    "RecordFailureDelayInMinutes": 5,
    "RecordSuspendDelayInMinutes": 30
  }
}
JSON
}

variable "cdc_start_position" {
  description = "CDC start position (optional). Leave empty for full-load-and-cdc."
  type        = string
  default     = null
}

variable "cdc_stop_position" {
  description = "CDC stop position (optional). Leave empty for continuous replication."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags for all resources."
  type        = map(string)
  default     = {}
}