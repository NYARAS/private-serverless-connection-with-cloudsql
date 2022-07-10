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
