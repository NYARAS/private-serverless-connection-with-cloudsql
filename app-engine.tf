resource "google_app_engine_flexible_app_version" "appengine_flexible_automatic_scaling" {
  runtime = var.runtime
  readiness_check {
    path              = var.readiness_path
    host              = var.readiness_host
    failure_threshold = var.readiness_failure_threshold
    success_threshold = var.readiness_success_threshold
    check_interval    = var.readiness_check_interval
    timeout           = var.readiness_timeout
    app_start_timeout = var.readiness_app_start_timeout
  }
  liveness_check {
    path              = var.liveness_path
    host              = var.liveness_host
    failure_threshold = var.liveness_failure_threshold
    success_threshold = var.liveness_success_threshold
    check_interval    = var.liveness_check_interval
    timeout           = var.liveness_timeout
    initial_delay     = var.liveness_initial_delay
  }
  service = var.service
  
  version_id       = var.service_version
  inbound_services = var.inbound_services
  instance_class   = var.instance_class

  dynamic "network" {
    for_each = var.network[*]
    content {
      forwarded_ports  = network.value.forwarded_ports
      instance_tag     = network.value.instance_tag
      name             = network.value.name
      subnetwork       = network.value.subnetwork
      session_affinity = network.value.session_affinity
    }
  }
    dynamic "resources" {
    for_each = var.resources[*]
    content {
      cpu       = resources.value.cpu
      disk_gb   = resources.value.disk_gb
      memory_gb = resources.value.memory_gb
      dynamic "volumes" {
        for_each = resources.value.volumes == null ? [] : list(resources.value.volumes)
        content {
          name        = volumes.value.name
          volume_type = volumes.value.volume_type
          size_gb     = volumes.value.size_gb
        }
      }
    }
  }

  runtime_channel     = var.runtime_channel
  beta_settings       = var.beta_settings
  serving_status      = var.serving_status
  runtime_api_version = var.api_version

   dynamic "handlers" {
    for_each = var.handlers == null ? [] : var.handlers
    content {
      url_regex                   = var.handlers[handlers.key]["url_regex"]
      security_level              = var.handlers[handlers.key]["security_level"]
      login                       = var.handlers[handlers.key]["login"]
      auth_fail_action            = var.handlers[handlers.key]["auth_fail_action"]
      redirect_http_response_code = var.handlers[handlers.key]["redirect_http_response_code"]
      dynamic "script" {
        for_each = handlers.value.script == null ? [] : list(handlers.value.script)
        content {
          script_path = script.value.script_path
        }
      }
      dynamic "static_files" {
        for_each = handlers.value.static_files == null ? [] : list(handlers.value.static_files)
        content {
          path                  = static_files.value.path
          upload_path_regex     = static_files.value.upload_path_regex
          http_headers          = static_files.value.http_headers
          mime_type             = static_files.value.mime_type
          expiration            = static_files.value.expiration
          require_matching_file = static_files.value.require_matching_file
          application_readable  = static_files.value.application_readable
        }
      }
    }
  }
  runtime_main_executable_path = var.runtime_main_executable_path
  dynamic "api_config" {
    for_each = var.api_config == null ? [] : list(var.api_config)
    content {
      auth_fail_action = var.api_config[api_config.key]["auth_fail_action"]
      login            = var.api_config[api_config.key]["login"]
      script           = var.api_config[api_config.key]["script"]
      security_level   = var.api_config[api_config.key]["security_level"]
      url              = var.api_config[api_config.key]["url"]
    }
  }

  deployment {
    dynamic "zip" {
      for_each = var.zip[*]
      content {
        source_url  = zip.value.source_url
        files_count = zip.value.files_count
      }
    }
  }
  noop_on_destroy           = var.noop_on_destroy
  delete_service_on_destroy = var.delete_service_on_destroy
}
