terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.51.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.endpoint
  #api_token = var.api_token
  username = var.tf_username
  password = var.tf_password
  insecure = true # TODO: import server self-signed cert to disable it
  ssh {
    agent    = true
    username = var.ssh_agent_username
    password = var.ssh_agent_password
    #private_key = file("~/.ssh/id_rsa")
    node {
      name    = var.target_node_name
      address = var.target_node_ip
      port    = var.target_node_port
    }
  }
}

data "proxmox_virtual_environment_vms" "template" {
  node_name = var.target_node_name
  tags      = ["template", var.template_tag]
}

resource "proxmox_virtual_environment_file" "cloud_user_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node_name

  source_raw {
    data = file("cloud-init/user_data")

    file_name = "${var.vm_hostname}.${var.domain}-ci-user.yml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_meta_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node_name

  source_raw {
    data = templatefile("cloud-init/meta_data",
      {
        instance_id    = sha1(var.vm_hostname)
        local_hostname = var.vm_hostname
      }
    )

    file_name = "${var.vm_hostname}.${var.domain}-ci-meta_data.yml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = "${var.vm_hostname}.${var.domain}"
  node_name = var.target_node_name

  on_boot = var.onboot


  agent {
    enabled = true
  }

  tags = var.vm_tags

  cpu {
    type    = "host"
    cores   = var.cores
    sockets = var.sockets
    flags   = []
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge  = "vnet0"
    model   = "virtio"
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }

  boot_order    = ["scsi0"]
  scsi_hardware = "virtio-scsi-single"

  disk {
    interface    = "scsi0"
    iothread     = true
    datastore_id = "${var.disk.storage}"
    size         = var.disk.size
    discard      = "ignore"
  }

  dynamic "disk" {
    for_each = var.additionnal_disks
    content {
      interface    = "scsi${1 + disk.key}"
      iothread     = true
      datastore_id = "${disk.value.storage}"
      size         = disk.value.size
      discard      = "ignore"
      file_format  = "raw"
    }
  }

  clone {
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
  }

  initialization {
    # ip_config {
    #   ipv4 {
    #     address = "dhcp"
    #   }
    # }

    datastore_id         = "local"
    interface            = "ide2"
    user_data_file_id    = proxmox_virtual_environment_file.cloud_user_config.id
    meta_data_file_id    = proxmox_virtual_environment_file.cloud_meta_config.id
  }


}
