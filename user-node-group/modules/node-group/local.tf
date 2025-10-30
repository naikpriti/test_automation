locals {
  node_arch = "amd64"

  os_types = {
    "ubuntu"      = "Linux"
    "azurelinux"  = "Linux"
    "windows2019" = "Windows"
    "windows2022" = "Windows"
  }

  os_skus = {
    "ubuntu"      = "Ubuntu"
    "azurelinux"  = "AzureLinux"
    "windows2019" = "Windows2019"
    "windows2022" = "Windows2022"
  }

  vm_size_lookup = {
    "amd64_gp_default_v1" = {
      "large"    = "Standard_D2s_v4"
      "xlarge"   = "Standard_D4s_v4"
      "2xlarge"  = "Standard_D8s_v4"
      "4xlarge"  = "Standard_D16s_v4"
      "8xlarge"  = "Standard_D32s_v4"
      "12xlarge" = "Standard_D48s_v4"
      "16xlarge" = "Standard_D64s_v4"
    }


    "amd64_gp_default_v2" = {
      "large"    = "Standard_D2s_v5"
      "xlarge"   = "Standard_D4s_v5"
      "2xlarge"  = "Standard_D8s_v5"
      "4xlarge"  = "Standard_D16s_v5"
      "8xlarge"  = "Standard_D32s_v5"
      "12xlarge" = "Standard_D48s_v5"
      "16xlarge" = "Standard_D64s_v5"
      "24xlarge" = "Standard_D96s_v5"
    }

    "amd64_gp_intel_v3" = {
      "large"    = "Standard_D2s_v6"
      "xlarge"   = "Standard_D4s_v6"
      "2xlarge"  = "Standard_D8s_v6"
      "4xlarge"  = "Standard_D16s_v6"
      "8xlarge"  = "Standard_D32s_v6"
      "12xlarge" = "Standard_D48s_v6"
      "16xlarge" = "Standard_D64s_v6"
      "24xlarge" = "Standard_D96s_v6"
      "26xlarge" = "Standard_D104s_v6"
    }

    "amd64_gp_default_v3" = {
      "large"    = "Standard_D2s_v3"
      "xlarge"   = "Standard_D4s_v3"
      "2xlarge"  = "Standard_D8s_v3"
      "4xlarge"  = "Standard_D16s_v3"
      "8xlarge"  = "Standard_D32s_v3"
      "12xlarge" = "Standard_D48s_v3"
      "16xlarge" = "Standard_D64s_v3"
      "24xlarge" = "Standard_D96s_v3"
    }

    "amd64_gp_amd_v2" = {
      "large"    = "Standard_D2as_v5"
      "xlarge"   = "Standard_D4as_v5"
      "2xlarge"  = "Standard_D8as_v5"
      "4xlarge"  = "Standard_D16as_v5"
      "8xlarge"  = "Standard_D32as_v5"
      "12xlarge" = "Standard_D48as_v5"
      "16xlarge" = "Standard_D64as_v5"
      "24xlarge" = "Standard_D96as_v5"
    }

    "amd64_gp_amd_v3" = {
      "large"    = "Standard_D2as_v6"
      "xlarge"   = "Standard_D4as_v6"
      "2xlarge"  = "Standard_D8as_v6"
      "4xlarge"  = "Standard_D16as_v6"
      "8xlarge"  = "Standard_D32as_v6"
      "12xlarge" = "Standard_D48as_v6"
      "16xlarge" = "Standard_D64as_v6"
      "24xlarge" = "Standard_D96as_v6"
    }

    "arm64_gp_default_v1" = {
      "large"    = "Standard_D2ps_v5"
      "xlarge"   = "Standard_D4ps_v5"
      "2xlarge"  = "Standard_D8ps_v5"
      "4xlarge"  = "Standard_D16ps_v5"
      "8xlarge"  = "Standard_D32ps_v5"
      "12xlarge" = "Standard_D48ps_v5"
      "16xlarge" = "Standard_D64ps_v5"
      "24xlarge" = "Standard_D96ps_v5"
    }
    "arm64_gp_default_v2" = {
      "large"    = "Standard_D2ps_v6"
      "xlarge"   = "Standard_D4ps_v6"
      "2xlarge"  = "Standard_D8ps_v6"
      "4xlarge"  = "Standard_D16ps_v6"
      "8xlarge"  = "Standard_D32ps_v6"
      "12xlarge" = "Standard_D48ps_v6"
      "16xlarge" = "Standard_D64ps_v6"
      "24xlarge" = "Standard_D96ps_v6"
    }

    "amd64_gpd_default_v1" = {
      "large"    = "Standard_D2ds_v4"
      "xlarge"   = "Standard_D4ds_v4"
      "2xlarge"  = "Standard_D8ds_v4"
      "4xlarge"  = "Standard_D16ds_v4"
      "8xlarge"  = "Standard_D32ds_v4"
      "12xlarge" = "Standard_D48ds_v4"
      "16xlarge" = "Standard_D64ds_v4"
    }

    "amd64_gpd_default_v2" = {
      "large"    = "Standard_D2ds_v5"
      "xlarge"   = "Standard_D4ds_v5"
      "2xlarge"  = "Standard_D8ds_v5"
      "4xlarge"  = "Standard_D16ds_v5"
      "8xlarge"  = "Standard_D32ds_v5"
      "12xlarge" = "Standard_D48ds_v5"
      "16xlarge" = "Standard_D64ds_v5"
      "24xlarge" = "Standard_D96ds_v5"
    }

    "amd64_gpd_intel_v3" = {
      "large"    = "Standard_D2ds_v6"
      "xlarge"   = "Standard_D4ds_v6"
      "2xlarge"  = "Standard_D8ds_v6"
      "4xlarge"  = "Standard_D16ds_v6"
      "8xlarge"  = "Standard_D32ds_v6"
      "12xlarge" = "Standard_D48ds_v6"
      "16xlarge" = "Standard_D64ds_v6"
      "24xlarge" = "Standard_D96ds_v6"
      "26xlarge" = "Standard_D104ds_v6"
    }

    "amd64_gpd_v2" = {
      "large"    = "Standard_D2ads_v5"
      "xlarge"   = "Standard_D4ads_v5"
      "2xlarge"  = "Standard_D8ads_v5"
      "4xlarge"  = "Standard_D16ads_v5"
      "8xlarge"  = "Standard_D32ads_v5"
      "12xlarge" = "Standard_D48ads_v5"
      "16xlarge" = "Standard_D64ads_v5"
      "24xlarge" = "Standard_D96ads_v5"
    }

    "amd64_gpd_amd_v3" = {
      "large"    = "Standard_D2ads_v6"
      "xlarge"   = "Standard_D4ads_v6"
      "2xlarge"  = "Standard_D8ads_v6"
      "4xlarge"  = "Standard_D16ads_v6"
      "8xlarge"  = "Standard_D32ads_v6"
      "12xlarge" = "Standard_D48ads_v6"
      "16xlarge" = "Standard_D64ads_v6"
      "24xlarge" = "Standard_D96ads_v6"
    }

    "arm64_gpd_default_v1" = {
      "large"    = "Standard_D2pds_v5"
      "xlarge"   = "Standard_D4pds_v5"
      "2xlarge"  = "Standard_D8pds_v5"
      "4xlarge"  = "Standard_D16pds_v5"
      "8xlarge"  = "Standard_D32pds_v5"
      "12xlarge" = "Standard_D48pds_v5"
      "16xlarge" = "Standard_D64pds_v5"
      "24xlarge" = "Standard_D96pds_v5"
    }

    "arm64_gpd_default_v2" = {
      "large"    = "Standard_D2pds_v6"
      "xlarge"   = "Standard_D4pds_v6"
      "2xlarge"  = "Standard_D8pds_v6"
      "4xlarge"  = "Standard_D16pds_v6"
      "8xlarge"  = "Standard_D32pds_v6"
      "12xlarge" = "Standard_D48pds_v6"
      "16xlarge" = "Standard_D64pds_v6"
      "24xlarge" = "Standard_D96pds_v6"
    }

    "amd64_mem_default_v1" = {
      "large"    = "Standard_E2s_v4"
      "xlarge"   = "Standard_E4s_v4"
      "2xlarge"  = "Standard_E8s_v4"
      "4xlarge"  = "Standard_E16s_v4"
      "8xlarge"  = "Standard_E32s_v4"
      "12xlarge" = "Standard_E48s_v4"
      "16xlarge" = "Standard_E64s_v4"
    }

    "amd64_mem_default_v2" = {
      "large"    = "Standard_E2s_v5"
      "xlarge"   = "Standard_E4s_v5"
      "2xlarge"  = "Standard_E8s_v5"
      "4xlarge"  = "Standard_E16s_v5"
      "8xlarge"  = "Standard_E32s_v5"
      "12xlarge" = "Standard_E48s_v5"
      "16xlarge" = "Standard_E64s_v5"
      "24xlarge" = "Standard_E96s_v5"
      "26xlarge" = "Standard_E104s_v5"
    }

    "amd64_mem_amd_v2" = {
      "large"    = "Standard_E2as_v5"
      "xlarge"   = "Standard_E4as_v5"
      "2xlarge"  = "Standard_E8as_v5"
      "4xlarge"  = "Standard_E16as_v5"
      "8xlarge"  = "Standard_E32as_v5"
      "12xlarge" = "Standard_E48as_v5"
      "16xlarge" = "Standard_E64as_v5"
      "24xlarge" = "Standard_E96as_v5"
      "26xlarge" = "Standard_E104as_v5"
    }

    "arm64_mem_default_v1" = {
      "large"   = "Standard_E2ps_v5"
      "xlarge"  = "Standard_E4ps_v5"
      "2xlarge" = "Standard_E8ps_v5"
      "4xlarge" = "Standard_E16ps_v5"
      "8xlarge" = "Standard_E32ps_v5"
    }

    "amd64_memd_default_v1" = {
      "large"    = "Standard_E2ds_v4"
      "xlarge"   = "Standard_E4ds_v4"
      "2xlarge"  = "Standard_E8ds_v4"
      "4xlarge"  = "Standard_E16ds_v4"
      "8xlarge"  = "Standard_E32ds_v4"
      "12xlarge" = "Standard_E48ds_v4"
      "16xlarge" = "Standard_E64ds_v4"
    }

    "amd64_memd_default_v2" = {
      "large"    = "Standard_E2ds_v5"
      "xlarge"   = "Standard_E4ds_v5"
      "2xlarge"  = "Standard_E8ds_v5"
      "4xlarge"  = "Standard_E16ds_v5"
      "8xlarge"  = "Standard_E32ds_v5"
      "12xlarge" = "Standard_E48ds_v5"
      "16xlarge" = "Standard_E64ds_v5"
      "24xlarge" = "Standard_E96ds_v5"
      "26xlarge" = "Standard_E104ds_v5"
    }

    "amd64_gpu_amd_v1" = {
      "xlarge"   = "Standard_NC4as_T4_v3"
      "2xlarge"  = "Standard_NC8as_T4_v3"
      "4xlarge"  = "Standard_NC16as_T4_v3"
      "16xlarge" = "Standard_NC64as_T4_v3"
    }

    "amd64_memd_amd_v2" = {
      "large"    = "Standard_E2ads_v5"
      "xlarge"   = "Standard_E4ads_v5"
      "2xlarge"  = "Standard_E8ads_v5"
      "4xlarge"  = "Standard_E16ads_v5"
      "8xlarge"  = "Standard_E32ads_v5"
      "12xlarge" = "Standard_E48ads_v5"
      "16xlarge" = "Standard_E64ads_v5"
      "24xlarge" = "Standard_E96ads_v5"
      "26xlarge" = "Standard_E104ads_v5"
    }

    "arm64_memd_default_v1" = {
      "large"   = "Standard_E2pds_v5"
      "xlarge"  = "Standard_E4pds_v5"
      "2xlarge" = "Standard_E8pds_v5"
      "4xlarge" = "Standard_E16pds_v5"
      "8xlarge" = "Standard_E32pds_v5"
    }

    "amd64_cpu_default_v1" = {
      "large"    = "Standard_F2s_v2"
      "xlarge"   = "Standard_F4s_v2"
      "2xlarge"  = "Standard_F8s_v2"
      "4xlarge"  = "Standard_F16s_v2"
      "8xlarge"  = "Standard_F32s_v2"
      "12xlarge" = "Standard_F48s_v2"
      "16xlarge" = "Standard_F64s_v2"
      "18xlarge" = "Standard_F72s_v2"
    }

    "amd64_stor_default_v1" = {
      "2xlarge"  = "Standard_L8s_v2"
      "4xlarge"  = "Standard_L16s_v2"
      "8xlarge"  = "Standard_L32s_v2"
      "12xlarge" = "Standard_L48s_v2"
      "16xlarge" = "Standard_L64s_v2"
      "20xlarge" = "Standard_L80s_v2"
    }

    "amd64_stor_default_v2" = {
      "2xlarge"  = "Standard_L8s_v3"
      "4xlarge"  = "Standard_L16s_v3"
      "8xlarge"  = "Standard_L32s_v3"
      "12xlarge" = "Standard_L48s_v3"
      "16xlarge" = "Standard_L64s_v3"
      "20xlarge" = "Standard_L80s_v3"
    }

    "amd64_stor_amd_v2" = {
      "2xlarge"  = "Standard_L8as_v3"
      "4xlarge"  = "Standard_L16as_v3"
      "8xlarge"  = "Standard_L32as_v3"
      "12xlarge" = "Standard_L48as_v3"
      "16xlarge" = "Standard_L64as_v3"
      "20xlarge" = "Standard_L80as_v3"
    }

    "amd64_laosv4_default_v1" = {
      "large"   = "Standard_L2aos_v4"
      "xlarge"  = "Standard_L4aos_v4"
      "2xlarge" = "Standard_L8aos_v4"
      "3xlarge" = "Standard_L12aos_v4"
      "4xlarge" = "Standard_L16aos_v4"
      "6xlarge" = "Standard_L24aos_v4"
      "8xlarge" = "Standard_L32aos_v4"
    }
  }

  temp_disk_size_lookup = {
    "gpd" = {
      "large"    = 75
      "xlarge"   = 150
      "2xlarge"  = 300
      "4xlarge"  = 600
      "8xlarge"  = 1200
      "12xlarge" = 1800
      "16xlarge" = 2400
      "24xlarge" = 3600
    }
    "memd" = {
      "large"    = 75
      "xlarge"   = 150
      "2xlarge"  = 300
      "4xlarge"  = 600
      "8xlarge"  = 1200
      "12xlarge" = 1800
      "16xlarge" = 2400
      "24xlarge" = 3600
      "26xlarge" = 3800
    }
    "stor" = {
      "2xlarge"  = 80
      "4xlarge"  = 160
      "8xlarge"  = 320
      "12xlarge" = 480
      "16xlarge" = 640
      "20xlarge" = 800
    }
    "laosv4" = {
      "large"   = 480  # L2aos_v4: 480GB NVMe (3 disks)
      "xlarge"  = 960  # L4aos_v4: 960GB NVMe (3 disks)
      "2xlarge" = 960  # L8aos_v4: 960GB NVMe (6 disks)
      "3xlarge" = 960  # L12aos_v4: 960GB NVMe (9 disks)
      "4xlarge" = 1920 # L16aos_v4: 1920GB NVMe (6 disks)
      "6xlarge" = 1920 # L24aos_v4: 1920GB NVMe (9 disks)
      "8xlarge" = 1920 # L32aos_v4: 1920GB NVMe (12 disks)
    }
  }

  vm_labels = {
    "gp"     = {}
    "gpd"    = { "lnrs.io/local-storage" = "true", "node.lnrs.io/temp-disk" = "true", "node.lnrs.io/temp-disk-mode" = var.temp_disk_mode }
    "mem"    = {}
    "gpu"    = {}
    "memd"   = { "lnrs.io/local-storage" = "true", "node.lnrs.io/temp-disk" = "true", "node.lnrs.io/temp-disk-mode" = var.temp_disk_mode }
    "cpu"    = {}
    "stor"   = { "lnrs.io/local-storage" = "true", "node.lnrs.io/temp-disk" = "true", "node.lnrs.io/temp-disk-mode" = var.temp_disk_mode, "node.lnrs.io/nvme" = "true", "node.lnrs.io/nvme-mode" = var.nvme_mode }
    "laosv4" = { "lnrs.io/local-storage" = "true", "node.lnrs.io/temp-disk" = "true", "node.lnrs.io/temp-disk-mode" = var.temp_disk_mode, "node.lnrs.io/nvme" = "true", "node.lnrs.io/nvme-mode" = var.nvme_mode }
  }

  vm_taints = {
    "gp"     = []
    "gpd"    = []
    "gpu"    = []
    "mem"    = []
    "memd"   = []
    "cpu"    = []
    "stor"   = []
    "laosv4" = []
  }

  max_pods = {
    "kubenet"       = 110
    "azure_overlay" = 110
    "azure"         = 30
  }

  taint_effects = {
    "NO_SCHEDULE"        = "NoSchedule"
    "NO_EXECUTE"         = "NoExecute"
    "PREFER_NO_SCHEDULE" = "PreferNoSchedule"
  }

  auto_scaling = var.max_capacity > 0 && var.min_capacity != var.max_capacity
}
