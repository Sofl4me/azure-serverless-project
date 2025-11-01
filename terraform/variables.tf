variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "serverless-img"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "spaincentral"
}

variable "storage_account_tier" {
  description = "Tier du Storage Account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Type de réplication"
  type        = string
  default     = "LRS"
}

variable "function_app_sku" {
  description = "SKU du App Service Plan"
  type        = string
  default     = "Y1"
}

variable "python_version" {
  description = "Version de Python"
  type        = string
  default     = "3.11"
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default = {
    Project     = "ServerlessImageProcessing"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}
