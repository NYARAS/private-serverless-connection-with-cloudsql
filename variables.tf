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

 ## Allocated IP range variables
variable "name" {
  description = "Name of the allocated IP range"
  type        = string
}

variable "description" {
  type        = string
  description = "An optional description for the allocated IP address range created."
  default     = "Allocated IP address range created using a Terraform module."
}

variable "address" {
  type        = string
  description = "The IP address or the beginning of the address range represented by the allocated IP address range. \n If not specified, GCP chooses a valid IP address for you."
	default = null
}

variable "purpose" {
  description = "This should only be set when using an INTERNAL address. Possible values when using INTERNAL addresses are VPC_PEERING"
  type        = string
}

variable "address_type" {
  description = "The type of the address to reserve. Possible values are EXTERNAL or INTERNAL"
  type        = string
}

variable "prefix_length" {
  description = "The prefix length of the IP range. If not present, it means the address field is a single IP address. This field is not applicable if address_type=EXTERNAL."
  type        = string
}

variable "associated_vpc_network_id" {
  description = "The URL of the network in which to reserve an INTERNAL IP range. The IP range must be in RFC1918 space. This field is not applicable if address_type=EXTERNAL."
  type        = string
}

variable "associated_vpc_network_id" {
	type = string
	description = "(Required) Name of the vpc network you would like to create a private connection with."
}

variable "allocated_ip_address_ranges" {
	type = list(string)
	description = "(Required) Name of the IP address range(s) to peer."
}

# ========================= VARIABLE DEFINITION =================== #
# variable "project_id" {}
variable "name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "The POSTGRESQL version to use. Supported values are: POSTGRES_9_6, POSTGRES_10, POSTGRES_11, POSTGRES_12. It defaults to POSTGRES_10"
  type        = string
  default     = "POSTGRES_10"
}

variable "cloud_sql_region" {

  description = "The region where the Cloud SQL instance will reside"
  type        = string
}

variable "tier" {
  description = "Tier of the Cloud SQL instance. It defaults to db-g1-small"
  type        = string
  default     = "db-g1-small"
}

variable "activation_policy" {
  description = "This specifies when the instance should be active. Can be either ALWAYS, NEVER or ON_DEMAND. \n\n It defaults to ALWAYS if not set."
  type        = string
  default     = "ALWAYS"
  validation {
    condition     = contains(["ALWAYS", "NEVER", "ON_DEMAND"], var.activation_policy)
    error_message = "The value should be ALWAYS, NEVER or ON_DEMAND."

  }
}

variable "availability_type" {
  description = "The availability of the Cloud SQL instance. \n \n High Availability (HA) --> REGIONAL \n Single Zone (SZ) --> ZONAL. It defaults to ZONAL"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
    error_message = "The availability type should be either REGIONAL or ZONAL."

  }
}

variable "disk_size" {
  description = "(Optional, Default: 10) The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "(Optional, Default: PD_SSD) The type of data disk: PD_SSD or PD_HDD."
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "The value should be either PD_SSD or PD_HDD."
  }

}

variable "disk_autoresize" {
  description = "(Optional, Default: true) Configuration to increase storage size automatically."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.disk_autoresize)
    error_message = "Value must be set to either true or false."


  }
}

variable "point_in_time_recovery_enabled" {
  description = "True if Point-In-Time-Recovery is enabled."
  type        = string
  default     = false
}

variable "ipv4_enabled" {
  description = "Whether the Cloud SQL instance should be assigned a public IPV4 address."
  type        = bool
  default     = true
}

variable "vpc_network_id" {
  description = "The VPC network from which the Cloud SQL instance is accessible using private IP"
  type        = string
  default     = ""
}

variable "require_ssl" {
  description = "Set to true if mysqld should default to REQUIRE X509 for users connnecting over IP"
  type        = bool
  default     = null
}

variable "maintenance_prefered_day" {
  description = "Day of the week (1-7), starting on Monday"
  type        = number
  default     = null
}

variable "maintenance_prefered_hour" {
  description = "Hour of the day (0-23). Ignored if maintenance_prefered_day not set"
  type        = number
  default     = null
}

variable "update_track" {
  description = "Receive updates before the maintenance (canary) or later (stable)."
  type        = string
  default     = ""
}

variable "backup_enabled" {
  description = "(Optional) True if backup configuration is enabled. If disabled, PITR should be disabled too."
  type        = bool
  default     = false
}

variable "master_instance_name" {
  description = "(Optional) The name of the instance that will act as the master in the replication setup. Note, this requires the master to have binary_log_enabled set, as well as existing backups."
  type        = string
  default     = ""
}

variable "sql_user_name" {
  type        = string
  description = "(Required) The name of the user."
}

variable "cloud_sql_instance_name" {
  type        = string
  description = "(Required) The name of the Cloud SQL instance the user will be created on."
}

# ==== Cloud SQL User ==== #
variable "sql_user_password" {
  type        = string
  description = "(Required) The password for the user."
	validation {
		condition = var.sql_user_password != null && var.sql_user_password != ""
		error_message = "The Cloud SQL user password must not be empty."
	}
}
