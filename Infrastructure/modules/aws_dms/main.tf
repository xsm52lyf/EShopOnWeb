terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id          = "${var.replication_instance_id}-subnet-group"
  replication_subnet_group_description = "DMS subnet group for CoreCommerce DR replication"
  subnet_ids                           = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.replication_instance_id}-subnet-group"
  })
}

resource "aws_dms_replication_instance" "main" {
  replication_instance_id     = var.replication_instance_id
  replication_instance_class  = var.replication_instance_class
  allocated_storage           = var.allocated_storage
  engine_version              = var.engine_version
  multi_az                    = var.multi_az
  publicly_accessible         = var.publicly_accessible
  replication_subnet_group_id = aws_dms_replication_subnet_group.main.id
  vpc_security_group_ids      = var.vpc_security_group_ids
  preferred_maintenance_window = var.preferred_maintenance_window
  auto_minor_version_upgrade  = true
  apply_immediately           = false

  tags = merge(var.tags, {
    Name = var.replication_instance_id
  })
}

resource "aws_dms_endpoint" "source" {
  endpoint_id                 = var.source_endpoint_id
  endpoint_type               = "source"
  engine_name                 = var.source_engine_name
  server_name                 = var.source_server_name
  port                        = var.source_port
  username                    = var.source_username
  password                    = var.source_password
  database_name               = var.source_database_name
  ssl_mode                    = var.source_ssl_mode

  postgres_settings {
    capture_ddls          = true
    execute_timeout       = 60
    max_file_size         = 32768
    slot_name             = "corecommerce_dms_replication_slot"
    heartbeat_enable      = true
    heartbeat_frequency   = 5
    plugin_name           = "test_decoding"
    fail_tasks_on_lob_truncation = false
    heartbeat_schema      = "public"
    map_boolean_as_boolean = false
    ddl_artifacts_schema  = "public"
  }

  extra_connection_attributes = ""

  tags = merge(var.tags, {
    Name = var.source_endpoint_id
  })

  depends_on = [aws_dms_replication_instance.main]
}

resource "aws_dms_endpoint" "target" {
  endpoint_id                 = var.target_endpoint_id
  endpoint_type               = "target"
  engine_name                 = var.target_engine_name
  server_name                 = var.target_server_name
  port                        = var.target_port
  username                    = var.target_username
  password                    = var.target_password
  database_name               = var.target_database_name
  ssl_mode                    = var.target_ssl_mode

  postgres_settings {
    after_connect_script    = ""
    fail_tasks_on_lob_truncation = false
    map_boolean_as_boolean  = false
  }

  extra_connection_attributes = ""

  tags = merge(var.tags, {
    Name = var.target_endpoint_id
  })

  depends_on = [aws_dms_replication_instance.main]
}

resource "aws_dms_replication_task" "cdc" {
  replication_task_id      = var.replication_task_id
  migration_type           = var.migration_type
  replication_instance_arn = aws_dms_replication_instance.main.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn

  table_mappings            = var.table_mappings
  replication_task_settings = var.replication_task_settings

  cdc_start_position        = var.cdc_start_position
  cdc_start_time            = var.cdc_start_position != null ? null : null  # 由 DMS 自动管理

  start_replication_task    = true

  tags = merge(var.tags, {
    Name = var.replication_task_id
  })

  depends_on = [
    aws_dms_endpoint.source,
    aws_dms_endpoint.target
  ]
}

resource "aws_cloudwatch_metric_alarm" "dms_cdc_latency" {
  alarm_name          = "${var.replication_task_id}-cdc-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CDCLatencySource"
  namespace           = "AWS/DMS"
  period              = 300
  statistic           = "Average"
  threshold           = 60  
  alarm_description   = "Alarm when CDC latency exceeds 60 seconds for more than 15 minutes"
  alarm_actions       = []   

  dimensions = {
    ReplicationInstanceIdentifier = var.replication_instance_id
    ReplicationTaskIdentifier     = var.replication_task_id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "dms_cdc_errors" {
  alarm_name          = "${var.replication_task_id}-cdc-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CDCLatencySource"
  namespace           = "AWS/DMS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when any CDC errors occur"
  alarm_actions       = []

  dimensions = {
    ReplicationInstanceIdentifier = var.replication_instance_id
    ReplicationTaskIdentifier     = var.replication_task_id
  }

  tags = var.tags
}

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dms_vpc_role" {
  name               = "dms-vpc-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  name               = "dms-cloudwatch-logs-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role" {
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}