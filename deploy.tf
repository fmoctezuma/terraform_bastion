resource "openstack_blockstorage_volume_v2" "bastion_volume" {
  count = "${var.diskn}"
  name  = "${format("bastion_disk%02d", count.index)}"
  size  = "${var.disk_size}"
}

resource "openstack_networking_port_v2" "bastion_port" {
  name           = "bastion_port"
  admin_state_up = "true"
  network_id = "${var.network_id}"
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

resource "openstack_compute_instance_v2" "bastion_server" {
  count = "${var.count}"
  name = "${format("bastion-server-%02d", count.index)}"
  image_name = "${var.image_name}"
  flavor_id = "${var.flavor_id}"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["${openstack_compute_secgroup_v2.bastion_secgroup.name}"]
  network {
    name = "${var.tenant_network}"
    port = "${openstack_networking_port_v2.bastion_port.id}"
    }

  provisioner "file" {
    source    = "bastion-reqs.sh"
    destination = "/tmp/bastion-reqs.sh"

  connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${var.private_key}"
      }
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
    host = "${openstack_compute_instance_v2.bastion_server.network.0.fixed_ip_v4}"
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${var.private_key}"
      }
   }
}
