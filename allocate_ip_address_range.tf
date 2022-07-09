resource "google_compute_global_address" "allocated_ip_range" {
  name          = var.name
  description   = var.description
  address       = var.address
  purpose       = var.address_type == "EXTERNAL" ? null : var.purpose
  address_type  = var.address_type
  prefix_length = var.address_type == "EXTERNAL" ? null : var.prefix_length
  network       = var.address_type == "EXTERNAL" ? null : var.associated_vpc_network_id
}

resource "google_service_networking_connection" "private_connection" {
  network                 = var.associated_vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = var.allocated_ip_address_ranges
}
