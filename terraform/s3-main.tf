locals {
  is_prod          = var.stage == "prod"

  subdomain   = local.is_prod ? "" : "${var.stage}."
  domain_name = "${local.subdomain}${var.domain_name}"

  domain_name_separator = local.is_prod ? "." : "-"
  domain_name_auth      = "auth${local.domain_name_separator}${local.domain_name}"
  domain_name_gql       = "gql${local.domain_name_separator}${local.domain_name}"
}

variable "domain_name" {
  default = "my-cinemadriveins.com"
}

variable "stage" {

}

#tfsec:ignore:AWS001
resource "aws_s3_bucket" "site" {
  bucket = local.domain_name
  acl    = "public-read"
  #tfsec:ignore:AWS002
  website {
    index_document = "index.html"
  }

#tfsec:ignore:AWS006
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${local.domain_name}-policy",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.domain_name}/*"
    }
  ]
}
POLICY
}

