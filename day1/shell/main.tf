terraform {

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
  }
}

data "shell_script" "user" {
    lifecycle_commands {
        read = <<-EOF
          echo "{\"user\": \"$(whoami)\"}"
        EOF
    }
}
# "user" can be accessed like a normal Terraform map
output "user" {
    value = data.shell_script.user.output["user"]
}

resource "shell_script" "weather" {
  lifecycle_commands {
    read =  file("${path.module}/weather.sh")
    create =  file("${path.module}/weather.sh")
    delete =  file("${path.module}/weather.sh")
  }
   interpreter = ["/bin/bash", "-c"]
}

# value is: "SanFrancisco: ⛅️ +54°F"
output "weather" {
  value = resource.shell_script.weather.output["SanFrancisco"]
}