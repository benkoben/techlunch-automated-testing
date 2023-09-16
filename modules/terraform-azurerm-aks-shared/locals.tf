locals {
  container_registry = merge(
    var.container_registry,
    {
      network_rules = {
        ip_rules          = var.whitelist_ip
        whitelist_subnets = var.whitelist_subnets
      }
    }
  )
}
