terraform {
  required_version = ">= 1.0"
}

################################
# WEB1
################################
resource "null_resource" "web1" {
  provisioner "local-exec" {
    command = <<EOT
VBoxManage createvm --name web1 --ostype Ubuntu_64 --register
VBoxManage modifyvm web1 --memory ${var.vm_memory} --cpus ${var.vm_cpus} --nic1 nat
VBoxManage modifyvm web1 --boot1 dvd --boot2 disk --boot3 none --boot4 none

VBoxManage createmedium disk --filename web1.vdi --size ${var.disk_size}
VBoxManage storagectl web1 --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach web1 --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium web1.vdi

VBoxManage storagectl web1 --name "IDE Controller" --add ide
VBoxManage storageattach web1 --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${var.iso_path}"

VBoxManage startvm web1 --type gui
EOT
  }
}

################################
# WEB2
################################
resource "null_resource" "web2" {
  provisioner "local-exec" {
    command = <<EOT
VBoxManage createvm --name web2 --ostype Ubuntu_64 --register
VBoxManage modifyvm web2 --memory ${var.vm_memory} --cpus ${var.vm_cpus} --nic1 nat
VBoxManage modifyvm web2 --boot1 dvd --boot2 disk --boot3 none --boot4 none

VBoxManage createmedium disk --filename web2.vdi --size ${var.disk_size}
VBoxManage storagectl web2 --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach web2 --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium web2.vdi

VBoxManage storagectl web2 --name "IDE Controller" --add ide
VBoxManage storageattach web2 --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${var.iso_path}"

VBoxManage startvm web2 --type gui
EOT
  }
}

################################
# LOAD BALANCER
################################
resource "null_resource" "lb" {
  provisioner "local-exec" {
    command = <<EOT
VBoxManage createvm --name loadbalancer --ostype Ubuntu_64 --register
VBoxManage modifyvm loadbalancer --memory ${var.vm_memory} --cpus ${var.vm_cpus} --nic1 nat
VBoxManage modifyvm loadbalancer --boot1 dvd --boot2 disk --boot3 none --boot4 none

VBoxManage createmedium disk --filename lb.vdi --size ${var.disk_size}
VBoxManage storagectl loadbalancer --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach loadbalancer --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium lb.vdi

VBoxManage storagectl loadbalancer --name "IDE Controller" --add ide
VBoxManage storageattach loadbalancer --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${var.iso_path}"

VBoxManage startvm loadbalancer --type gui
EOT
  }
}


################################
# GRAFANA MONITORING SERVER
################################
resource "null_resource" "monitoring" {
  provisioner "local-exec" {
    command = <<EOT
VBoxManage createvm --name monitoring --ostype Ubuntu_64 --register
VBoxManage modifyvm monitoring --memory ${var.vm_memory} --cpus ${var.vm_cpus} --nic1 nat
VBoxManage modifyvm monitoring --boot1 dvd --boot2 disk --boot3 none --boot4 none

VBoxManage createmedium disk --filename monitoring.vdi --size ${var.disk_size}

VBoxManage storagectl monitoring --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach monitoring --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium monitor.vdi

VBoxManage storagectl monitoring --name "IDE Controller" --add ide
VBoxManage storageattach monitoring--storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${var.iso_path}"

VBoxManage startvm monitoring --type gui
EOT
  }
}


################################
# Caching Server
################################
resource "null_resource" "caching_server" {
  provisioner "local-exec" {
    command = <<EOT
# Create VM
VBoxManage createvm --name caching --ostype Ubuntu_64 --register

# Configure VM
VBoxManage modifyvm caching --memory ${var.vm_memory} --cpus ${var.vm_cpus} --nic1 nat
VBoxManage modifyvm caching --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Create Disk
VBoxManage createmedium disk --filename caching.vdi --size ${var.disk_size}

# Attach Disk
VBoxManage storagectl caching --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach caching --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium caching.vdi

# Attach ISO
VBoxManage storagectl caching --name "IDE Controller" --add ide
VBoxManage storageattach caching --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${var.iso_path}"

# Start VM
VBoxManage startvm caching --type gui
EOT
  }
}