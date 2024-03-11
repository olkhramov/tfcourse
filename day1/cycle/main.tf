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

resource "local_file" "output1" {
    filename = "${local.output_directory}/file1.txt"
    file_permission = local.directory_permission
    directory_permission = local.directory_permission
    content = local_file.output2.content
}

resource "local_file" "output2" {
    filename = "${local.output_directory}/file2.txt"
    file_permission = local.directory_permission
    directory_permission = local.directory_permission
    depends_on = [ local_file.output1 ]
}