variable "ssh_keys" {
  type = list(
    object({
      name = string
      key = string
    })
  )

  default = [ {
    name = "default"
    key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDjv0NeythPTj0QgtIOV68GYPvcws/ffi+4v2F4M6wmy/87hDcFx/Lzcwi9g7gQ7MozKgg8S3fLnk4g283wPkNU="
  } ]
}
