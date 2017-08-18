resource "openstack_blockstorage_volume_v2" "bastion_volume" {
  count = "${var.diskn}"
  name  = "${format("bastion_disk%02d", count.index)}"
  size  = "${var.disk_size}"
}

resource "openstack_compute_secgroup_v2" "bastion_secgroup" {
  name        = "bastion_secgroup"
  description = "Bastion Security Group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "openstack_compute_keypair_v2" "k8s_keypair" {
  name       = "bastion_keypair"
  public_key = "${tls_private_key.ssh_key.public_key_openssh}"
}

resource "null_resource" "export" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_key.private_key_pem}' >id_rsa_core && chmod 0600 id_rsa_core"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_key.public_key_openssh}' >id_rsa_core.pub"
  }
}

resource "openstack_compute_instance_v2" "bastion_server" {
  count           = "${var.count}"
  name            = "${format("bastion-server-%02d", count.index)}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${openstack_compute_keypair_v2.k8s_keypair.name}"
  security_groups = ["${openstack_compute_secgroup_v2.bastion_secgroup.name}"]
  
    network {
    name = "${var.tenant_network}"
  }

  provisioner "file" {
    source      = "bastion-reqs.sh"
    destination = "/tmp/bastion-reqs.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.ssh_key.private_key_pem}"
  }
}

resource "openstack_compute_volume_attach_v2" "volume_attach" {
  instance_id = "${openstack_compute_instance_v2.bastion_server.*.id[count.index]}"
  volume_id   = "${openstack_blockstorage_volume_v2.bastion_volume.*.id[count.index]}"
}

resource "null_resource" "bastion_reqs" {
  depends_on = ["openstack_compute_volume_attach_v2.volume_attach"]

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/bastion-reqs.sh",
    ]

    connection {
      host        = "${openstack_compute_instance_v2.bastion_server.network.0.fixed_ip_v4}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${tls_private_key.ssh_key.private_key_pem}"
    }
  }
}
