provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "useast2"
  region = "us-east-2"
  default_tags {
    tags = local.common_tags
  }
}
