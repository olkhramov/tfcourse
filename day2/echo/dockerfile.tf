resource "local_file" "dockerfile" {
  filename = "${path.module}/app/Dockerfile"
  content  = <<-EOF
    FROM python:3.7
    WORKDIR /app
    COPY . /app
    RUN pip install -r requirements.txt
    EXPOSE 5000
    CMD ["python", "app.py"]
  EOF
}