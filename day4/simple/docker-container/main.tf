resource "docker_image" "image" {
  name = var.docker-image-name
  build {
    context    = "${var.docker-image-workdir}"
    tag        = ["${var.docker-image-name}:${var.docker-image-tag}"]
    dockerfile = "${var.docker-image-dockerfile}"
  }
}


variable "docker-image-name" {
    type = string
}

variable "docker-image-workdir" {
    type = string
    default = "."
}

variable "docker-image-tag" {
  type = string
  default = "latest"
}

variable "docker-image-dockerfile" {
  
}

output docker-image-id {
    value = resource.docker_image.image.name
}