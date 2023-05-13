locals {
  microservices = [
    "ms1",
    "ms2"
  ]

  configuration_path = "${path.module}/microservices"

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

  for_each = fileset("${local.configuration_path}/ms1", "*.json")

  datacenter = "${var.dc}"
  key_path   = "${var.unit}/ms1/${replace(each.key, ".json", "")}"
  key_value  = file("${local.configuration_path}/ms1/${each.key}")
}

module "test_ms2" {
  source = "git::https://github.com/deyanstoyanov10/consul-kv-module.git?ref=v0.0.1"

  for_each = fileset("${local.configuration_path}/ms2", "*.json")

  datacenter = "${var.dc}"
  key_path   = "${var.unit}/ms2/${replace(each.key, ".json", "")}"
  key_value  = file("${local.configuration_path}/ms2/${each.key}")
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