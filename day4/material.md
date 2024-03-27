# Day 4


## Recap

- Terraform has some built in data types, namely `string`, `number`, `bool`, `list`, `map`, `object`, `set`, and `tuple`.
- `for` and `for_each` are used to iterate over lists, maps, and sets.
- `count` is used to create multiple instances of a resource.
- `triggers` are used to force a resource to be replaced or updated.
- `dynamic` is used to create multiple instances of a resource or module based on a set of objects.
- Rich templates can be used to generate complex configurations.
- Terraform has a rich set of functions that can be used to manipulate data.


## Outiline

- More on functions
- Modules
- Public modules
- Cycling back to the infrastructure as code


## A word on functions

Rich set of functions include:

- File functions 
  - `file` - Read a file from disk.
  ```terraform
  data "file" "example" {
    filename = "example.txt"
  }
  ```

  - `fileset` - List files in a directory.
  ```terraform
  data "fileset" "example" {
    path = "example"
  }
  ```
  
  - Various hashing functions - `md5`, `sha1`, `sha256`, `sha512`.
  ```terraform
  resource "local_file" "example" {
    content  = md5("example")
    filename = "example.txt"
  }
  ```
- String manipulation functions:
  - `format` - Format a string.
  - `join` - Join a list of strings.
  - `lower` - Convert a string to lowercase.
  - `replace` - Replace a substring in a string.
  - `split` - Split a string into a list.
  - `substr` - Get a substring from a string.
  - `title` - Convert a string to title case.
  - `trim` - Trim whitespace from a string.
  - `upper` - Convert a string to uppercase.
  - `chomp` - Remove trailing newline characters.
  - `regex` - Perform a regular expression match.
  - `regexall` - Perform a regular expression match and return all matches.
  - `trimspace` - Trim leading and trailing whitespace.
  - `trimprefix` - Trim a prefix from a string.
  - `trimsuffix` - Trim a suffix from a string.
  - `indent` - Indent a string.
  - `strrev` - Reverse a string.
- Numeric functions:
  - `abs` - Get the absolute value of a number.
  - `ceil` - Round up to the nearest integer.
  - `floor` - Round down to the nearest integer.
  - `max` - Get the maximum value from a list of numbers.
  - `min` - Get the minimum value from a list of numbers.
  - `pow` - Raise a number to a power.
  - `signum` - Get the sign of a number.
- IP Network functions - `cidrhost`, `cidrnetmask`, `cidrsubnet`, `cidrsubnets`.

```terraform
cidrhost("10.0.0.0/8", 2)

cidrnetmask(24)
cidrsubnet("10.1.2.0/24", 4, 15)
cidrsubnets("10.1.0.0/16", 4, 4, 8, 4)
```

- Date & time functions - `formatdate`, `parseintime`, `timeadd`, `timestamp`, `timeutc`, `timeadd`, `timeformat`, `timeparse`

```terraform
formatdate("YYYY-MM-DD", "2021-01-01T00:00:00Z")
parseintime("YYYY-MM-DD", "2021-01-01")
timeadd("2021-01-01T00:00:00Z", "1h")
timestamp()
timeutc()
timeadd("2021-01-01T00:00:00Z", "1h")
timeformat("YYYY-MM-DD", "2021-01-01T00:00:00Z")
timeparse("2021-01-01T00:00:00Z")
```


## Modules

Modules are a way to organize your Terraform configuration into reusable components

```terraform
module "example" {
  source = "./example"
}
```

Modules can be used to create reusable components that can be shared across multiple configurations.

```terraform
module "example" {
  source = "github.com/username/repo"
}
```

In addition to that you're free to use meta arguments with modules. 
Namely, `count`, `for_each`, and `providers`.
Also you can explicitly specify the `depends_on` argument to ensure that a module is created after another module.

```terraform
module "example" {
  source = "./example"
  count = 3
  depends_on = [module.other]
}
```

## Public modules

Public modules are modules that are published to the Terraform Registry.
In addition it supports pretty much any Git server, including GitHub, GitLab, and Bitbucket.
Mercurial is also supported.

```terraform

module "example" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.0.0"
}
```

## Cycling back to the infrastructure as code

Especially in the context of public modules, you may need (and you're strongly encouraged by me) to double and triple verify that module does what you expect.

Namely, I'm referring to the following tools:

- Rover - visualization tool.
- Terraform graph - messy and hard to read, but still useful.
- Inframap - visualization tool that omits special objects we don't care about.

### Inframap 

Useful in case of cloud infrastructure.
Renders only notable, imporant resources.
We may not care about every single resource - directory, app registration, etc.

[Inframap](https://github.com/cycloidio/inframap)


Generate Dot diagram:
```bash
docker run --rm -v ${PWD}:/opt cycloid/inframap generate /opt/terraform.tfstate
```

Generate PNG:
```bash
docker run --rm -v ${PWD}:/opt --entrypoint "/bin/ash" inframap -c './inframap generate /opt/PATH_TO_HCL_STATE | dot -Tpng > /opt/graph.png'
```



