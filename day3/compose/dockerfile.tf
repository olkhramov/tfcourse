resource "local_file" "echo_dockerfile" {
  filename = "${path.module}/echo/Dockerfile"
  content  = <<-EOF
    FROM python:3.7
    WORKDIR /app
    COPY . /app
    RUN pip install -r requirements.txt
    EXPOSE 5000
    CMD ["python", "app.py"]
  EOF
}

resource "local_file" "retrieve_dockerfile" {
  filename = "${path.module}/retrieve/Dockerfile"
  content  = <<-EOF
    FROM python:3.7
    WORKDIR /app
    COPY . /app
    RUN pip install -r requirements.txt
    EXPOSE 5000
    CMD ["python", "app.py"]
  EOF
}