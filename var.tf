variable "custome_domain_name" {}
variable "hostzone" {}

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
    "192.168.2.0/24"
  ]
}

variable "private_subnets" {
  type = list(string)

  default = [
    "192.168.102.0/24"
  ]
}

variable "spot_bid_percentage" {
  type    = string
  default = "100"
}

variable "instance_types" {
  type    = list(string)
  default = ["m5.large", "m5.xlarge"]
  # default = ["m5.2xlarge"]
}

variable "instance_settings" {
  type = map(any)

  default = {
    min_vcpus = 0
    max_vcpus = 10
  }
}

variable "youtube_dl_job_log_group_name" {
  type    = string
  default = "/aws/batch/youtube-dl"
}

variable "youtube_dl_job_definition_name" {
  type    = string
  default = "youtube-dl-job-definition"
}

variable "youtube_dl_job_queue_name" {
  type    = string
  default = "youtubedl-batch-queue"
}

variable "api_gateway_stagename" {
  type    = string
  default = "prod"
}