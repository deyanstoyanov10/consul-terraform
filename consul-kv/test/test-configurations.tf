locals {
  ms1_configurations = fileset("${path.module}/microservices/ms1/*.json")
}

module "ms1_values" {
  source = "git::https://github.com/deyanstoyanov10/consul-kv-module.git?ref=v0.0.1"

  for_each = { for file in local.ms1_configurations : basename(file, ".json") => jsondecode(file("${path.module}/microservices/ms1/${file}")) }

  datacenter = "dev"
  key_path = "test/ms1/${each.key}"
  key_value = each.value
}