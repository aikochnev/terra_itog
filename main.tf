# ----------------------------
# Образ Ubuntu
# ----------------------------

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# ----------------------------
# VPC и подсети
# ----------------------------

resource "yandex_vpc_network" "main" {
  name        = "devops-vpc"
  description = "VPC for web VMs and Managed MySQL"
}

# Подсеть для VM в ru-central1-b
resource "yandex_vpc_subnet" "web_b" {
  name           = "web-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

# Подсеть для VM в ru-central1-d
resource "yandex_vpc_subnet" "web_d" {
  name           = "web-d"
  zone           = var.zone_d
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}

# Приватная подсеть для Managed MySQL в ru-central1-b
resource "yandex_vpc_subnet" "db_b" {
  name           = "db-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}


# ----------------------------
# Две web VM в разных зонах
# ----------------------------

locals {
  web_nodes = {
    web-b = {
      zone      = var.zone_b
      subnet_id = yandex_vpc_subnet.web_b.id
    }

    web-d = {
      zone      = var.zone_d
      subnet_id = yandex_vpc_subnet.web_d.id
    }
  }

  ssh_public_key = file(pathexpand("~/.ssh/ubuntu.pub"))
}

resource "yandex_compute_instance" "web" {
  for_each = local.web_nodes

  name        = each.key
  hostname    = each.key
  zone        = each.value.zone
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = each.value.subnet_id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# ----------------------------
# Managed MySQL в zone-b
# ----------------------------

resource "yandex_mdb_mysql_cluster" "mysql" {
  name        = "app-mysql"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.main.id
  version     = "8.0"

  security_group_ids  = [yandex_vpc_security_group.mysql_sg.id]
  deletion_protection = false

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  host {
    zone             = var.zone_b
    subnet_id        = yandex_vpc_subnet.db_b.id
    assign_public_ip = false
  }
}

resource "yandex_mdb_mysql_database" "app" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "appdb"
}

resource "yandex_mdb_mysql_user" "app" {
  cluster_id        = yandex_mdb_mysql_cluster.mysql.id
  name              = "appuser"
  generate_password = true

  permission {
    database_name = yandex_mdb_mysql_database.app.name
    roles         = ["ALL"]
  }
}

# ----------------------------
# Container Registry
# ----------------------------

resource "yandex_container_registry" "main" {
  name      = "devops-registry"
  folder_id = var.folder_id

  labels = {
    environment = "lab"
    project     = "devops"
  }
}

resource "yandex_container_repository" "app" {
  name = "${yandex_container_registry.main.id}/my-app"
}
