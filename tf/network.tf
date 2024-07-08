resource "google_compute_network" "home_lab_network" {
  name                    = "home-lab-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "home_lab_sub_network" {
  name          = "cluster-subnet"
  ip_cidr_range = var.ranges.local_range
  network       = google_compute_network.home_lab_network.id
}

resource "google_compute_address" "public_ip_addresses" {
  count = 3
  name  = "node-${count.index + 1}-public-ip-address"
}

resource "google_compute_address" "master_internal_ip_static" {
  name         = "master-internal-ip-static"
  address      = var.internal_ips.master
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.home_lab_sub_network.id
}

resource "google_compute_address" "workers_internal_ip_static" {
  count        = 2
  name         = "worker-${count.index + 1}-internal-ip-static"
  address      = element(var.internal_ips.workers, count.index)
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.home_lab_sub_network.id
}

##### Firewall rules #####

# Allow internal traffic between cluster nodes
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.home_lab_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = [var.ranges.local_range]
}

###### ACCESS FROM THE INTERNET ######

## API SERVER to access the cluster from outside.
resource "google_compute_firewall" "external_api_server" {
  name    = "allow-access-to-api-server"
  network = google_compute_network.home_lab_network.id

  allow {
    protocol = "tcp"
    ports    = ["6443"] # for the API server
  }

  source_ranges = [var.ranges.global_range] # will be accessed from inside the cluster and from the internet
  target_tags   = ["home-lab-k8s-master"]
}

## NODE PORTS (workers)
resource "google_compute_firewall" "allow_access_through_node_ports" {
  name    = "allow-access-through-node-ports"
  network = google_compute_network.home_lab_network.id

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = [var.ranges.global_range]
  target_tags   = ["home-lab-k8s-worker"]
}

## SSH
resource "google_compute_firewall" "allow_external_ssh" {
  name    = "allow-external-ssh"
  network = google_compute_network.home_lab_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.ranges.global_range]
}
