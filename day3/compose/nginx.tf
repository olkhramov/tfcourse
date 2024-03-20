resource "docker_image" "nginx" {
  name = "nginx:alpine"
}


resource "docker_container" "nginx" {
  image = docker_image.nginx.name
  name  = "nginx"
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    container_path = "/usr/share/nginx/html"
  host_path      = "${abspath("${path.module}/workdir/nginx")}"
    read_only      = true
  }
  networks_advanced {
    name    = docker_network.main-network.id
    aliases = ["nginx", "webserver"]
  }
}


resource "local_file" "nginx_conf" {
  filename = "${path.module}/workdir/nginx/default.conf"
  content  = <<-EOF
  
    http {
        upstream ${local.echo_name} {
            server ${local.echo_name}:5000;
        }

        upstream ${local.retrieve_name} {
            server ${local.retrieve_name}:5000;
        }

        server {
            listen 80;

            location /${local.retrieve_name}/ {
                proxy_pass http:///${local.retrieve_name};
            }

            location /${local.echo_name}/ {
                proxy_pass http:///${local.echo_name};
            }
        }
    }
EOF

}
