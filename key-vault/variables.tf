#version: v1.3.0

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  nullable    = true
}


variable "location" {
  description = "Azure region in which to build resources."
  type        = string
  nullable    = true
}

variable "key_vault_name" {
  description = "Key Vault Name"
  type        = string
}

variable "tags" {
  description = "Tags for Key Vault"
  type        = map(string)
  default     = {}
}

variable "azure_allowed_ip_list" {
  type    = list(any)
default = ["20.42.64.3/30", "20.85.14.70/32", "20.5.194.220/32", "20.11.28.220/31", "40.121.67.30/32", "172.191.219.248/30", "13.82.71.152/32", "20.88.154.20/31", "40.71.10.204/31", "40.71.13.128/28", "40.117.134.189/32", "40.121.13.26/32", "52.224.186.99/32", "13.82.93.245/32", "13.82.101.179/32", "13.82.175.96/32", "13.90.143.69/32", "13.90.213.204/32", "13.92.139.214/32", "13.92.193.110/32", "13.92.237.218/32", "20.42.26.252/32", "20.49.104.0/25", "20.119.0.0/20", "20.119.16.0/21", "20.119.27.0/25", "23.96.0.52/32", "23.96.1.109/32", "23.96.13.243/32", "23.96.32.128/32", "23.96.96.142/32", "23.96.103.159/32", "23.96.112.53/32", "23.96.113.128/32", "23.96.124.25/32", "40.71.0.179/32", "40.71.11.128/25", "40.71.177.34/32", "40.71.199.117/32", "40.71.234.254/32", "40.71.250.191/32", "40.76.5.137/32", "40.76.192.15/32", "40.76.210.54/32", "40.76.218.33/32", "40.76.223.101/32", "40.79.154.192/27", "40.85.190.10/32", "40.87.65.131/32", "40.87.70.95/32", "40.114.13.25/32", "40.114.41.245/32", "40.114.51.68/32", "40.114.68.21/32", "40.114.106.25/32", "40.117.154.240/32", "40.117.188.126/32", "40.117.190.72/32", "40.121.8.241/32", "40.121.16.193/32", "40.121.32.232/32", "40.121.35.221/32", "40.121.91.199/32", "40.121.212.165/32", "40.121.221.52/32", "52.168.125.188/32", "52.170.7.25/32", "52.170.46.174/32", "52.179.97.15/32", "52.226.134.64/32", "52.234.209.94/32", "104.45.129.178/32", "104.45.141.247/32", "104.45.152.13/32", "104.45.152.60/32", "104.45.154.200/32", "104.211.26.212/32", "137.117.58.204/32", "137.117.66.167/32", "137.117.84.54/32", "137.117.90.63/32", "137.117.93.87/32", "137.135.91.176/32", "137.135.107.235/32", "168.62.48.183/32", "168.62.180.173/32", "191.236.16.12/32", "191.236.59.67/32", "191.237.24.89/32", "191.237.27.74/32", "191.238.8.26/32", "191.238.33.50/32", "20.42.68.128/26", "20.88.157.128/28", "40.71.13.64/26", "52.224.105.172/32", "191.236.60.72/32", "13.90.194.180/32", "20.42.65.86/31", "20.42.74.230/32", "20.42.74.232/30", "20.49.109.32/30", "40.71.15.194/32", "52.146.79.132/30", "52.168.118.130/32", "137.135.98.137/32", "172.172.252.64/29", "172.172.252.72/31", "20.62.129.148/30", "40.71.15.204/30", "20.62.133.128/25", "20.62.134.0/26", "40.71.12.0/25", "40.71.12.128/26", "40.78.227.64/26", "40.78.227.128/25", "40.79.155.64/26", "40.79.155.128/25", "20.42.0.64/30", "40.71.12.244/30", "20.42.4.128/26", "20.42.24.90/32", "20.42.29.212/32", "20.42.30.105/32", "20.42.34.190/32", "20.42.35.204/32", "20.185.110.199/32", "40.90.240.17/32", "52.151.235.150/32", "52.151.235.242/32", "52.151.235.244/32", "52.188.217.235/32", "52.188.218.228/32", "52.188.218.239/32", "20.62.210.48/32", "20.88.153.176/28", "20.88.153.192/27", "40.71.11.80/28", "40.71.15.160/27", "40.71.193.203/32", "40.71.249.139/32", "40.71.249.205/32", "40.114.40.132/32", "52.151.220.217/32", "52.151.221.119/32", "52.151.221.184/32", "104.41.132.180/32", "20.42.66.0/24", "20.42.67.0/24", "20.42.74.64/26", "20.62.128.0/26", "40.71.10.216/29", "40.78.226.208/29", "40.78.231.0/24", "40.79.154.104/29", "52.168.112.192/26", "52.168.114.0/24", "52.168.115.0/24", "57.151.4.0/23", "72.152.167.192/26", "4.255.28.232/32", "4.255.28.237/32", "13.90.199.155/32", "40.71.10.0/25", "40.71.203.37/32", "40.71.204.115/32", "40.78.226.0/25", "40.79.154.128/26", "40.85.178.211/32", "52.146.79.160/27", "52.150.38.36/32", "52.168.28.222/32", "52.179.73.128/26", "52.186.69.224/32", "52.188.136.242/32", "52.188.137.75/32", "52.191.40.64/26", "52.191.41.128/25", "104.45.131.193/32", "20.185.100.27/32", "40.71.13.176/28", "52.224.146.56/32", "20.42.5.0/24", "20.42.6.32/27", "20.42.6.128/28", "20.42.64.64/26", "20.62.129.32/27", "20.62.129.128/29", "20.185.75.6/32", "20.185.75.209/32", "52.149.234.152/32", "52.149.238.190/32", "52.149.239.34/32", "52.170.161.49/32", "52.170.162.28/32", "52.186.106.218/32", "52.191.16.191/32", "52.191.18.106/32", "57.152.125.234/31", "57.154.203.8/29", "20.42.7.0/25", "52.149.248.0/28", "52.149.248.64/27", "52.149.248.96/28", "52.154.68.16/28", "52.154.68.32/28", "52.170.171.192/28", "52.170.171.240/28", "52.186.36.16/28", "57.152.109.80/28", "57.152.110.64/26", "13.90.208.184/32", "13.92.124.151/32", "13.92.180.208/32", "13.92.190.184/32", "20.42.68.64/26", "20.42.74.0/26", "20.88.153.0/26", "40.71.10.128/26", "40.76.40.11/32", "40.76.194.119/32", "40.78.226.128/26", "40.79.155.0/26", "40.117.88.66/32", "40.121.84.50/32", "40.121.141.232/32", "40.121.148.193/32", "52.168.14.144/32", "52.168.66.180/32", "52.168.117.0/26", "52.168.146.69/32", "52.168.147.11/32", "52.179.6.240/32", "52.179.8.35/32", "52.191.45.0/24", "52.191.213.188/32", "52.191.228.245/32", "52.226.36.235/32", "104.45.135.34/32", "104.45.147.24/32", "137.117.85.236/32", "137.117.89.253/32", "137.117.91.152/32", "137.135.102.226/32", "168.62.52.235/32", "172.191.248.0/24", "191.236.32.73/32", "191.236.32.191/32", "191.236.35.225/32", "191.237.47.93/32", "13.82.93.138/32", "20.49.109.128/25", "20.49.110.0/26", "20.49.110.128/25", "20.72.188.101/32", "20.72.188.160/32", "20.88.176.170/32", "20.121.97.114/32", "40.71.14.128/25", "40.76.71.185/32", "40.78.229.128/25", "40.79.156.128/25", "40.114.53.146/32", "52.152.247.195/32", "52.168.180.95/32", "52.186.41.15/32", "104.211.18.153/32", "137.117.83.38/32", "168.61.54.255/32", "20.42.64.44/30", "20.42.73.8/30", "20.62.134.76/30", "20.62.134.224/29", "20.88.156.160/29", "40.71.10.200/30", "20.42.0.240/28", "20.62.135.208/28", "40.71.11.64/28", "40.78.227.32/28", "40.79.154.64/28", "48.211.42.128/27", "48.211.42.160/28", "52.255.214.109/32", "52.255.217.127/32", "9.169.0.224/30", "9.169.0.228/32", "13.82.100.176/32", "13.82.184.151/32", "13.90.93.206/32", "13.90.248.141/32", "13.90.249.229/32", "13.90.251.123/32", "13.92.40.198/32", "13.92.40.223/32", "13.92.138.16/32", "13.92.179.52/32", "13.92.211.249/32", "13.92.232.146/32", "13.92.254.218/32", "13.92.255.146/32", "20.42.0.68/31", "20.42.65.72/29", "20.42.65.128/25", "20.42.73.16/29", "20.42.73.128/25", "20.49.109.46/31", "20.49.109.80/28", "20.49.111.16/28", "20.49.111.32/28", "20.62.132.0/25", "23.96.28.38/32", "40.71.12.224/28", "40.71.12.240/30", "40.71.12.248/29", "40.71.13.168/29", "40.71.14.112/30", "40.71.183.225/32", "40.76.29.55/32", "40.76.53.225/32", "40.78.226.216/29", "40.78.229.32/29", "40.79.154.80/29", "40.79.156.32/29", "40.85.180.90/32", "40.87.67.118/32", "40.112.49.101/32", "40.117.80.207/32", "40.117.95.162/32", "40.117.147.74/32", "40.117.190.239/32", "40.117.197.224/32", "40.121.57.2/32", "40.121.61.208/32", "40.121.135.131/32", "40.121.163.228/32", "40.121.165.150/32", "40.121.210.163/32", "52.150.36.187/32", "52.168.112.64/32", "52.168.116.72/29", "52.168.136.177/32", "52.179.73.32/27", "52.186.121.41/32", "52.186.126.31/32", "52.188.247.144/28", "52.191.197.52/32", "52.224.125.230/32", "52.224.162.220/32", "52.224.235.3/32", "52.226.151.250/32", "57.152.116.224/27", "68.220.88.120/29", "72.152.228.64/26", "72.152.228.128/26", "104.41.152.101/32", "104.41.157.59/32", "104.45.136.42/32", "168.62.169.17/32", "20.42.4.224/28", "13.68.130.251/32", "13.68.235.98/32", "13.90.156.71/32", "13.92.138.76/32", "20.42.6.192/27", "20.49.109.36/30", "20.49.109.44/31", "20.49.109.48/28", "20.62.128.240/29", "40.71.15.144/28", "40.114.78.132/32", "40.117.86.243/32", "40.117.237.78/32", "48.211.4.192/27", "20.62.130.0/23", "40.71.13.224/28", "40.79.158.0/23", "20.42.65.64/29", "20.42.65.96/27", "20.42.68.192/27", "20.42.69.0/25", "20.42.69.128/26", "20.42.73.0/29", "20.42.73.32/27", "20.42.74.192/27", "20.42.75.0/25", "20.42.75.128/26", "20.62.132.160/27", "20.62.132.192/27", "20.62.133.0/26", "23.96.89.109/32", "23.96.106.191/32", "40.71.8.0/26", "40.71.8.192/26", "40.71.9.0/26", "40.71.9.192/26", "40.76.2.172/32", "40.76.26.90/32", "40.76.42.44/32", "40.76.65.222/32", "40.76.66.9/32", "40.76.193.221/32", "40.78.224.0/26", "40.78.224.128/26", "40.78.225.0/26", "40.78.225.128/26", "40.79.152.0/26", "40.79.152.192/26", "40.79.153.0/26", "40.79.153.192/26", "40.114.45.195/32", "40.117.42.73/32", "40.117.44.71/32", "40.121.143.204/32", "40.121.149.49/32", "40.121.158.30/32", "52.168.116.64/29", "52.168.117.96/27", "52.168.117.128/27", "52.168.117.160/29", "52.168.117.192/26", "52.168.118.0/25", "52.168.166.153/32", "52.170.98.29/32", "52.179.75.0/25", "52.179.78.0/24", "52.186.79.49/32", "52.188.246.128/25", "52.188.248.0/25", "104.41.152.74/32", "104.45.158.30/32", "191.238.6.43/32", "191.238.6.44/31", "191.238.6.46/32", "48.211.7.0/25", "48.211.8.0/23", "52.168.112.96/27", "57.152.113.128/26", "57.152.114.0/24", "13.82.27.247/32", "20.42.65.0/26", "20.42.68.0/26", "20.42.72.192/26", "20.42.73.64/26", "20.88.153.64/26", "40.71.10.192/29", "40.78.226.192/29", "40.79.154.88/29", "40.114.86.33/32", "40.114.111.22/32", "40.121.88.231/32", "52.168.29.86/32", "52.168.112.128/26", "52.168.116.192/26", "52.168.133.227/32", "52.226.22.118/32", "57.152.109.128/25", "57.154.200.128/25", "57.154.201.0/24", "57.154.202.0/26", "168.62.48.238/32", "168.62.54.52/32", "172.173.179.62/32", "20.62.133.64/27", "20.88.155.0/25", "13.68.163.32/28", "13.68.165.64/28", "13.68.167.240/28", "13.82.33.32/28", "13.82.152.16/28", "13.82.152.48/28", "13.82.152.80/28", "20.33.143.0/24", "20.33.150.0/24", "20.33.186.0/24", "20.33.201.0/24", "20.33.208.0/24", "20.33.224.0/23", "20.33.255.0/24", "20.38.98.0/24", "20.47.1.0/24", "20.47.16.0/23", "20.47.31.0/24", "20.60.0.0/24", "20.60.2.0/23", "20.60.6.0/23", "20.60.60.0/22", "20.60.128.0/23", "20.60.134.0/23", "20.60.146.0/23", "20.60.220.0/23", "20.150.32.0/23", "20.150.90.0/24", "20.153.1.0/24", "20.157.39.0/24", "20.157.59.0/24", "20.157.61.0/24", "20.157.132.0/24", "20.157.147.0/24", "20.157.171.0/24", "20.157.231.0/24", "20.157.240.0/24", "20.157.252.0/24", "20.209.0.0/23", "20.209.40.0/23", "20.209.52.0/23", "20.209.74.0/23", "20.209.84.0/23", "20.209.106.0/23", "20.209.146.0/23", "20.209.162.0/23", "20.209.226.0/23", "23.96.64.64/26", "40.71.104.16/28", "40.71.104.32/28", "40.71.240.16/28", "40.117.48.80/28", "40.117.48.112/28", "40.117.104.16/28", "52.179.24.16/28", "52.186.112.32/27", "52.226.8.32/27", "52.226.8.80/28", "52.226.8.96/28", "52.226.8.128/27", "52.234.176.48/28", "52.234.176.64/28", "52.234.176.96/27", "52.239.152.0/22", "52.239.168.0/22", "52.239.207.192/26", "52.239.214.0/23", "52.239.220.0/23", "52.239.246.0/23", "52.239.252.0/24", "52.240.48.16/28", "52.240.48.32/28", "52.240.60.16/28", "52.240.60.32/28", "52.240.60.64/27", "57.150.0.0/23", "57.150.8.112/28", "57.150.8.128/25", "57.150.9.0/24", "57.150.10.0/26", "57.150.10.64/28", "57.150.18.80/28", "57.150.18.96/27", "57.150.18.128/26", "57.150.18.192/27", "57.150.18.224/28", "57.150.26.0/23", "57.150.28.0/23", "57.150.82.0/23", "57.150.86.0/23", "57.150.106.0/23", "57.150.132.0/23", "57.150.154.0/23", "138.91.96.64/26", "138.91.96.128/26", "168.62.32.0/26", "168.62.32.192/26", "168.62.33.128/26", "191.237.32.128/28", "191.237.32.208/28", "191.237.32.240/28", "191.238.0.0/26", "191.238.0.224/28", "40.117.248.145/32", "52.152.180.144/28", "74.235.227.153/32", "13.92.114.103/32", "20.42.6.224/27", "23.96.12.112/32", "23.96.101.73/32", "23.96.109.140/32", "40.71.12.192/27", "40.78.227.0/27", "40.79.154.32/27", "40.88.48.36/32", "52.188.222.115/32", "104.41.129.99/32", "137.117.45.176/32", "137.117.109.143/32", "168.62.36.128/32", "168.62.168.27/32", "191.236.37.239/32", "191.236.38.142/32", "20.42.2.0/23", "20.42.4.0/26", "20.42.64.0/28", "20.49.111.0/29", "20.119.28.57/32", "20.232.89.104/29", "40.71.14.32/28", "40.78.229.96/28", "48.211.4.136/29", "48.211.4.144/28", "48.211.4.160/29", "48.211.37.0/26", "20.42.0.72/29", "20.88.159.0/27", "40.71.11.96/29", "40.88.222.179/32", "40.88.223.53/32", "13.82.225.233/32", "40.71.13.160/29", "40.71.175.99/32", "52.146.79.136/29", "57.151.0.240/28", "57.151.6.128/29", "168.61.48.131/32", "168.61.49.99/32", "4.156.25.14/32", "4.156.25.188/31", "4.156.26.80/32", "4.156.27.7/32", "4.156.28.117/32", "4.156.241.47/32", "4.156.241.165/32", "4.156.241.183/32", "4.156.241.191/32", "4.156.241.195/32", "4.156.241.229/32", "4.156.242.12/31", "4.156.242.26/32", "4.156.242.49/32", "4.156.242.86/32", "4.156.242.92/32", "4.156.242.96/31", "4.156.243.164/31", "4.156.243.170/32", "4.156.243.172/31", "4.156.243.174/32", "13.92.98.111/32", "20.42.64.48/28", "20.42.72.160/27", "20.84.29.18/32", "20.84.29.29/32", "20.84.29.150/32", "20.88.159.144/29", "20.88.159.160/27", "20.242.168.24/32", "20.242.168.44/32", "23.100.29.190/32", "23.101.132.208/32", "23.101.136.201/32", "23.101.139.153/32", "40.76.148.50/32", "40.76.151.25/32", "40.76.151.124/32", "40.76.174.39/32", "40.76.174.83/32", "40.76.174.148/32", "40.114.8.21/32", "40.114.12.31/32", "40.114.13.216/32", "40.114.14.143/32", "40.114.40.186/32", "40.114.51.5/32", "40.114.82.191/32", "40.117.99.79/32", "40.117.100.228/32", "40.121.91.41/32", "52.224.145.30/32", "52.224.145.162/32", "52.226.216.187/32", "52.226.216.197/32", "52.226.216.209/32", "57.152.113.64/28", "104.45.153.81/32", "137.116.126.165/32", "137.117.72.32/32", "137.135.106.54/32", "172.212.32.196/32", "172.212.37.35/32", "191.238.41.107/32", "20.42.29.162/32", "20.42.31.48/32", "20.42.31.251/32", "20.228.186.154/32", "40.71.14.16/28", "40.76.78.217/32", "40.78.229.64/28", "40.79.156.112/28", "40.114.112.147/32", "40.121.134.1/32", "48.211.15.16/28", "48.211.15.64/27", "48.211.16.0/24", "52.151.237.243/32", "52.151.238.5/32", "52.151.244.65/32", "52.151.247.27/32", "52.188.217.236/32", "52.190.26.220/32", "52.190.31.62/32", "52.191.237.188/32", "52.191.238.65/32", "52.224.188.157/32", "52.224.188.168/32", "52.224.190.225/32", "52.224.191.62/32", "52.224.201.216/32", "52.224.201.223/32", "52.224.202.86/32", "52.224.202.91/32", "57.152.117.114/31", "57.152.117.120/29", "57.152.117.128/25", "57.152.118.0/27", "104.45.168.103/32", "104.45.168.104/32", "104.45.168.106/32", "104.45.168.108/32", "104.45.168.111/32", "104.45.168.114/32", "104.45.170.70/32", "104.45.170.127/32", "104.45.170.161/32", "104.45.170.173/32", "104.45.170.174/31", "104.45.170.176/32", "104.45.170.178/32", "104.45.170.180/32", "104.45.170.182/31", "104.45.170.184/31", "104.45.170.186/32", "104.45.170.188/32", "104.45.170.191/32", "104.45.170.194/32", "104.45.170.196/32", "104.211.9.226/32", "40.71.10.208/29", "40.78.226.200/29", "40.79.154.96/29", "20.42.24.159/32", "20.42.39.188/32", "20.49.110.84/30", "20.49.111.48/28", "20.49.111.64/26", "20.49.111.128/25", "20.62.129.136/29", "20.62.157.223/32", "20.62.180.13/32", "20.62.212.114/32", "20.62.235.189/32", "20.62.235.247/32", "20.72.130.4/32", "20.72.132.26/32", "20.81.0.146/32", "20.81.55.62/32", "20.81.113.146/32", "20.83.131.174/32", "20.84.25.107/32", "20.85.173.165/32", "20.85.179.67/32", "20.88.154.32/27", "20.88.154.64/26", "20.88.155.128/25", "20.88.156.0/25", "20.88.156.128/27", "20.88.157.64/29", "20.119.120.190/32", "20.121.156.117/32", "20.124.54.195/32", "20.124.56.83/32", "20.185.8.74/32", "20.185.72.53/32", "20.185.73.73/32", "20.185.78.168/32", "20.185.211.94/32", "20.185.215.62/32", "20.185.215.91/32", "20.231.112.182/32", "20.237.81.39/32", "20.237.83.167/32", "20.237.112.231/32", "20.241.129.50/32", "40.71.233.8/32", "40.71.233.189/32", "40.71.234.201/32", "40.71.236.15/32", "40.76.128.89/32", "40.76.128.191/32", "40.76.133.236/32", "40.76.149.246/32", "40.76.161.144/32", "40.76.161.165/32", "40.76.161.168/32", "40.88.16.44/32", "40.88.18.208/32", "40.88.18.248/32", "40.88.23.15/32", "40.88.23.202/32", "40.88.48.237/32", "40.88.231.249/32", "40.88.251.157/32", "48.211.10.64/26", "48.211.10.128/25", "48.211.11.0/24", "48.211.12.0/23", "48.211.14.0/24", "48.211.32.64/26", "48.211.32.128/25", "48.211.33.0/24", "48.211.34.0/23", "48.211.36.0/24", "48.219.240.4/30", "48.219.240.8/29", "48.219.240.16/29", "48.219.240.32/27", "48.219.240.64/26", "48.219.240.128/25", "48.219.241.0/27", "52.142.16.162/32", "52.142.28.86/32", "52.146.24.0/32", "52.146.24.96/32", "52.146.24.106/32", "52.146.24.114/32", "52.146.24.226/32", "52.146.26.125/32", "52.146.26.218/32", "52.146.26.244/32", "52.146.50.100/32", "52.146.60.149/32", "52.146.72.0/22", "52.146.76.0/23", "52.146.78.0/24", "52.146.79.0/25", "52.146.79.128/30", "52.147.222.228/32", "52.149.169.236/32", "52.149.238.57/32", "52.149.240.75/32", "52.149.243.177/32", "52.150.35.132/32", "52.150.37.207/32", "52.150.39.143/32", "52.150.39.180/32", "52.151.208.38/32", "52.151.208.126/32", "52.151.212.53/32", "52.151.212.119/32", "52.151.213.195/32", "52.151.231.104/32", "52.151.238.19/32", "52.151.243.194/32", "52.151.246.107/32", "52.152.194.10/32", "52.152.204.86/32", "52.152.205.65/32", "52.152.205.137/32", "52.188.43.247/32", "52.188.77.154/32", "52.188.79.60/32", "52.188.143.191/32", "52.188.177.124/32", "52.188.180.105/32", "52.188.181.97/32", "52.188.182.12/32", "52.188.183.159/32", "52.188.216.65/32", "52.188.221.237/32", "52.188.222.168/32", "52.188.222.206/32", "52.190.24.61/32", "52.190.27.148/32", "52.190.30.136/32", "52.190.30.145/32", "52.190.39.65/32", "52.191.39.181/32", "52.191.44.48/29", "52.191.217.43/32", "52.191.232.133/32", "52.191.237.186/32", "52.191.238.79/32", "52.191.238.157/32", "52.191.239.208/32", "52.191.239.246/32", "52.224.17.48/32", "52.224.17.98/32", "52.224.137.160/32", "52.224.142.152/32", "52.224.149.89/32", "52.224.150.63/32", "52.224.184.205/32", "52.224.184.221/32", "52.224.185.216/32", "52.224.195.119/32", "52.224.200.26/32", "52.224.201.114/32", "52.224.201.121/32", "52.224.203.192/32", "52.224.204.110/32", "52.226.41.202/32", "52.226.41.235/32", "52.226.49.104/32", "52.226.49.156/32", "52.226.51.138/32", "52.226.139.204/32", "52.226.141.200/32", "52.226.143.0/32", "52.226.148.5/32", "52.226.148.225/32", "52.226.175.58/32", "52.226.201.162/32", "52.226.254.118/32", "52.249.201.87/32", "52.249.204.114/32", "52.255.212.164/32", "52.255.213.211/32", "52.255.221.231/32", "104.45.174.26/32", "104.45.175.45/32", "104.45.188.240/32", "104.45.191.89/32", "172.178.6.72/29", "172.178.6.96/27", "172.178.6.192/26", "172.178.7.0/26", "172.178.7.64/27", "172.178.7.96/28", "20.88.159.140/30", "20.88.159.152/29", "20.88.159.208/28", "20.88.159.224/27", "20.119.28.0/27", "20.119.28.32/30", "20.232.88.200/29", "20.232.89.16/28", "20.232.89.32/27", "20.232.89.64/27", "20.232.89.96/29", "52.255.218.64/26", "57.152.116.184/29", "172.191.253.64/26", "172.191.253.128/25", "20.42.4.200/30", "20.42.76.134/31", "20.232.88.0/29", "52.168.118.142/31", "57.152.116.160/28", "57.152.116.176/29", "68.220.88.36/31", "13.72.73.110/32", "13.90.86.1/32", "13.92.97.243/32", "13.92.188.209/32", "13.92.190.185/32", "40.71.86.107/32", "40.117.35.99/32", "40.121.214.58/32", "52.168.88.247/32", "52.168.89.30/32", "52.168.92.234/32", "52.168.116.0/26", "52.168.136.186/32", "52.168.139.96/32", "52.168.141.90/32", "52.168.143.85/32", "52.168.168.165/32", "52.168.178.77/32", "52.168.179.117/32", "52.168.180.168/32", "52.170.28.184/32", "52.170.34.217/32", "52.170.37.236/32", "52.170.209.22/32", "52.179.23.200/32", "72.152.254.0/24", "137.117.96.184/32", "137.117.97.51/32", "13.92.124.124/32", "20.42.64.40/30", "20.42.72.132/30", "40.71.11.104/29", "40.76.203.148/32", "40.76.205.181/32", "20.42.4.248/29", "104.41.148.238/32", "4.157.241.73/32", "4.157.248.58/32", "20.127.137.143/32", "20.163.206.97/32", "20.231.109.75/32", "20.231.110.84/32", "20.232.123.155/32", "20.232.127.69/32", "20.232.137.227/32", "40.64.146.80/28", "4.156.0.0/15", "4.227.128.0/17", "4.236.128.0/17", "4.246.128.0/17", "4.255.0.0/17", "9.169.0.0/17", "13.68.128.0/17", "13.72.64.0/18", "13.82.0.0/16", "13.87.112.0/21", "13.90.0.0/16", "13.92.0.0/16", "13.104.144.128/27", "13.104.152.128/25", "13.104.192.0/21", "13.104.211.0/25", "13.104.214.128/25", "13.104.215.0/25", "13.105.17.0/26", "13.105.19.0/25", "13.105.20.192/26", "13.105.27.0/25", "13.105.27.192/27", "13.105.36.192/26", "13.105.74.48/28", "13.105.98.48/28", "13.105.98.96/27", "13.105.98.128/27", "13.105.104.32/27", "13.105.104.64/28", "13.105.104.96/27", "13.105.106.0/27", "13.105.106.32/28", "13.105.106.64/27", "20.20.131.0/24", "20.25.0.0/17", "20.33.3.0/24", "20.33.8.0/24", "20.33.12.0/24", "20.33.14.0/24", "20.33.20.0/24", "20.33.26.0/24", "20.33.31.0/24", "20.33.32.0/24", "20.33.37.0/24", "20.33.41.0/24", "20.33.45.0/24", "20.33.48.0/24", "20.33.51.0/24", "20.33.53.0/24", "20.33.55.0/24", "20.33.57.0/24", "20.33.59.0/24", "20.33.61.0/24", "20.33.67.0/24", "20.33.69.0/24", "20.33.77.0/24", "20.33.79.0/24", "20.33.88.0/24", "20.33.104.0/24", "20.33.116.0/24", "20.33.143.0/24", "20.33.150.0/24", "20.33.186.0/24", "20.33.201.0/24", "20.33.208.0/24", "20.33.224.0/23", "20.33.255.0/24", "20.38.98.0/24", "20.39.32.0/19", "20.42.0.0/17", "20.47.1.0/24", "20.47.16.0/23", "20.47.31.0/24", "20.47.108.0/23", "20.47.113.0/24", "20.49.104.0/21", "20.51.128.0/17", "20.55.0.0/17", "20.60.0.0/24", "20.60.2.0/23", "20.60.6.0/23", "20.60.60.0/22", "20.60.128.0/23", "20.60.134.0/23", "20.60.146.0/23", "20.60.220.0/23", "20.62.128.0/17", "20.72.128.0/18", "20.75.128.0/17", "20.81.0.0/17", "20.83.128.0/18", "20.84.0.0/17", "20.85.128.0/17", "20.88.128.0/18", "20.95.0.0/24", "20.95.2.0/24", "20.95.4.0/24", "20.95.6.0/24", "20.95.19.0/24", "20.95.21.0/24", "20.95.23.0/24", "20.95.31.0/24", "20.95.33.0/24", "20.95.34.0/24", "20.95.54.0/24", "20.95.58.0/24", "20.95.63.0/24", "20.102.0.0/17", "20.106.128.0/17", "20.115.0.0/17", "20.119.0.0/17", "20.120.0.0/17", "20.121.0.0/16", "20.124.0.0/16", "20.127.0.0/16", "20.135.4.0/23", "20.135.194.0/23", "20.135.196.0/22", "20.136.3.0/25", "20.136.4.0/24", "20.143.12.0/24", "20.143.34.0/23", "20.143.52.0/23", "20.143.72.0/23", "20.150.32.0/23", "20.150.90.0/24", "20.152.0.0/23", "20.152.36.0/22", "20.153.1.0/24", "20.157.6.0/23", "20.157.19.0/24", "20.157.24.0/24", "20.157.39.0/24", "20.157.59.0/24", "20.157.61.0/24", "20.157.93.0/24", "20.157.104.0/24", "20.157.109.0/24", "20.157.116.0/24", "20.157.124.0/24", "20.157.132.0/24", "20.157.147.0/24", "20.157.171.0/24", "20.157.215.0/24", "20.157.216.0/24", "20.157.231.0/24", "20.157.240.0/24", "20.157.252.0/24", "20.163.128.0/17", "20.168.192.0/18", "20.169.128.0/17", "20.172.128.0/17", "20.185.0.0/16", "20.190.130.0/24", "20.190.151.0/24", "20.201.204.0/24", "20.202.20.0/24", "20.202.39.0/24", "20.202.106.0/24", "20.202.110.0/24", "20.202.114.0/24", "20.202.118.0/24", "20.202.120.0/22", "20.202.124.0/24", "20.202.130.0/24", "20.202.134.0/24", "20.202.138.0/24", "20.202.184.0/21", "20.202.192.0/23", "20.209.0.0/23", "20.209.40.0/23", "20.209.52.0/23", "20.209.74.0/23", "20.209.84.0/23", "20.209.106.0/23", "20.209.146.0/23", "20.209.162.0/23", "20.209.226.0/23", "20.228.128.0/17", "20.231.0.0/17", "20.231.192.0/18", "20.232.0.0/16", "20.237.0.0/17", "20.241.128.0/17", "20.242.128.0/17", "20.246.128.0/17", "20.253.0.0/17", "23.96.0.0/17", "23.98.45.0/24", "23.100.16.0/20", "23.101.128.0/20", "40.64.146.80/28", "40.64.164.128/25", "40.71.0.0/16", "40.76.0.0/16", "40.78.219.0/24", "40.78.224.0/21", "40.79.152.0/21", "40.80.144.0/21", "40.82.24.0/22", "40.82.60.0/22", "40.85.160.0/19", "40.87.0.0/17", "40.87.164.0/22", "40.88.0.0/16", "40.90.23.128/25", "40.90.24.128/25", "40.90.25.0/26", "40.90.30.192/26", "40.90.129.128/26", "40.90.130.96/28", "40.90.131.224/27", "40.90.136.16/28", "40.90.136.32/27", "40.90.137.96/27", "40.90.139.224/27", "40.90.143.0/27", "40.90.146.64/26", "40.90.147.0/27", "40.90.148.64/27", "40.90.150.32/27", "40.90.224.0/19", "40.91.4.0/22", "40.93.2.0/24", "40.93.4.0/24", "40.93.11.0/24", "40.97.4.0/24", "40.97.46.192/26", "40.97.47.0/25", "40.112.48.0/20", "40.114.0.0/17", "40.117.32.0/19", "40.117.64.0/18", "40.117.128.0/17", "40.120.148.0/23", "40.120.150.0/24", "40.120.151.0/25", "40.120.151.128/27", "40.120.151.160/31", "40.121.0.0/16", "40.123.132.0/22", "40.123.176.0/22", "40.126.2.0/24", "40.126.23.0/24", "48.208.3.0/24", "48.208.4.0/22", "48.208.8.0/23", "48.208.10.0/24", "48.211.0.0/17", "48.216.128.0/17", "48.217.0.0/16", "48.219.240.0/21", "51.5.38.0/23", "51.8.0.0/17", "51.8.192.0/18", "52.101.4.0/22", "52.101.9.0/24", "52.101.20.0/22", "52.101.51.0/24", "52.101.52.0/22", "52.102.129.0/24", "52.102.137.0/24", "52.102.159.0/24", "52.103.1.0/24", "52.103.3.0/24", "52.103.11.0/24", "52.103.129.0/24", "52.103.137.0/24", "52.106.2.0/24", "52.106.7.0/24", "52.108.16.0/21", "52.108.79.0/24", "52.108.105.0/24", "52.108.106.0/23", "52.109.12.0/22", "52.111.229.0/24", "52.112.23.0/24", "52.112.112.0/24", "52.112.123.0/24", "52.112.127.0/24", "52.113.16.0/20", "52.114.132.0/22", "52.115.54.0/24", "52.115.62.0/23", "52.115.192.0/19", "52.120.32.0/19", "52.120.224.0/20", "52.122.0.0/24", "52.122.2.0/23", "52.122.4.0/23", "52.122.6.0/24", "52.122.148.0/22", "52.122.152.0/21", "52.122.160.0/22", "52.123.0.0/24", "52.123.10.0/24", "52.123.187.0/24", "52.123.188.0/24", "52.125.132.0/22", "52.136.64.0/18", "52.142.0.0/18", "52.143.207.0/24", "52.146.0.0/17", "52.147.192.0/18", "52.149.128.0/17", "52.150.0.0/17", "52.151.128.0/17", "52.152.128.0/17", "52.154.64.0/18", "52.168.0.0/16", "52.170.0.0/16", "52.179.0.0/17", "52.186.0.0/16", "52.188.0.0/16", "52.190.0.0/17", "52.191.0.0/17", "52.191.192.0/18", "52.224.0.0/16", "52.226.0.0/16", "52.232.146.0/24", "52.234.128.0/17", "52.239.152.0/22", "52.239.168.0/22", "52.239.207.192/26", "52.239.214.0/23", "52.239.220.0/23", "52.239.246.0/23", "52.239.252.0/24", "52.240.0.0/17", "52.245.8.0/22", "52.245.104.0/22", "52.249.128.0/17", "52.253.160.0/24", "52.255.128.0/17", "57.150.0.0/23", "57.150.8.112/28", "57.150.8.128/25", "57.150.9.0/24", "57.150.10.0/26", "57.150.10.64/28", "57.150.18.80/28", "57.150.18.96/27", "57.150.18.128/26", "57.150.18.192/27", "57.150.18.224/28", "57.150.26.0/23", "57.150.28.0/23", "57.150.82.0/23", "57.150.86.0/23", "57.150.106.0/23", "57.150.132.0/23", "57.150.154.0/23", "57.151.0.0/17", "57.152.0.0/17", "57.154.192.0/18", "65.54.19.128/27", "68.220.88.0/21", "70.152.8.0/24", "70.152.106.0/23", "70.152.108.0/22", "70.152.112.0/21", "70.152.120.0/24", "72.152.128.0/17", "74.179.128.0/17", "74.235.0.0/16", "104.41.128.0/19", "104.44.91.32/27", "104.44.94.16/28", "104.44.95.160/27", "104.44.95.240/28", "104.45.128.0/18", "104.45.192.0/20", "104.211.0.0/18", "135.234.128.0/17", "135.237.0.0/17", "137.116.112.0/20", "137.117.32.0/19", "137.117.64.0/18", "137.135.64.0/18", "138.91.96.0/19", "151.206.83.0/24", "151.206.84.0/24", "151.206.129.0/24", "157.56.176.0/21", "168.61.32.0/20", "168.61.48.0/21", "168.62.32.0/19", "168.62.160.0/19", "172.171.32.0/19", "172.171.64.0/19", "172.171.128.0/17", "172.172.128.0/17", "172.173.128.0/17", "172.174.0.0/16", "172.178.0.0/17", "172.190.0.0/15", "172.203.128.0/17", "172.206.192.0/18", "172.208.0.0/17", "172.210.0.0/17", "172.212.0.0/17", "172.214.0.0/17", "191.234.32.0/19", "191.236.0.0/18", "191.237.0.0/17", "191.238.0.0/18", "204.152.18.0/31", "204.152.18.8/29", "204.152.18.32/27", "204.152.18.64/26", "204.152.19.0/24"]
}

variable "github_static_runners_ip_list" {
  type    = list(any)
  default = ["20.190.30.32/23", "20.253.119.128/28", "20.99.151.104/29"]
}

variable "vpn_network_cidr_list" {
  type    = list(any)
  default = []
}

variable "rbac_bindings" {
  description = "Azure AD user and group IDs to configure in Kubernetes ClusterRoleBindings."
  type = object({
    cluster_admin_users  = optional(map(string), {})
    cluster_admin_groups = optional(list(string), [])
    cluster_view_users   = optional(map(string), {})
    cluster_view_groups  = optional(list(string), [])
  })
}

variable "azure_env" {
  description = "Azure cloud environment type."
  type        = string
  nullable    = false
}

variable "aks_control_plane_identity_id" {
  description = "AKS control plane managed identity id"
  type        = string
}

variable "github_workflow_sp_object_ids" {
  description = "Github Workflow Azure Application Object IDs"
  type        = list(string)
}
