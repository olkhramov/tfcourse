resource "docker_volume" "nginx-volume" {
  name = "nginx-volume"
  labels {
    label = "temporary"
    value = true
  }

  labels {
    label = "owner"
    value = "nginx"
  }
}


resource "docker_volume" "retrieve-volume" {
    name = "retrieve-volume"
    
    labels {
        label = "temporary"
        value = true
    }
    
    labels {
        label = "owner"
        value = "retrieve"
    }
}

