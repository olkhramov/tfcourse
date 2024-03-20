#  user_data               = templatefile("script.tftpl", { request_id = "REQ000129834", name = "John" })
 

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

resource "local_file" "nginx_config" {
    filename = "${local.output_directory}/nginx_config.conf"
    content  = templatefile("${path.module}/nginx.tftpl", {
        containers = [
            {
                name = "echo",
                port = 5000
            },
            {
                name = "retrieve",
                port = 5001
            }
        ]
    })
    file_permission      = local.sensitive_file_permission
    directory_permission = local.directory_permission
} 