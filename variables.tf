variable "credentials" {
  type        = string
  description = "Location of the service account for GCP."
}

variable "project_id" {
  type        = string
  description = "GCP project id to create the resources."
}

variable "region" {
  type        = string
  description = "The GCP region to create the resources."
  default     = "us-central1"
}

## VPC variables
variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "vpc_description" {
  description = "An optional description of the vpc resource"
  type        = string
  default     = "VPC network created using Terraform."
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#auto_create_subnetworks
variable "vpc_auto_create_subnetworks_enabled" {
  description = "When set to `true`, it will create a subnetwork for each region automatically across the 10.128.0.0/9"
  type        = bool
  default     = false
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#routing_mode
variable "routing_mode" {
  type        = string
  description = "Possible values for this variable are GLOBAL or REGIONAL. It defaults to GLOBAL"
  default     = "GLOBAL"
}

# If set to false, it can deny access to the internet for the instances attached to the network created
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#delete_default_routes_on_create
variable "delete_default_routes_on_create_enabled" {
  type        = bool
  description = "If set to true, default routes (0.0.0.0/0) will be deleted immediately after the network creation. Defaults to false"
  default     = false
}
