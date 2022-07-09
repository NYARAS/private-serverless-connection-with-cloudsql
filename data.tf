# ======================== DATA SOURCE DEFINITION ================= #

# It collects the different regions available within GCP.
data "google_compute_regions" "available" {
}
