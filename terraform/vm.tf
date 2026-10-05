resource "yandex_compute_instance_group" "lamp" {
  name               = "lamp-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.ig_sa.id

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = var.image_id
        size     = 20
        type     = "network-ssd"
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public_subnet.id]
      nat        = true
    }

    scheduling_policy {
      preemptible = true
    }

    metadata = {
      user-data = templatefile("${path.module}/cloud-init.tftpl", {
        bucket_domain = yandex_storage_bucket.pictures_bucket.bucket
        object_key    = yandex_storage_object.download_kitty.key
      })
      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  load_balancer {
    target_group_name        = "lamp-target-group"
    target_group_description = "Target group for LAMP"
  }
  application_load_balancer {
    target_group_name        = "lamp-target-group"
    target_group_description = "Target group for LAMP"
  }
  health_check {
    interval            = 10
    timeout             = 4
    healthy_threshold   = 3
    unhealthy_threshold = 5

    http_options {
      port = 80
      path = "/"
    }
  }
}

output "external_ips" {
  value = {
    for i, vm in yandex_compute_instance_group.lamp.instances :
    vm.name => vm.network_interface[0].nat_ip_address
  }
}

output "internal_ips" {
  value = {
    for i, vm in yandex_compute_instance_group.lamp.instances :
    vm.name => vm.network_interface[0].ip_address
  }
}