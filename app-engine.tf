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

  runtime_main_executable_path = var.runtime_main_executable_path

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
