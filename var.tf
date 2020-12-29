variable "vpc_name" {
  type        = string
  default     = "youtube-dl-vpc"
  description = "Sample Variable"
}

variable "cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "azs" {
  type = list(string)

  default = [
    "ap-northeast-1a"
  ]
}

variable "public_subnets" {
  type = list(string)

  default = [
    "192.168.1.0/24"
  ]
}

variable "private_subnets" {
  type = list(string)

  default = [
    "192.168.101.0/24"
  ]
}

variable "spot_bid_percentage" {
  type    = string
  default = "100"
}

variable "instance_types" {
  type    = list(string)
  default = ["m5"]
}

variable "instance_settings" {
  type = map

  default = {
    min_vcpus = 0
    max_vcpus = 4
  }
}
