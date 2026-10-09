# --- Conexión a Proxmox ---
variable "proxmox_api_url" {
  description = "URL de la API de Proxmox, p. ej. https://<ip-o-nombre>:8006/api2/json"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "ID del token de API con el formato usuario@realm!nombre, p. ej. terraform@pve!terraform"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Secreto (UUID) del token de API. Proxmox solo lo enseña al crearlo"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Aceptar el certificado autofirmado de Proxmox. Ponerlo a false si tiene uno válido"
  type        = bool
  default     = true
}

# --- Configuración común a todas las VMs ---
variable "vm_target_node" {
  description = "Nodo de Proxmox donde se crean las VMs (el nombre que sale en el árbol del Datacenter)"
  type        = string
}

variable "vm_template_id" {
  description = "ID numérico de la plantilla con cloud-init que se clona (bpg/proxmox no acepta el nombre)"
  type        = number
}

variable "vm_gateway" {
  description = "Puerta de enlace IPv4. Si todas las VMs van por DHCP, se deja sin poner"
  type        = string
  default     = null
}

variable "vm_network_bridge" {
  description = "Bridge de Proxmox al que se conecta la tarjeta de red"
  type        = string
  default     = "vmbr0"
}

variable "vm_disk_storage" {
  description = "Almacenamiento de Proxmox para el disco, p. ej. local-lvm"
  type        = string
}

# --- Acceso a las VMs (cloud-init) ---
variable "vm_ci_user" {
  description = "Usuario que crea cloud-init en cada VM"
  type        = string
  default     = "usuario"
}

variable "vm_ci_password" {
  description = "Contraseña de ese usuario"
  type        = string
  sensitive   = true
}

variable "vm_ssh_key_path" {
  description = "Ruta a la clave SSH PÚBLICA que se mete en las VMs, p. ej. ~/.ssh/id_ed25519.pub"
  type        = string
}

# --- Las VMs: una por cada entrada del mapa ---
variable "vms" {
  description = "Mapa nombre => datos de la VM. El nombre de la clave es el nombre de la VM en Proxmox"
  type = map(object({
    id        = number # VMID libre en Proxmox
    ip        = string # IPv4 en CIDR (192.0.2.50/24) o "dhcp"
    cores     = number
    memory    = number # MB
    disk_size = number # GB, número entero
  }))

  validation {
    condition = alltrue([
      for vm in values(var.vms) : vm.ip == "dhcp" || can(cidrhost(vm.ip, 0))
    ])
    error_message = "Cada ip debe ir en formato CIDR (p. ej. 192.0.2.50/24) o ser \"dhcp\"."
  }
}
