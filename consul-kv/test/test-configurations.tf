locals {
  microservices = [
    "ms1"
  ]

  microservices_configurations = flatten([
    for microservice in local.microservices : [
      for file in fileset("${path.module}/microservices/${microservice}", "*.json") : {
        microservice_key_name = replace(file, ".json$", "")
        microservice_key_prefix = "${var.unit}/${microservice}/"
        microservice_configuration = file("${path.module}/microservices/${microservice}/${file}")
      }
    ]
  ])
}

module "ms1_values" {
  source = "git::https://github.com/deyanstoyanov10/consul-kv-module.git?ref=v0.0.1"

  for_each = local.microservices_configurations

  datacenter = "${var.dc}"
  key_path = "${each.microservice_key_prefix}${each.microservice_key_name}"
  key_value = each.microservice_configuration
}