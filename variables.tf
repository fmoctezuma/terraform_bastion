variable "openstack_user_name" {
    description = "The username for the Tenant."
    default  = "your user"
}

variable "openstack_tenant_name" {
    description = "The name of the Tenant."
    default  = "your tenant"
}

variable "openstack_password" {
    description = "The password for the Tenant."
    default  = "your pass"
}

variable "openstack_auth_url" {
    description = "The endpoint url to connect to OpenStack."
    default  = "${OS_PUB_ENDPOINT}"
}

variable "openstack_keypair" {
    description = "The keypair to be used."
    default  = "yourkey"
}

variable "tenant_network" {
    description = "The network to be used."
    default  = "public"
}

variable "image_name" {
    description = "Glance image name."
    default = "Ubuntu Server 16.04 LTS Xenial Xerus (cloudimg)"
}

variable "flavor_id" {
    description = "Openstack flavor id."
    default = "e46a21da-3487-4fac-8e16-d1239f41f58b"
}

variable "private_key" {
    type = "string"
    description = "private_key"
    default = <<EOF
-----BEGIN RSA PRIVATE KEY-----
your key
-----END RSA PRIVATE KEY-----
EOF
}
