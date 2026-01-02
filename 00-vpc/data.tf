data "aws_vpc" "default" {
  default = true
}

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# #to get default vp
# data "aws_vpc" "default_vpc" {
#   default = true

#   # Optional: Add a second filter just to be explicit
#   filter {
#     name   = "is-default"
#     values = ["true"]
#   }
# }

#to get default subnet
data "aws_subnet" "default_subnet" {
  vpc_id            = data.aws_vpc.default_vpc.id
  default_for_az    = true
  availability_zone = "us-east-1a"
}

#to get default security group
data "aws_security_group" "default_sg" {
  vpc_id = data.aws_vpc.default_vpc.id

  # The filter targets the SG named 'default' in the VPC.
  filter {
    name   = "group-name"
    values = ["default"]
  }
}
