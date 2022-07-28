variable "location" {
  type        = string
  description = "Resource group location. Make sure you are deploying in a location where Azure Image Builder is supported"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"

}

variable "tags" {
  description = "Tags to be used for this resource deployment."
  type        = map(any)
  default     = null
}

variable "publisher" {
  type        = string
  description = "Image publisher"
}

variable "offer" {
  type        = string
  description = "Image offer"
}

variable "sku" {
  type        = string
  description = "Image SKU"
}

variable "image_replication_regions" {
  type        = string
  description = "Image replication regions"
}

variable "aib_region" {
  type        = string
  description = "Image builder region"
}

variable "aib_api_version" {
  type        = string
  description = "Image builder API version"
  default     = "2020-02-14"
}