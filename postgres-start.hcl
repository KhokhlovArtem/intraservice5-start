resource "yandex_mdb_postgresql_cluster" "servicedesk-test01-dbcl01" {
  name        = "servicedesk-test01-dbcl01"
  environment = "PRODUCTION"
  network_id = yandex_vpc_network.my-net.id

  config {
    version = 17
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id      = "network-ssd"
      disk_size         = 20
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.my-subnet.id
  }
}
