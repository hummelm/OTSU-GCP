# Configuration du fournisseur Google Cloud
provider "google" {
  project = "votre-project-id"
  region  = "europe-west1"
}

# --- RESEAU ---

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-cours-informatique"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-web-db"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
}

# Règle Firewall pour le HTTP et le SSH (port 22)
resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-and-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"] # À restreindre en production
}

# --- INSTANCE WEB & LOAD BALANCER ---

resource "google_compute_instance" "web_instance" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata_startup_script = "apt-get update && apt-get install -y apache2"
}

# Groupe d'instances pour le Load Balancer
resource "google_compute_instance_group" "web_group" {
  name = "web-server-group"
  zone = "europe-west1-b"
  instances = [google_compute_instance.web_instance.id]
  named_port {
    name = "http"
    port = 80
  }
}

# --- COMPOSANTS DU LOAD BALANCER HTTP ---

resource "google_compute_global_forwarding_rule" "default" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "web-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "web-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "web-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group.web_group.id
  }

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name = "http-health-check"
  http_health_check {
    port = 80
  }
}
