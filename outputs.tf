output "rest_password" {
  description = ""
  value       = module.wowza.rest_password
  sensitive   = true
}

output "stream_password" {
  description = ""
  value       = module.wowza.stream_password
  sensitive   = true
}

# output "lb_pip" {
#   description = "Public IP for LB - This needs to be added to https://github.com/hmcts/azure-public-dns"
#   value       = module.wowza.lb_pip
# }
