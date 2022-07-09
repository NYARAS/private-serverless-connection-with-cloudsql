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
