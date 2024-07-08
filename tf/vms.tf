provider "google" {
  project = "taki-test-project"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

resource "google_compute_instance" "master" {
  name         = "k8s-master"
  machine_type = var.machine.machine_type

  tags = ["home-lab-k8s-master"]

  boot_disk {
    initialize_params {
      image = var.machine.os
    }
  }

  network_interface {
    network    = google_compute_network.home_lab_network.id
    subnetwork = google_compute_subnetwork.home_lab_sub_network.id
    network_ip = google_compute_address.master_internal_ip_static.address
    access_config {
      nat_ip = google_compute_address.public_ip_addresses[0].address
    }
  }

  metadata = {
    ssh-keys = "taki:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_instance" "worker" {
  count        = 2
  name         = "k8s-worker-${count.index + 1}"
  machine_type = var.machine.machine_type

  tags = ["home-lab-k8s-worker"]

  boot_disk {
    initialize_params {
      image = var.machine.os
    }
  }

  network_interface {
    network    = google_compute_network.home_lab_network.id
    subnetwork = google_compute_subnetwork.home_lab_sub_network.id
    network_ip = google_compute_address.workers_internal_ip_static[count.index].address

    access_config {
      nat_ip = google_compute_address.public_ip_addresses[count.index + 1].address
    }
  }

  metadata = {
    ssh-keys = "taki:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/ansible_inventory.tpl", {
    ips = concat(
      [
        google_compute_instance.master.network_interface.0.access_config.0.nat_ip,
      ],
      [
        for instance in google_compute_instance.worker : instance.network_interface[0].access_config[0].nat_ip
      ]
    )
  })
  filename = "${path.module}/../ansible/inventory/inventory.yaml"
}
