variable "application" {
  description = "Application attributes."
  default = {
    label      = "akamai-linode-demo"
    token      = "token"
    publicKey  = "publicKey"
    privateKey = "privateKey"
  }
}

variable "linode" {
  description = "Linode attributes."
  default = {
    region = "us-east"
    token  = "token"
    balancer = {
      connectionThrottle = 20
      healthCheck        = {
        protocol   = "http"
        port       = 80
        attempts   = 3
        interval   = 10
        timeout    = 5
        path       = "/"
        stickiness = "http_cookie"
        algorithm  = "source"
      }
    }
    manager = {
      label = "demo-manager"
      type  = "g6-standard-2"
      os    = "linode/debian11"
      user  = "root"
    }
    worker = {
      label = "demo-worker"
      type  = "g6-standard-2"
      os    = "linode/debian11"
      user  = "root"
    }
  }
}

variable "akamai" {
  description = "Akamai attributes."
  default = {
    edgegrid = {
      apiHostname  = "apiHostname"
      accessToken  = "accessToken"
      clientToken  = "clientToken"
      clientSecret = "clientSecret"
    }
    account  = "account"
    contract = "contract"
    group    = "group"
    product  = "product"
    email    = "email"
    property = {
      id           = "akamai-linode-demo"
      hostname     = "hostname"
      edgeHostname = "edgeHostname"
    }
  }
}