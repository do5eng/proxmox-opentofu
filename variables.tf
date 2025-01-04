variable "endpoint" {
  description = "URL of Proxmox web interface"
  type = string
}

variable "api_token" {
  description = "Token to connect Proxmox API"
  type = string
}

variable "tf_username" {
  description = "Proxmox TF username"
  type = string
}

variable "tf_password" {
  description = "Proxmox TF password"
  type = string
}

variable "ssh_agent_username" {
  description = "Proxmox SSH agent username"
  type = string
}

variable "ssh_agent_password" {
  description = "Proxmox SSH agent password"
  type = string
}

variable "target_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "target_node_ip" {
  description = "Proxmox node IP"
  type        = string
}

variable "target_node_port" {
  description = "Proxmox node port"
  type        = string
}

variable "onboot" {
  description = "Auto start VM when node is start"
  type        = bool
  default     = true
}

variable "target_node_domain" {
  description = "Proxmox node domain"
  type        = string
  default = ""
}

variable "vm_hostname" {
  description = "VM hostname"
  type        = string
  default = "ourserver"
}

variable "domain" {
  description = "VM domain"
  type        = string
  default = "local"
}

variable "vm_tags" {
  description = "VM tags"
  type        = list(string)
  default = [ "ubuntu" ]
}

variable "template_tag" {
  description = "Template tag"
  type        = string
  default = "ubuntu"
}

variable "sockets" {
  description = "Number of sockets"
  type        = number
  default     = 1
}

variable "cores" {
  description = "Number of cores"
  type        = number
  default     = 6
}

variable "memory" {
  description = "Number of memory in MB"
  type        = number
  default     = 20480
}

variable "vm_user" {
  description = "User"
  type        = string
  sensitive   = true
  default = "sysadmin"
}

variable "disk" {
  description = "Disk (size in Gb)"
  type = object({
    storage = string
    size    = number
  })
  default = {
    storage = "local"
    size = 20
  }
}

variable "additionnal_disks" {
  description = "Additionnal disks"
  type = list(object({
    storage = string
    size    = number
  }))
  default = [
    {
      storage = "local"
      size = 180
    }
  ]
}
