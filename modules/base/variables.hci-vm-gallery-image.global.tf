variable "download_win_server_image" {
  description = "Whether to download Windows Server image"
  type        = bool
  default     = false
}

variable "user_storage_id" {
  description = "The user storage ID to store images."
  type        = string
  default     = ""
}
