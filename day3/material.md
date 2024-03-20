# Day 3

## Recap

- Unorthodox terraform providers
  - Local: manipulate local files & folders
  - Null: provider to bridge the gap between multiple providers or to wait for a resource to be created
  - Archive: create a zip or tarball of files
  - External: run external scripts
  - Random: generate random values
- Vendor specific providers
  - AWS
  - Azure
  - Google Cloud
  - Artifactory
- Docker provider to manage docker containers
  - [Docker provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- Variables - to parameterize the terraform code
- Data sources - to fetch data from external sources
- Locals - to define local variables
- Input variables - to take input from the user/other sources
- Output variables - to display output to the user/other sources

## Flow management & parameterization


Terraform has a built-in flow management system.
It allows for the use of variables, locals, and data sources.

Variables are useful for parameterizing the terraform code. But, but.
We may need to go deeper and instead of parameterizing the code with similar variables for common resources (3 containers - 3 different vars for name) - we can use count and for_each.

### Types 

The Terraform language uses the following types for its values:

- `string`: a sequence of Unicode characters representing some text, like "hello".
- `number`: a numeric value. The number type can represent both whole numbers like 15 and fractional values like 6.283185.
- `bool`: a boolean value, either true or false. bool values can be used in conditional logic.
- `list` (or tuple): a sequence of values, like ["us-west-1a", "us-west-1c"]. Identify elements in a list with consecutive whole numbers, starting with zero.
- `set`: a collection of unique values that do not have any secondary identifiers or ordering.
- `map` (or object): a group of values identified by named labels, like {name = "Mabel", age = 52}.


### For & for_each

For expressions are used to transform values in a list, map, or set into a new list, map, or set by applying an expression to each item in the original collection.
```terraform
[for s in var.list : upper(s)]
```

For_each is used to create multiple instances of a resource or module. It is used to iterate over a map or set of objects and create a resource for each object.
```terraform
locals {
    files = ["one.Dockerfile", "two.Dockerfile", "three.Dockerfile"]
}

resource "docker_image" "example" {
  for_each = local.files
  name = each.value
  build {
    context = "${path.module}/${each.value}"
  }
}
```

### Triggers

Triggers are a way to force a resource to be replaced or updated.
```terraform
triggers = {
    file_md5 = filemd5("${path.module}/example.txt")
}
```

### Count

```terraform
resource "docker_image" "example" {
  count = 3
  name = "example-${count.index}"
  build {
    context = "${path.module}/example"
  }
}
```

### Dynamic

```terraform
resource "docker_image" "example" {
  dynamic "build" {
    for_each = fileset("${path.module}/example", "*.Dockerfile")
    content {
      name = build.key
      build {
        context = "${path.module}/example"
      }
    }
  }
}
```
A dynamic block acts much like a for expression, but produces nested blocks instead of a complex typed value. It iterates over a given complex value, and generates a nested block for each element of that complex value.


The label of the dynamic block ("build" in the example above) specifies what kind of nested block to generate.
The for_each argument provides the complex value to iterate over.
The iterator argument (optional) sets the name of a temporary variable that represents the current element of the complex value. If omitted, the name of the variable defaults to the label of the dynamic block ("setting" in the example above).
The labels argument (optional) is a list of strings that specifies the block labels, in order, to use for each generated block. You can use the temporary iterator variable in this value.
The nested content block defines the body of each generated block. You can use the temporary iterator variable inside this block.

## Templates

Terraform has a built-in template rendering engine. It can be used to render files with variables.

```terraform
data "template_file" "example" {
  template = file("${path.module}/example.tpl")
  vars = {
    name = "example"
  }
}

resource "local_file" "example" {
  filename = "${path.module}/example.txt"
  content = data.template_file.example.rendered
}
```

Templates can use any of the Terraform language's built-in functions, including those for working with collections like `for` and `for_each`.

```terraform
data "template_file" "example" {
  template = <<EOF
  % for key, value in var.example:
  ${key} = ${value}
  % endfor
  EOF
  vars = {
    example = {
      key1 = "value1"
      key2 = "value2"
    }
  }
}
```


### Nginx configuration

```nginx

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```terraform

data "template_file" "nginx" {
  template = file("${path.module}/nginx.tpl")
  vars = {
    port = 8080
  }
}

resource "local_file" "nginx" {
  filename = "${path.module}/nginx.conf"
  content = data.template_file.nginx.rendered
}
```


### Exercises

1. Docker compose with dynamic blocks for containers
2. Mounting volumes with dynamic blocks
3. Nginx configuration with templates