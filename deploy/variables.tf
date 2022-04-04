variable "prefix" {
  default = "project-be"
}

variable "project" {
  default = "Backend"
}

variable "contact" {
  default = "contactEmail.com"
}

variable "db_username" {
  description = "Username for the RDS Postgres instance"
  # default =
  # type        = string
}

variable "db_name" {
  description = "DBname for the RDS Postgres instance"
  # type        = string
}

variable "db_host" {
  description = "DBhost for the RDS Postgres instance"
  # type        = string
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
  # default =
  # type        = string
}


## We are using a vpc that already existed. So we are pulling from these vars for Staging infra. terraform config. 
variable "vpc_id" {
  description = "Existing VPC"
  # type        = string
}

variable "public1" {
  description = "Public subnet 1"
  # type        = string
}

variable "private1" {
  description = "Private subnet 1"
  # type        = string
}

variable "public2" {
  description = "Public subnet 2"
  # type        = string
}

variable "private2" {
  description = "Private subnet 2"
  # type        = string
}

variable "bastion_key_name" {
  default = "Telepsycrx-be-api-bastion"
}


variable "ecr_image_api" {
  description = "ECR Image for API"
  default     = "API:latest"
}

variable "ecr_image_proxy" {
  description = "ECR Image for API"
  default     = "ECR:latest"
}

variable "django_secret_key" {
  description = "Secret key for Django app"
}


# variable "db_snapshot_identifier" {
#   type = string
# }

variable "app_aws_id" {
  description = "aws key id for application"
}

variable "app_aws_key" {
  description = "aws key for application"
}

variable "zoom_api_id" {
  description = "zoom key id for application"
}

variable "zoom_api_key" {
  description = "zoom key for application"
}
