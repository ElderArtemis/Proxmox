resource "proxmox_vm_qemu" "vm_ansible" { # Renombrado para más claridad
  # Configuración de Cloud-Init
  ciuser     = var.vm_ci_user
  cipassword = var.vm_ci_password
  sshkeys    = file(var.vm_ssh_key_path)

  # Configuración de la VM
  name        = var.vm_name
  target_node = var.vm_target_node
  clone       = var.vm_template
  full_clone  = true
  vmid        = var.vm_id
  bootdisk    = "scsi0" # [cite: 2]

  # Recursos
  cores   = var.vm_cores
  vcpus   = var.vm_cores # Asumo vcpus = cores
  memory  = var.vm_memory
  agent   = 1 # [cite: 3]

  # Disco
  disk {
    type     = "scsi"
    size     = var.vm_disk_size
    storage  = var.vm_disk_storage
    iothread = 1 # [cite: 3]
  }

  # Red
  network {
    model  = "virtio"
    bridge = var.vm_network_bridge # [cite: 4]
  }

  # Configuración IP
  ipconfig0 = var.vm_ip_config
}