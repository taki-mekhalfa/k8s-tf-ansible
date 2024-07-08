variable "machine" {
  default = {
    machine_type = "e2-standard-2"
    os           = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}

variable "ranges" {
  default = {
    local_range  = "192.168.0.0/24"
    global_range = "0.0.0.0/0"
  }
}

variable "internal_ips" {
  default = {
    master  = "192.168.0.2"
    workers = ["192.168.0.3", "192.168.0.4"]
  }
}