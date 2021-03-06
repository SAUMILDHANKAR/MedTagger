## Network ##

resource "openstack_networking_network_v2" "network" {
  name           = "medtagger_net"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "medtagger_subnet"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr       = "192.168.0.0/24"
  dns_nameservers = "${var.dns_list}"
}

resource "openstack_networking_router_v2" "router" {
  name                = "medtagger_router"
  external_network_id = "${var.ext_network_id}"
  admin_state_up      = true
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}

resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = "${var.default_network}"
}

## Security groups ##

resource "openstack_networking_secgroup_v2" "app_sec_group" {
  name        = "app"
  description = "Security group for app hosts for MedTagger"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_app" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_sec_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ui" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.app_sec_group.id}"
}


resource "openstack_networking_secgroup_v2" "db_sec_group" {
  name        = "db"
  description = "Security group for Db hosts for MedTagger"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_db" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.db_sec_group.id}"
}

resource "openstack_networking_secgroup_rule_v2" "cassandra_sec_group" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9042
  port_range_max    = 9042
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.db_sec_group.id}"
}

## Key pairs ##

resource "openstack_compute_keypair_v2" "medtagger_keypair_app" {
  name = "app-key"
}

resource "openstack_compute_keypair_v2" "medtagger_keypair_db" {
  name = "db-key"
}

data "openstack_compute_keypair_v2" "app_public_key" {
  name = "${openstack_compute_keypair_v2.medtagger_keypair_app.name}"
}

data "openstack_compute_keypair_v2" "db_public_key" {
  name = "${openstack_compute_keypair_v2.medtagger_keypair_db.name}"
}

resource "local_file" "app_cert" {
    content     = "${data.openstack_compute_keypair_v2.app_public_key.public_key}"
    filename = "${path.module}/app.cert"
}

resource "local_file" "app_cert" {
    content     = "${data.openstack_compute_keypair_v2.db_public_key.public_key}"
    filename = "${path.module}/db.cert"
}
