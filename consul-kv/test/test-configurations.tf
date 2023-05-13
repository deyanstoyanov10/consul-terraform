locals {
  microservices = [
    "ms1",
    "ms2"
  ]

  configuration_path = "${path.module}/microservices/"

  microservices_configurations = flatten([
    for microservice in local.microservices : [
      for file in fileset("${path.module}/microservices/${microservice}", "*.json") : {
        microservice_key_name = replace(file, ".json", "")
        microservice_key_prefix = "${var.unit}/${microservice}"
        microservice_configuration = file("${path.module}/microservices/${microservice}/${file}")
      }
    ]
  ])

  
}

module "test_ms1" {
  source = "git::https://github.com/deyanstoyanov10/consul-kv-module.git?ref=v0.0.1"

  microservice_name = "ms1"
  for_each = fileset("${configuration_path}${microservice_name}", "*.json")
  microservice_key_name = replace(each.key, ".json", "")

  datacenter = "${var.dc}"
  key_path   = "${var.unit}/${microservice_name}/${microservice_key_name}"
  key_value  = file("${configuration_path}${microservice_name}/${each.key}")
}

//module "test_unit_configurations" {
//  source = "git::https://github.com/deyanstoyanov10/consul-kv-module.git?ref=v0.0.1"
//
//  for_each = { for entry in local.microservices_configurations : "${entry.microservice_key_name}.${entry.microservice_key_prefix}.${entry.microservice_configuration}" => entry }
//
//  datacenter = "${var.dc}"
//  key_path = "${each.value.microservice_key_prefix}/${each.value.microservice_key_name}"
//  key_value = each.value.microservice_configuration
//}