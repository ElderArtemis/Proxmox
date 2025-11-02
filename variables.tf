# -----------------------------------------------
# Credenciales del Proveedor (Definición)
# -----------------------------------------------
variable "proxmox_api_url" {
  type        = string
  description = "URL de la API de Proxmox (ej: https://192.168.1.145:8006/api2/json)"
  sensitive   = true
}

variable "proxmox_user" {
  type        = string
  description = "Usuario de Proxmox"
  sensitive   = true
}

variable "proxmox_password" {
  type        = string
  description = "Contraseña del usuario de Proxmox"
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  type        = bool
  description = "Ignorar certificados TLS inválidos"
  default     = true # <--- Este default está bien, no es un secreto
}

# -----------------------------------------------
# Configuración de la VM (Definición)
# -----------------------------------------------

# --- Valores específicos (sin default) ---
#     (Estos DEBEN ir en tu .tfvars)

variable "vm_name" {
  description = "Nombre para la nueva VM"
  type        = string
  # Sin default
}

variable "vm_id" {
  description = "ID único para la nueva VM"
  type        = number
  # Sin default
}

variable "vm_template" {
  description = "Nombre de la plantilla a clonar"
  type        = string
  # Sin default
}

variable "vm_target_node" {
  description = "Nodo de Proxmox donde se desplegará la VM"
  type        = string
  default     = "pve" # <-- Puedes dejar este si 'pve' es tu único nodo
}

variable "vm_ip_config" {
  description = "Configuración IP estática (ej: ip=192.168.1.200/24,gw=192.168.1.1)"
  type        = string
  # Sin default
}

variable "vm_ci_user" {
  description = "Usuario de Cloud-Init"
  type        = string
  default     = "ubuntu" # <-- Este está bien, es el estándar de la plantilla
}

variable "vm_ci_password" {
  description = "Contraseña de Cloud-Init"
  type        = string
  sensitive   = true
  # Sin default (¡MUY IMPORTANTE!)
}

variable "vm_ssh_key_path" {
  description = "Ruta al fichero de clave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub" # <-- Este default es genérico, está bien
}


# --- Valores genéricos (con default) ---
#     (Estos son opcionales en tu .tfvars)

variable "vm_cores" {
  description = "Número de cores de CPU"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memoria RAM en MB"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Tamaño del disco"
  type        = string
  default     = "20G"
}

variable "vm_disk_storage" {
  description = "Storage de Proxmox para el disco"
  type        = string
  default     = "local-lvm"
}

variable "vm_network_bridge" {
  description = "Bridge de red de Proxmox (ej: vmbr0)"
  type        = string
  default     = "vmbr0" # <-- Podrías quitarlo si tienes varios (vmbr0, vmbr1...)
}