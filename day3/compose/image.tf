
resource "docker_image" "echo" {
  name = var.echo_image_name
  build {
    context    = "${path.module}/echo"
    tag        = ["${var.echo_image_name}:${var.echo_image_tag}"]
    dockerfile = "Dockerfile"
  }
  depends_on = [local_file.echo_dockerfile]
}

resource "docker_image" "retrieve" {
  name = var.retrieve_image_name
  build {
    context    = "${path.module}/echo"
    tag        = ["${var.retrieve_image_name}:${var.retrieve_image_tag}"]
    dockerfile = "Dockerfile"
  }
  depends_on = [local_file.echo_dockerfile]
}

resource "docker_container" "echo" {
  image = docker_image.echo.name
  name  = local.echo_name
  ports {
    internal = 5000
    external = 5000
  }

  networks_advanced {
    name    = docker_network.main-network.id
    aliases = ["echo"]
  }
}

resource "docker_container" "retrieve" {
  image = docker_image.retrieve.name
  name  = local.retrieve_name
  ports {
    internal = 5000
    external = 5001
  }
  volumes {
    container_path = "/data"
    host_path      = "${abspath("${path.module}/workdir/data")}"
    read_only      = true
  }
  networks_advanced {
    name    = docker_network.main-network.id
    aliases = ["retrieve"]
  }
}


resource "random_pet" "retrieve_name" {
  length    = 2
  separator = "-"
}

resource "random_pet" "echo_name" {
  length    = 2
  separator = "-"
}

locals {
  retrieve_name = random_pet.retrieve_name.id
  echo_name     = random_pet.echo_name.id
}

