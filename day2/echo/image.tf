
resource "docker_image" "app" {
    name = var.docker_image_name
    build {
        context = "${path.module}/app"
        tag = ["${var.docker_image_name}:${var.docker_image_tag}"]
        dockerfile = "Dockerfile"
    }
    depends_on = [ local_file.dockerfile ]
}

resource "docker_container" "app" {
    image = docker_image.app.name
    name  = local.petname
    ports {
        internal = 5000
        external = 5000
    }
}

resource "random_pet" "container-name" {
}


locals {
    petname = random_pet.container-name.id
}

