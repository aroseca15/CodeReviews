variable "prefix" {
  default = "telpsyrx-be"
}

variable "project" {
  default = "TelePsycRX_Backend"
}

variable "contact" {
  default = "amanda.macdonald@telepsycrx.com"
}

variable "db_username" {
  description = "Username for the RDS Postgres instance"
  default     = "telepsycrx_db_user1"
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
  default     = "n<A8ynAtZWVAfZ8+MQ|uHMNbFG$*}"
}

variable "vpc_id" {
  default = "vpc-b09aa2c8"
}

variable "public1" {
  default = "subnet-c268fdba"
}

variable "private1" {
  default = "subnet-03dd2ff891574c58b"
}

variable "public2" {
  default = "subnet-ab9e28e1"
}

variable "private2" {
  default = "subnet-06c6d34fb995660b7"
}
