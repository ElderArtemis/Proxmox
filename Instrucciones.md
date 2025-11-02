# Despliegue de VMs en Proxmox con Terraform

Este proyecto automatiza la creación de máquinas virtuales (VMs) en un clúster de Proxmox VE utilizando Terraform.

El objetivo es pasar de una configuración monolítica (`main.tf`) a una estructura de código flexible, segura y reutilizable, lista para ser gestionada por Ansible.

## 🚀 Tecnologías Utilizadas

* **Terraform:** Para la Infraestructura como Código (IaC).
* **Proxmox VE:** Como hipervisor.
* **Ansible (Siguiente paso):** Para la gestión de la configuración post-creación.

---

## ✨ Características Principales

Este repositorio sigue las mejores prácticas de Terraform para garantizar la seguridad y la flexibilidad:

1.  **Estructura Modular:** El código está separado lógicamente:
    * `versions.tf`: Define los proveedores.
    * `provider.tf`: Configura la conexión a Proxmox.
    * `variables.tf`: Define **qué** se puede configurar (es una plantilla abstracta).
    * `main.tf`: Crea los recursos usando las variables.
    * `outputs.tf`: Devuelve datos útiles (como la IP de la VM).

2.  **Seguridad (Sin Secretos):**
    * **No hay contraseñas en el código.** Todas las credenciales (API de Proxmox, contraseñas de VM) se gestionan en el fichero `terraform.tfvars`.
    * El fichero `.gitignore` bloquea explícitamente `*.tfvars` y `*.tfstate` para que nunca se suban secretos al repositorio.

3.  **Flexibilidad (Entornos):**
    * **No hay IPs ni nombres "hardcodeados".** Todas las configuraciones específicas del entorno (IPs, nombres de VM, IDs, plantillas a clonar) se definen en `terraform.tfvars`.
    * Se pueden crear nuevos entornos (ej. `prod.tfvars`) y desplegarlos con `terraform apply -var-file="prod.tfvars"`.

---

## 🔧 Cómo Usar

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/ElderArtemis/Proxmox.git](https://github.com/ElderArtemis/Proxmox.git)
    cd Proxmox
    ```

2.  **Crear fichero de configuración:**
    Crea un fichero `terraform.tfvars` (este fichero está ignorado por Git) y rellénalo con tus datos:

    ```hcl
    # Credenciales (Secretos)
    proxmox_api_url  = "https://TU_IP_PROXMOX:8006/api2/json"
    proxmox_user     = "root@pam"
    proxmox_password = "TU_CONTRASEÑA_PROXMOX"
    vm_ci_password   = "TU_CONTRASEÑA_PARA_LA_PLANTILLA"

    # Configuración de la VM (Tu Entorno)
    vm_name         = "VM-ANSIBLE"
    vm_id           = 200
    vm_template     = "ubuntu-template"
    vm_ip_config    = "ip=192.168.1.200/24,gw=192.168.1.1"
    vm_target_node  = "pve"
    ```

3.  **Desplegar:**
    ```bash
    # Inicializar Terraform
    terraform init

    # (Opcional) Ver el plan
    terraform plan

    # Aplicar y crear la VM
    terraform apply
    ```