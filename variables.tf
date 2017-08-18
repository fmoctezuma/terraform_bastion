variable "count" {
  default = 1
}

variable "diskn" {
  default = 1
}

variable "disk_size" {
  default = 50
}

variable "tenant_network" {
  description = "The network to be used."
  default     = "public"
}

variable "image_name" {
  description = "Glance image name."
  default     = "Ubuntu Server 16.04 LTS Xenial Xerus (cloudimg)"
}

variable "flavor_name" {
  description = "Openstack flavor name."
  default     = "m1.medium"
}
