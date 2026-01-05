variable "aws_region" {
    default = "us-central-1"
}

variable "consumer_db_host" {
    default = "tcp://4.tcp.ngrok.io"
}

variable "consumer_db_port" {
    default = 16943
}

variable "consumer_db_user" {
    default = "db_user"
}

variable "consumer_db_password"{
    default = "db_password"
}

variable "consumer_image_tag" {
    default = "1.0"
}