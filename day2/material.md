# Day 2

- Terraform providers
  - Docker
  - Local
  - Archive
- Unorthodox terraform providers
- Vendor specific providers
- Variables & inputs
- Terraform state
- Exercices
  - Docker provider
  - Local provider
  - Multiple providers

## Recap

- Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.
- Terraform uses HCL (HashiCorp Configuration Language) to define the infrastructure.
- `main.tf` is the commonly used name for the main configuration file.
- Providers are the plugins that Terraform uses to manage resources.
- Providers are specified in the `provider` block.
- Providers are responsible for understanding API interactions and exposing resources.
- Resource names are mapped to provider names.
- Provider can be specified explicitly per resource.
- Backend is the place where Terraform stores the state of the infrastructure.
- Terraform state is a snapshot of the infrastructure's state at a certain point in time.
- Terraform state is used to map Terraform-managed resources to real-world resources.
- Visualization tools are abundant for Terraform.
- Rover is a tool for visualizing Terraform state and plan.
- Cycles are bad


## Unorthodox terraform providers

Terraform is a flexible tool, most providers are designed to manage cloud infrastructure, but it's not limited to that. Terraform could manage anything.

One example of unorthodox provider is the `local` provider. It's a provider that allows you to manage local resources.

### Null

[null](https://registry.terraform.io/providers/hashicorp/null/latest/docs)

Another example is the `null` provider. It quite literally does nothing. It's main usecase is to be used as a bridge or wait for another resource to get created.

```terraform
resource "aws_instance" "cluster" {
  count         = 3
  ami           = "ami-0dcc1e21636832c5d"
  instance_type = "m5.large"

  # ...
}

# The primary use-case for the null resource is as a do-nothing container
# for arbitrary actions taken by a provisioner.
#
# In this example, three EC2 instances are created and then a
# null_resource instance is used to gather data about all three
# and execute a single action that affects them all. Due to the triggers
# map, the null_resource will be replaced each time the instance ids
# change, and thus the remote-exec provisioner will be re-run.
resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = join(",", aws_instance.cluster[*].id)
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = element(aws_instance.cluster[*].public_ip, 0)
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "bootstrap-cluster.sh ${join(" ",
      aws_instance.cluster[*].private_ip)}",
    ]
  }
}
```

### Archive

[Archive docs](https://registry.terraform.io/providers/hashicorp/archive/latest/docs)

The `archive` provider is another example of an unorthodox provider. It's used to create a zip or tarball of files.

```terraform
resource "archive_file" "example" {
  type        = "zip"
  source_dir  = "${path.module}/files"
  output_path = "${path.module}/example.zip"
}
```

### External

[External docs](https://registry.terraform.io/providers/hashicorp/external/latest/docs)

It's used to use output of other programs, commands or scripts as a resource.

```terraform
resource "external" "example" {
  program = ["python", "${path.module}/example.py"]
  query = {
    key1 = "value1"
    key2 = "value2"
  }
}
```

## Vendor specific providers

Terraform in recent years has become a de-facto standard for infrastructure as code.
Cloud providers are now providing their own terraform providers.
This allows for easier management of cloud resources, and simplifies the process of managing cloud resources for developers and operators.

### AWS

[AWS docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

```terraform
provider "aws" {
  region = "us-west-2"
}
```

### Azure

[Azure docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

```terraform
provider "azurerm" {
  features {}
}
```


### Google Cloud

[Google Cloud docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

```terraform
provider "google" {
  project = "acme-app"
  region  = "us-central1"
}
```

### Digital Ocean

[Digital ocean provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)

```terraform
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a web server
resource "digitalocean_droplet" "web" {
  # ...
}
```

### Artifactory

[Artifactory provider](https://registry.terraform.io/providers/jfrog/artifactory/latest/docs)

```terraform
terraform {
  required_providers {
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "10.0.2"
    }
  }
}

# Configure the Artifactory provider
provider "artifactory" {
  url           = "${var.artifactory_url}/artifactory"
  access_token  = "${var.artifactory_access_token}"
}
```

## Variables & inputs

### Variables

Variables are used to parameterize the configuration. They are defined in a `.tf` file and can be used in other `.tf` files.

```terraform
variable "region" {
  description = "The region in which to create the resources"
  type        = string
  default     = "us-west-2"
}
```

### Inputs

Inputs are used to pass values to the terraform configuration. They are defined in a `.tfvars` file.

```terraform
region = "us-west-2"
```

### Outputs

Outputs are used to define the values that are to be exposed to the user.

```terraform
output "region" {
  value = var.region
}
```

### Local values

Local values are used to define a value that can be reused throughout the configuration.

```terraform
locals {
  region = "us-west-2"
}
```

Also they can be used as a placeholder for a complex value.

```terraform
locals {
  tags = {
    Name        = "example"
    Environment = "dev"
  }
}
```

> Local values are not to be used as a replacement for variables. They are to be used to define a value that can be reused throughout the configuration.
>
> Local values are stored in the state.

Local values can be thought of as variables in the function scope.


## State

Terraform state is a snapshot of the infrastructure's state at a certain point in time. Terraform state is used to map Terraform-managed resources to real-world resources.

If we're using a local backend, the terraform state is stored in a file named `terraform.tfstate` (or any other file you've specified in the configuration). This file is created when you run `terraform apply` and is used to map the resources to the configuration.


## Exercises

1. Create a docker container using the docker provider.
2. Parametrize the docker file with locals & variables.
   1. Change the base image to a variable.
   2. Change the port to a variable.
3. Extract tarball or zip and use files as configs for the docker container.
4. Emulate docker compose with terraform.
   1. Create a network.
   2. Create a volume.
   3. Create two containers
      1. Echo server
      2. JSON retriever: server that would serve set of json files from a directory (volume).
   4. Use the network and volume to connect the containers.
