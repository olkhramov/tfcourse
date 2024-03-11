terraform {

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

locals {
  sensitive_file_permission = "0600"
  directory_permission = "0755"
  output_directory = "output"
}

resource "random_pet" "pets" {
  count = 3
  separator = "_"
}

resource "random_password" "passwords" {
  count = 3
  length = 16
}

# Create a file dynamically
resource "local_sensitive_file" "password-file" {
  filename             = "${local.output_directory}/${random_pet.pets[0].id}.txt"
  content              = <<-EOT
    %{ for id, f in random_password.passwords ~}
    ${ id } password: ${ f.result }
    %{ endfor ~}
  EOT
  file_permission      = local.sensitive_file_permission
  directory_permission = local.directory_permission
}