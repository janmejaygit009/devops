terraform {
  backend "gcs" {
    bucket = "jm_bucket_1"
    prefix = "jm-resource-creation/"
  }
}
