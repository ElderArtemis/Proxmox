output "vm_name" {
  description = "Nombre de la VM creada"
  value       = proxmox_vm_qemu.vm_ansible.name
}

output "vm_ip_address" {
  description = "IP de la VM (puede tardar en aparecer)"
  value       = proxmox_vm_qemu.vm_ansible.default_ipv4_address
}