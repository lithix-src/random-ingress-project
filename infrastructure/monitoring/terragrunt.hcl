include "root" {
    path = find_in_parent_folders()
}

dependency "ingress_storage" {
    config_path = "../storage/ingress-s3"
}

inputs = {
    ingress_log_bucket = dependency.ingress_storage.outputs.ingress_bucket_id
}