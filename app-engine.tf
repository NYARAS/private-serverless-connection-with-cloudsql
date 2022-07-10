resource "google_app_engine_flexible_app_version" "appengine_flexible_automatic_scaling" {
  runtime = var.runtime
  readiness_check {

  }
  liveness_check {

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
