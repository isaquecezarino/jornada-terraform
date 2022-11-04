terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.dotoken
}

# Create a new Web Droplet in the nyc3 region
resource "digitalocean_droplet" "jenkins" {
  image    = "almalinux-9-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key_name.id]
}

data "digitalocean_ssh_key" "ssh_key_name" {
  name = var.ssh_key_name
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

# as variaveis abaixo estao no arquivo terraform.tfvars que não foi enviado ao github por questao de seguranca
variable "region" {
  default = ""
}

variable "dotoken" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

output "jenkinsIP" {
  value       = digitalocean_droplet.jenkins.ipv4_address
  description = "Jenkins IP"
}

resource "local_file" "jenkinsIP" {
  content = digitalocean_droplet.jenkins.ipv4_address
  filename = "JenkinsIP.txt"

}

resource "local_file" "kubeconfig" {
    content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}