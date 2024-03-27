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

resource "local_file" "dockerfile" {
    for_each = {
        Dockerfile1 = "Dockerfile1",
        Dockerfile2 = "Dockerfile2",
        Dockerfile3 = "Dockerfile3"
    }
    content = <<-EOF
    FROM python:3.7
    WORKDIR /app
    COPY . /app
    RUN pip install -r requirements.txt
    EXPOSE 5000
    CMD ["python", "app.py"]
  EOF
    filename = each.value
}

module "docker-container" {
    source = "./docker-container"
    for_each = { 
        image1 = { workdir = "echo", dockerfile = "Dockerfile1" },
        image2 = { workdir = "echo", dockerfile = "Dockerfile2" },
        image3 = { workdir = "echo", dockerfile = "Dockerfile3" }
    }

    docker-image-name = each.key
    docker-image-workdir = "${path.module}/${each.value.workdir}"
    docker-image-dockerfile = "${path.module}/${each.value.dockerfile}"
}