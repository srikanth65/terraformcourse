variable "CIDR" {
    type = string
    default = "10.0.0.0/16"
    description = "VPC CIDR"
  
}


variable "tags" {
    type = map(string)
    default = {
        Name = "timing"
        Terraform = "true"
        Environment = "Dev"
    }
  
}

variable "instance_tenancy" {
    type = string
    default = "default"
    description = "instance tenancy"
  
}

variable "enable_dns_support" {
    type = bool
    default = true 
}

variable "enable_dns_hostnames" {
    type = bool
    default = true  
}

variable "postgress_port" {
    type = number
    default = 5432
}

variable "cidr_list" {
    type = list
    default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "instance_name" {
    type = list
    default = ["web_server","api_server","db_server"]
}

variable "isProd" {
    type = bool
    default = true 
}

variable "env" {
    type = string
    default = "prod"
}