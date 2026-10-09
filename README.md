# Despliegue de VMs en Proxmox con Terraform

Crea máquinas virtuales en Proxmox VE clonando una plantilla con cloud-init. Las VMs se describen en un mapa
(`vms`): cada entrada es una VM, y añadir o quitar una entrada crea o destruye esa VM. Queda lista para configurarla
después con Ansible.

## Por qué el proveedor `bpg/proxmox`

La primera versión usaba `Telmate/proxmox` 2.9.x, que **no funciona con Proxmox 9**: pide el permiso `VM.Monitor`,
que ya no existe, y el proveedor se cae con un `panic`. Se cambió a [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs),
que está mantenido y soporta Proxmox 8 y 9. Los dos no son compatibles entre sí: cambian los recursos, los nombres de
los argumentos y la autenticación (ver [Migrar desde la versión con Telmate](#migrar-desde-la-versión-con-telmate)).

## Ficheros

| Fichero | Qué hace |
|---|---|
| `versions.tf` | Fija el proveedor `bpg/proxmox` 0.66.0 |
| `provider.tf` | Conexión a la API con token y SSH por el agente |
| `variables.tf` | Variables con su descripción; las IPs se validan (CIDR o `dhcp`) |
| `main.tf` | Recurso `proxmox_virtual_environment_vm`: una VM por entrada de `vms` |
| `outputs.tf` | IPs de cada VM según el qemu-guest-agent |
| `terraform.tfvars` | **Tus valores.** No está en el repo: lo ignora `.gitignore` |

## Requisitos

- Terraform 1.x.
- Proxmox VE 8 o 9.
- Una **plantilla con cloud-init y qemu-guest-agent** (ver más abajo).
- Un **token de API** en Proxmox.
- Un **ssh-agent** con una clave que entre como `root` en el nodo. El proveedor usa SSH para algunas operaciones que
  la API no cubre.

### 1. Usuario y token en Proxmox

En la shell del nodo:

```bash
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role Administrator
pveum user token add terraform@pve terraform --privsep 0
```

El último comando muestra el **secreto** del token una sola vez: guárdalo en tu gestor de contraseñas. El ID del token
es `terraform@pve!terraform`.

> `Administrator` es lo más sencillo para un laboratorio. Para algo más serio, crea un rol con solo los permisos que
> necesitas (`VM.*`, `Datastore.AllocateSpace`, `Datastore.Audit`, `SDN.Use`…) y asígnalo en lugar de ese.

### 2. Plantilla con cloud-init

Ejemplo con la imagen cloud de Ubuntu 24.04 y el VMID `9000`:

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

# La imagen cloud no trae el agente: se instala antes de importarla (paquete libguestfs-tools)
virt-customize -a noble-server-cloudimg-amd64.img --install qemu-guest-agent

qm create 9000 --name plantilla-ubuntu --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit --boot order=scsi0 --serial0 socket --vga serial0 --agent enabled=1
qm template 9000
```

Sin el qemu-guest-agent, `terraform apply` se queda esperando a que la VM informe de su IP hasta agotar el tiempo.

### 3. Clave SSH en el agente

Linux o macOS:

```bash
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_ed25519
```

Windows (PowerShell como administrador, una vez):

```powershell
Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
ssh-add $HOME\.ssh\id_ed25519
```

## Uso

```bash
git clone https://github.com/ElderArtemis/Proxmox.git
cd Proxmox
```

Crea `terraform.tfvars`. Las IPs del ejemplo son del rango `192.0.2.0/24`, reservado para documentación: pon las de
tu red.

```hcl
# --- Conexión ---
proxmox_api_url          = "https://192.0.2.10:8006/api2/json"
proxmox_api_token_id     = "terraform@pve!terraform"
proxmox_api_token_secret = "<secreto-del-token>"
# proxmox_insecure       = false   # solo si Proxmox tiene un certificado válido

# --- Común a todas las VMs ---
vm_target_node    = "pve"
vm_template_id    = 9000
vm_gateway        = "192.0.2.1"
vm_network_bridge = "vmbr0"
vm_disk_storage   = "local-lvm"

# --- Acceso a las VMs ---
vm_ci_user      = "usuario"
vm_ci_password  = "<contraseña>"
vm_ssh_key_path = "~/.ssh/id_ed25519.pub"

# --- Las VMs ---
vms = {
  "vm-01" = { id = 201, ip = "192.0.2.51/24", cores = 2, memory = 2048, disk_size = 20 }
  "vm-02" = { id = 202, ip = "dhcp",          cores = 2, memory = 4096, disk_size = 30 }
}
```

Despliegue:

```bash
terraform init     # descarga bpg/proxmox
terraform plan     # revisa qué va a crear, cambiar o DESTRUIR
terraform apply
terraform output   # IPs de cada VM
```

- **Añadir una VM**: una entrada más en `vms` y `terraform apply`.
- ⚠️ **Quitar una entrada destruye esa VM** con su disco. Mira siempre el `plan` antes.
- `disk_size` solo puede crecer: Proxmox no reduce discos.
- Para otro entorno, otro fichero de variables: `terraform apply -var-file="lab.tfvars"`.
- `terraform destroy` borra todas las VMs del mapa.

## Seguridad

- **No hay secretos ni IPs en el código**: todo va en `terraform.tfvars`, que está en `.gitignore` igual que
  `*.tfstate`.
- ⚠️ **El `terraform.tfstate` guarda en claro** la contraseña de las VMs y el resto de valores, aunque estén marcados
  como `sensitive`. Trátalo como un secreto: no lo subas ni lo compartas.
- `sensitive = true` solo evita que el valor salga por pantalla en `plan` y `apply`.

## Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| `apply` se queda en *Still creating…* varios minutos | La plantilla no tiene qemu-guest-agent, o está parado en la VM |
| `401` / `403` de la API | ID o secreto del token mal escritos, o el token sin permisos (`--privsep 0` o un rol asignado al token) |
| Error de certificado | Deja `proxmox_insecure = true` mientras Proxmox use el certificado autofirmado |
| `VM ... already exists` | El VMID (`id`) ya está en uso en el clúster |
| Error de SSH al nodo | La clave no está cargada en el ssh-agent o no entra como `root` |
| `Error acquiring the state lock` | Quedó un bloqueo de una ejecución cortada: `terraform force-unlock <ID>` (el ID sale en el error) |

## Migrar desde la versión con Telmate

El estado de Telmate (`proxmox_vm_qemu`) no sirve con bpg (`proxmox_virtual_environment_vm`):

```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

- Las VMs que creó la versión anterior siguen en Proxmox, pero el estado nuevo no las conoce. Sácalas del estado
  viejo con `terraform state rm proxmox_vm_qemu.vm_ansible` y bórralas a mano, o vuelve a crearlas desde el mapa.
- Las variables cambian: `vm_ip_config` pasa a ser `ip` en CIDR dentro de `vms`, la plantilla se indica por ID
  (`vm_template_id`) y el token va en `proxmox_api_token_id` y `proxmox_api_token_secret`.
