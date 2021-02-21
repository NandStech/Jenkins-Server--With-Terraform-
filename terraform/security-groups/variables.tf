variable "server_tcp" {
  description = "The port the server will use for TCP requests"
  type        = number
  default     = 22
}

variable "server_web" {
  description = "The port the server will use for web requests"
  type        = number
  default     = 8080
}

variable "server_http" {
  description = "The port the server will use for web requests"
  type        = number
  default     = 80
}

variable "server_https" {
  description = "The port the server will use for web requests"
  type        = number
  default     = 443
}

