terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {
  host    = "unix:///home/olkhramov/.local/share/containers/podman/podman.sock"
}
