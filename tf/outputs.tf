output "nodes_ips" {
  value = {
    master_ip = {
      public_ip   = google_compute_instance.master.network_interface.0.access_config.0.nat_ip
      internal_ip = google_compute_instance.master.network_interface.0.network_ip
    }
    worker_ips = {
      public_ips   = [for i in google_compute_instance.worker : i.network_interface.0.access_config.0.nat_ip]
      internal_ips = [for i in google_compute_instance.worker : i.network_interface.0.network_ip]
    }
  }
}
