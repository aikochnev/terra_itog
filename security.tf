
# ----------------------------
# Security Group для web VM
# ----------------------------

resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-sg"
  description = "SSH from administrator IP, public HTTP and HTTPS"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description    = "SSH only from administrator IP"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description    = "Public HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Public HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------
# Security Group для MySQL
# ----------------------------

resource "yandex_vpc_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Allow MySQL only from web VMs"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description       = "MySQL from web VM security group"
    protocol          = "TCP"
    port              = 3306
    security_group_id = yandex_vpc_security_group.web_sg.id
  }

  egress {
    description    = "Allow all outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}