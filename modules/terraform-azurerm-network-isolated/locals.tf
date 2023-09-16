locals {
  public_ip_prefixes = {
    for prefix in var.public_ip_prefixes : prefix.name => {
      name          = prefix.name
      prefix_length = prefix.prefix_length
    }
  }
}
