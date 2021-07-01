locals {
  firewall_defaults = {
    "allow-gcp-healthchecks" = {
      target_tags = ["allow-gcp-healthcheck"]
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      direction     = "INGRESS"
      source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
      allow = {
        "tcp" = {
          protocol = "tcp"
        }
      }
    }
    "allow-internal-all-iapssh" = {
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["allow-iap-ssh"]
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      direction = "INGRESS"
      allow = {
        "tcp-ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
    "allow-internal-deny-all" = {
      target_tags = ["allow-internal-all"]
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      direction = "EGRESS"
      # Set up high priority so it can be easily overwriten by anything with standard priority (following fw rules)
      priority = 10000
      deny = {
        "all" = {
          protocol = "all"
        }
      }
    }
    "allow-https-all" = {
      target_tags = ["logging-proxy"]
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      direction = "EGRESS"
      allow = {
        "tcp-https" = {
          protocol = "tcp"
          ports    = ["443"]
        }
      }
    }
    "allow-fluentbit-all" = {
      target_tags = ["logging-proxy"]
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      direction = "INGRESS"
      allow = {
        "tcp-fluentbit" = {
          protocol = "tcp"
          ports    = ["24224", "5140"]
        }
      }
    }
    "allow-fluentd-all" = {
      target_tags = ["logging-proxy"]
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      direction = "EGRESS"
      allow = {
        "tcp-fluentd" = {
          protocol = "tcp"
          ports    = ["24224", "5140"] # for TLS, use 24284
        }
      }
    }
  }

  firewall = {
    "udino" = {
      "prd" = {
        "allow-pexip-conferencing" = {
          target_tags = ["pexip-conferencing"]
          log_config = {
            metadata = "EXCLUDE_ALL_METADATA"
          }
	  source_ranges = [
            "0.0.0.0/0"
          ]
          allow = {
            "tcp-http"      = { protocol = "tcp", ports = ["80"] }
            "tcp-https"     = { protocol = "tcp", ports = ["443"] }
            "tcp-1720"      = { protocol = "tcp", ports = ["1720"] }
            "tcp-5060"      = { protocol = "tcp", ports = ["5060"] }
            "tcp-5061"      = { protocol = "tcp", ports = ["5061"] }
            "tcp-ephemeral" = { protocol = "tcp", ports = ["33000-49999"] }
            "tcp-1719"      = { protocol = "udp", ports = ["1719"] } # TODO: tcp vs udp mismatch?
            "udp-ephemeral" = { protocol = "udp", ports = ["33000-49999"] }
          }
        }
        "allow-pexip-management" = {
          target_tags = ["pexip-management"]
          log_config = {
            metadata = "EXCLUDE_ALL_METADATA"
          }
	  ######################################################################
	  # consider to have an import of an admin range maintained in one file?
	  source_ranges = [
            "0.0.0.0/0"
          ]
          allow = {
            "tcp-https" = { protocol = "tcp", ports = ["443"] }
          }
        }
	######################################################################
	# consider to have an import of an admin range maintained in one file?
        "allow-pexip-provisioning" = {
          target_tags = ["pexip-provisioning"]
          log_config = {
            metadata = "EXCLUDE_ALL_METADATA"
          }
          source_ranges = [
            "0.0.0.0/0"
          ]
          allow = {
            "tcp-https" = { protocol = "tcp", ports = ["8443"] }
          }
        }
      }
      "dev" = {
      }
    }
  }
}
           