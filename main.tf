resource "proxmox_virtual_environment_vm" "mis_vms" {
  # Una VM por cada entrada del mapa var.vms
  for_each = var.vms

  name      = each.key # la clave del mapa, p. ej. "vm-01"
  node_name = var.vm_target_node
  vm_id     = each.value.id # VMID, único en el clúster

  initialization {
    user_account {
      username = var.vm_ci_user
      password = var.vm_ci_password
      keys     = [file(var.vm_ssh_key_path)]
    }

    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.vm_gateway
      }
    }
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  # La plantilla debe traer qemu-guest-agent; sin él, Terraform espera hasta agotar el tiempo
  agent {
    enabled = true
  }

  disk {
    datastore_id = var.vm_disk_storage
    interface    = "scsi0"
    size         = each.value.disk_size
    file_format  = "raw"
  }

  network_device {
    bridge = var.vm_network_bridge
  }

  clone {
    vm_id = var.vm_template_id
  }
}