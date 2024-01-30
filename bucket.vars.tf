variable "name" {
  type        = string
  description = "The name of the bucket."
  default     = null
}

variable "location" {
  type        = string
  description = "The GCS location."
  default     = null
}

variable "force_destroy" {
  type        = string
  description = "(Optional, Default: false) When deleting a bucket, this boolean option will delete all contained objects."
  default     = null
}

variable "project" {
  type        = string
  description = "(Optional) The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  default     = null
}

variable "storage_class" {
  type        = string
  description = "(Optional, Default: 'STANDARD') The Storage Class of the new bucket."
  default     = null
  validation {
    condition = contains(
      [
        "STANDARD",
        "MULTI_REGIONAL",
        "REGIONAL",
        "NEARLINE",
        "COLDLINE",
        "ARCHIVE",
      ],
      var.storage_class != null ? var.storage_class : "STANDARD"
    )
    error_message = "Possible values are: ${join(", ",
      [
        "<STANDARD>",
        "MULTI_REGIONAL",
        "REGIONAL",
        "NEARLINE",
        "COLDLINE",
        "ARCHIVE",
      ],
    )}."
  }
}

variable "autoclass" {
  type = object({
    enabled                = bool             # While set to true, autoclass automatically transitions objects in your bucket to appropriate storage classes based on each object's access pattern.
    terminal_storage_class = optional(string) # The storage class that objects in the bucket eventually transition to if they are not read for a certain length of time. Supported values include: NEARLINE, ARCHIVE.
  })
  description = "The bucket's Autoclass configuration."
  default     = { enabled = null }
}

variable "lifecycle_rule" {
  type = list(object({
    action = object({
      type          = string           # The type of the action of this Lifecycle Rule. Supported values include: Delete, SetStorageClass and AbortIncompleteMultipartUpload.
      storage_class = optional(string) # (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE.
    })
    condition = object({
      age                        = optional(number) # Minimum age of an object in days to satisfy this condition.
      no_age                     = optional(bool)   # While set true, age value will be omitted. Note Required to set true when age is unset in the config file.
      created_before             = optional(string) # A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when an object is created before midnight of the specified date in UTC.
      with_state                 = optional(string) # Match to live and/or archived objects. Unversioned buckets have only live objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
      matches_storage_class      = optional(string) # Storage Class of objects to satisfy this condition. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE, DURABLE_REDUCED_AVAILABILITY.
      matches_prefix             = optional(string) # One or more matching name prefixes to satisfy this condition.
      matches_suffix             = optional(string) # One or more matching name suffixes to satisfy this condition.
      num_newer_versions         = optional(number) # Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
      custom_time_before         = optional(string) # A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when the customTime metadata for the object is set to an earlier date than the date used in this lifecycle condition.
      days_since_custom_time     = optional(number) # Days since the date set in the customTime metadata for the object. This condition is satisfied when the current date and time is at least the specified number of days after the customTime.
      days_since_noncurrent_time = optional(number) # Relevant only for versioned objects. Number of days elapsed since the noncurrent timestamp of an object.
      noncurrent_time_before     = optional(string) # Relevant only for versioned objects. The date in RFC 3339 (e.g. 2017-06-13) when the object became nonconcurrent.
    })
  }))
  description = "The bucket's Lifecycle Rules configuration."
  default     = [{ action = { type = null } }]
}

variable "versioning" {
  type = object({
    enabled = bool # While set to true, versioning is fully enabled for this bucket.
  })
  description = "The bucket's Versioning configuration."
  default     = { enabled = null }
}

variable "website" {
  type = object({
    main_page_suffix = optional(string) # Behaves as the bucket's directory index where missing objects are treated as potential directories.
    not_found_page   = optional(string) # The custom object to return when a requested resource is not found.
  })
  description = "Configuration if the bucket acts as a website."
  default     = null
}

variable "cors" {
  type = list(object({
    origin          = optional(list(string)) # The list of Origins eligible to receive CORS response headers. Note: "*" is permitted in the list of origins, and means "any Origin".
    method          = optional(list(string)) # The list of HTTP methods on which to include CORS response headers, (GET, OPTIONS, POST, etc) Note: "*" is permitted in the list of methods, and means "any method".
    response_header = optional(list(string)) # The list of HTTP headers other than the simple response headers to give permission for the user-agent to share across domains.
    max_age_seconds = optional(number)       # The value, in seconds, to return in the Access-Control-Max-Age header used in preflight responses.
  }))
  description = "The bucket's Cross-Origin Resource Sharing (CORS) configuration."
  default     = []
}

variable "default_event_based_hold" {
  type        = bool
  description = "(Optional) Whether or not to automatically apply an eventBasedHold to new objects added to the bucket."
  default     = null
}

variable "retention_policy" {
  type = object({
    is_locked        = optional(bool) # If set to true, the bucket will be locked and permanently restrict edits to the bucket's retention policy. Caution: Locking a bucket is an irreversible action.
    retention_period = number         # The period of time, in seconds, that objects in the bucket must be retained and cannot be deleted, overwritten, or archived. The value must be less than 2,147,483,647 seconds.
  })
  description = "(Optional) Configuration of the bucket's data retention policy for how long objects in the bucket should be retained."
  default     = { retention_period = null }
}

variable "labels" {
  type        = map(string)
  description = "(Optional) A map of key/value label pairs to assign to the bucket."
  default     = {}
}

variable "logging" {
  type = object({
    log_bucket        = string           # The bucket that will receive log objects.
    log_object_prefix = optional(string) # The object prefix for log objects. If it's not provided, by default GCS sets this to this bucket's name.
  })
  description = "The bucket's Access & Storage Logs configuration."
  default     = { log_bucket = null }
}

variable "encryption" {
  type = object({
    default_kms_key_name = string # The id of a Cloud KMS key that will be used to encrypt objects inserted into this bucket, if no encryption method is specified.
  })
  description = "The bucket's encryption configuration."
  default     = { default_kms_key_name = null }
}

variable "enable_object_retention" {
  type        = bool
  description = "(Optional, Default: false) Enables object retention on a storage bucket."
  default     = null
}

variable "requester_pays" {
  type        = bool
  description = "(Optional, Default: false) Enables Requester Pays on a storage bucket."
  default     = null
}

variable "rpo" {
  type        = string
  description = "(Optional) The recovery point objective for cross-region replication of the bucket. Applicable only for dual and multi-region buckets."
  default     = null
  validation {
    condition = contains(
      [
        "DEFAULT",
        "ASYNC_TURBO",
      ],
      var.rpo != null ? var.rpo : "DEFAULT"
    )
    error_message = "Possible values are: ${join(", ",
      [
        "<DEFAULT>",
        "ASYNC_TURBO",
      ],
    )}."
  }
}

variable "uniform_bucket_level_access" {
  type        = bool
  description = "(Optional, Default: false) Enables Uniform bucket-level access access to a bucket."
  default     = null
}

variable "public_access_prevention" {
  type        = string
  description = "Prevents public access to a bucket."
  default     = null
  validation {
    condition = contains(
      [
        "inherited",
        "enforced",
      ],
      var.public_access_prevention != null ? var.public_access_prevention : "inherited"
    )
    error_message = "Possible values are: ${join(", ",
      [
        "<inherited>",
        "enforced",
      ],
    )}."
  }
}

variable "custom_placement_config" {
  type = object({
    data_locations = list(string) # The list of individual regions that comprise a dual-region bucket.
  })
  description = "(Optional) The bucket's custom location configuration, which specifies the individual regions that comprise a dual-region bucket."
  default     = { data_locations = [] }
}
