locals {
  region_map = {
    euw2 = "europe-west2"
    euw4 = "europe-west4"
  }
  # Defining subnets here so we can look them up based on environment variable
  # Subnet planning: https://teams.microsoft.com/l/channel/19%3Abbec70be612441048bee90d7cf13c209%40thread.tacv2/tab%3A%3Aca0989d3-8bdf-481b-a56b-b9431598d19b?groupId=4f558f27-2df5-4fa5-9368-7dc9f4e2af20&tenantId=66e34cd0-2ec3-4f44-a0d0-4dc5cad62531
  subnets = {
    ###################
    # PRD 10.0.0.0/23
    ###################
    "prd" = {
      "ksm-udino-euw4" = "10.128.108.0/23"
         }

    ###################
    # DEV 10.132.x.x/x
    ###################
    "dev" = {
#      "kinlycloud-shared-euw2" = "10.132.x.x/x"
    }
  }


  # These subnets should be created for all shared VPC projects for Kinly videocloud
  # Environment specific subnets can be defined in the vpc local variable below
  vpc_default_subnets = merge(
    { for region in ["euw4"] :
      format("ksm-%s-%s", var.customer, region) => {
        ip_cidr_range = local.subnets[var.environment]["${var.project}-${var.customer}-${region}"]
        region        = local.region_map[region]
        roles = {
          "roles/compute.networkUser" = {
            # Required to allow Terraform deploy SA to create resources using this subnet
            format("tf-ssono-cicd-%s-%s@%s.iam.gserviceaccount.com", var.customer, var.environment, local.cicd_gcp_project) = "serviceAccount"
          }
        }
      } if can(local.subnets[var.environment]["${var.project}-${var.customer}-${region}"])
    }
  )

  ###########################################
  # define defaults for all environments
  ###########################################
  vpc_defaults = {
    name    = "ksm"
    subnets = local.vpc_default_subnets,
    routes = {
      "default" = {
        description      = "Set default gateway for GCP resources so we can run health checks and use IAP SSH."
        dest_range       = "0.0.0.0/0"
        next_hop_gateway = "default-internet-gateway"
        priority         = "1"
      }
    }
  }

  vpc = {
    ###########################################
    # Environment specific config starts here
    ###########################################
    prd = {

    }
    dev = {

    }
  }
}