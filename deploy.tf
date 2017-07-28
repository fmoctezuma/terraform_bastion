variable "count" {
  default = 1
}

variable "diskn" {
  default = 1
}

variable "disk_size" {
  default = 10
}

resource "openstack_blockstorage_volume_v2" "bastion_volume" {
  count = "${var.diskn}"
  name  = "${format("bastion_disk%02d", count.index)}"
  size  = "${var.disk_size}"
}

resource "openstack_compute_instance_v2" "bastion_server" {
  count = "${var.count}"
  name = "${format("bastion-server-%02d", count.index)}"
  image_name = "${var.image_name}"
  flavor_id = "${var.flavor_id}"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["default"]
  network {
    name = "${var.tenant_network}"
    }

  provisioner "file" {
    source    = "bastion-reqs.sh"
    destination = "/tmp/bastion-reqs.sh"

  connection {
      type     = "ssh"
      user     = "your user"
      private_key = "${var.private_key}"
      }
  }

  provisioner "remote-exec" {
     inline = [
     "sudo bash /tmp/bastion-reqs.sh >/dev/null 2>&1 &",
     ]

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
