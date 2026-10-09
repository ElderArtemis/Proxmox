provider "proxmox" {
  endpoint = var.proxmox_api_url

  # bpg/proxmox quiere el token entero en una sola cadena: ID=SECRETO
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"

  # Proxmox trae un certificado autofirmado de serie
  insecure = var.proxmox_insecure

  # Algunas operaciones del proveedor van por SSH al nodo; usa las claves del ssh-agent
  ssh {
    agent = true
  }
}
