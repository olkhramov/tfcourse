resource "docker_network" "main-network" {
  name = "containers"
  driver = "bridge"
}
