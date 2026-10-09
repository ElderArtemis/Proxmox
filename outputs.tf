output "lista_maquinas" {
  description = "IPs que reporta el qemu-guest-agent de cada VM (vacío si el agente no está instalado en la plantilla)"
  value = {
    for nombre, vm in proxmox_virtual_environment_vm.mis_vms : nombre => vm.ipv4_addresses
  }
}
