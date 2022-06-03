locals {
  id                           = "web" # TODO
  availability_zones           = ["ap-northeast-1a", "ap-northeast-1c"]
  vpc_cidr                     = "10.0.0.0/16"
  public_subnet_cidrs          = ["10.0.1.0/24", "10.0.2.0/24"]
  application_subnet_cidrs     = ["10.0.64.0/24", "10.0.65.0/24"]
  database_subnet_cidrs        = ["10.0.128.0/24", "10.0.129.0/24"]
  bastion_vpc_cidr             = "10.1.0.0/16"
  bastion_public_subnet_cidrs  = ["10.1.1.0/24"]
  bastion_private_subnet_cidrs = ["10.1.64.0/24"]
}

###########################################################################
# Network
###########################################################################
module "network" {
  source      = "../modules/network/"
  environment = var.environment
  vpc_name    = local.id
  vpc_cidr    = local.vpc_cidr
  public_subnets = [
    {
      name = "public"
      az   = local.availability_zones[0]
      cidr = local.public_subnet_cidrs[0]
    },
    {
      name = "public"
      az   = local.availability_zones[1]
      cidr = local.public_subnet_cidrs[1]
    }
  ]
  application_subnets = [
    {
      name = "application"
      az   = local.availability_zones[0]
      cidr = local.application_subnet_cidrs[0]
    },
    {
      name = "application"
      az   = local.availability_zones[1]
      cidr = local.application_subnet_cidrs[1]
    }
  ]
  database_subnets = [
    {
      name = "database"
      az   = local.availability_zones[0]
      cidr = local.database_subnet_cidrs[0]
    },
    {
      name = "database"
      az   = local.availability_zones[1]
      cidr = local.database_subnet_cidrs[1]
    }
  ]
}
module "bastion_network" {
  source      = "../modules/network/"
  environment = var.environment
  vpc_name    = "bastion"
  vpc_cidr    = local.bastion_vpc_cidr
  public_subnets = [
    {
      name = "public"
      az   = local.availability_zones[0]
      cidr = local.bastion_public_subnet_cidrs[0]
    }
  ]
  application_subnets = [
    {
      name = "private"
      az   = local.availability_zones[0]
      cidr = local.bastion_private_subnet_cidrs[0]
    }
  ]
  database_subnets = []
}
module "peering" {
  source                    = "../modules/peering/"
  accepter_vpc_id           = module.network.vpc_id
  accepter_vpc_name         = local.id
  accepter_vpc_cidr         = local.vpc_cidr
  accepter_subnet_ids       = module.network.application_subnet_ids
  accepter_subnet_cidrs     = local.application_subnet_cidrs
  accepter_route_table_ids  = module.network.private_route_table_ids
  requester_vpc_id          = module.bastion_network.vpc_id
  requester_vpc_name        = "bastion"
  requester_vpc_cidr        = local.bastion_vpc_cidr
  requester_subnet_ids      = module.bastion_network.application_subnet_ids
  requester_subnet_cidrs    = local.bastion_private_subnet_cidrs
  requester_route_table_ids = module.bastion_network.private_route_table_ids
}

###########################################################################
# WAF
###########################################################################
module "waf" {
  source      = "../modules/waf/"
  environment = var.environment
  waf_name    = local.id
}

###########################################################################
# CloudFront
###########################################################################
module "cloudfront" {
  source            = "../modules/cloudfront/"
  environment       = var.environment
  distribution_name = local.id
  aliases           = ["hoge.jp"]                                                 # TODO
  certificate_arn   = "arn:aws:acm:us-east-1:111111111111:certificate/xxxxxxxxxx" # TODO
  web_acl_id        = module.waf.web_acl_id
  lb_id             = module.application.lb_id
  lb_dns_name       = module.application.lb_dns_name
}

###########################################################################
# Application
###########################################################################
module "application" {
  source                 = "../modules/application/"
  environment            = var.environment
  hosted_zone_id         = "xxxxxxxxxx"                                                     # TODO
  domain_name            = "hoge.jp"                                                        # TODO
  lb_certificate_arn     = "arn:aws:acm:ap-northeast-1:111111111111:certificate/xxxxxxxxxx" # TODO
  container_name         = "app"                                                            # TODO
  container_image_uri    = "111111111111.dkr.ecr.ap-northeast-1.amazonaws.com/app:latest"   # TODO
  container_port         = 8080                                                             # TODO
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  application_subnet_ids = module.network.application_subnet_ids
  cf_domain_name         = module.cloudfront.domain_name
  cf_hosted_zone_id      = module.cloudfront.hosted_zone_id
  rds_secrets_arn        = module.database.rds_secrets_arn
}

###########################################################################
# Batch
###########################################################################
module "batch" {
  source                 = "../modules/batch/"
  environment            = var.environment
  sfn_name               = "helloWorld"                                                     # TODO
  event_name             = "Monthly"                                                        # TODO
  event_description      = "Start every month"                                              # TODO
  event_schedule         = "cron(0 0 1 * ? *)"                                              # TODO
  container_name         = "helloworld"                                                     # TODO
  container_image_uri    = "111111111111.dkr.ecr.ap-northeast-1.amazonaws.com/batch:latest" # TODO
  container_command      = ["helloWorld"]                                                   # TODO
  container_port         = 8080                                                             # TODO
  vpc_id                 = module.network.vpc_id
  application_subnet_ids = module.network.application_subnet_ids
  rds_secrets_arn        = module.database.rds_secrets_arn
}

###########################################################################
# Database
###########################################################################
module "database" {
  source                   = "../modules/database/"
  environment              = var.environment
  rds_name                 = local.id
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.database_subnet_ids
  application_subnet_cidrs = local.application_subnet_cidrs
  bastion_vpc_cidr         = local.bastion_vpc_cidr
}

###########################################################################
# Bastion
###########################################################################
module "bastion" {
  source       = "../modules/bastion/"
  bastion_name = local.id
  subnet_ids   = module.bastion_network.application_subnet_ids
}
