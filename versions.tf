terraform {
  required_providers {
    # El proveedor Telmate/proxmox falla con Proxmox 9 (permiso VM.Monitor y panics); bpg/proxmox sí funciona
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.0"
    }
  }
}
