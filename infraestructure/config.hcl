consul {
  retry {
    enabled = false
    attempts = 1
    backoff = "30ms"
    max_backoff = "1m"
  }
}

wait = "0s:15s"
pid_file = "/var/run/consul-template.pid"

deduplicate {
  enabled = true
  prefix = "consul-template/dedup/"
}