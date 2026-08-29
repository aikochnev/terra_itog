
# ----------------------------
# Outputs
# ----------------------------

output "web_public_ips" {
  description = "Публичные IP-адреса web VM"

  value = {
    for name, vm in yandex_compute_instance.web :
    name => vm.network_interface[0].nat_ip_address
  }
}

output "mysql_cluster_id" {
  value = yandex_mdb_mysql_cluster.mysql.id
}

output "container_registry_id" {
  value = yandex_container_registry.main.id
}

output "container_image_path" {
  value = "cr.yandex/${yandex_container_registry.main.id}/my-app"
}
