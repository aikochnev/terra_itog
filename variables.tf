###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "ID облака Yandex Cloud"
}

variable "folder_id" {
  type        = string
  description = "ID каталога Yandex Cloud"
}

variable "admin_cidr" {
  type        = string
  description = "Ваш внешний IP в формате x.x.x.x/32 для SSH"
}

variable "ssh_public_key" {
  type        = string
  description = "Содержимое публичного SSH-ключа"
}

variable "zone_b" {
  type    = string
  default = "ru-central1-b"
}

variable "zone_d" {
  type    = string
  default = "ru-central1-d"
}