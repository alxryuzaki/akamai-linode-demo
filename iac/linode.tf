# Linode token definition.
provider "linode" {
  token = var.linode.token
}

# Create a public key to be used by the cluster nodes.
resource "linode_sshkey" "application" {
  label   = var.application.label
  ssh_key = var.application.publicKey
}

# Create the manager node of the cluster.
resource "linode_instance" "manager" {
  label           = var.linode.manager.label
  region          = var.linode.region
  type            = var.linode.manager.type
  image           = var.linode.manager.os
  tags            = [ var.application.label ]
  private_ip      = true
  authorized_keys = [ linode_sshkey.application.ssh_key ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.linode.manager.label}",
      "apt -y update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "export K3S_TOKEN=${var.application.token}",
      "export K3S_KUBECONFIG_MODE=644",
      "export INSTALL_K3S_EXEC=server",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ip_address} --flannel-backend=wireguard-native --flannel-external-ip"
    ]
  }
}

# Create the worker node of the cluster.
resource "linode_instance" "worker" {
  label           = var.linode.worker.label
  region          = var.linode.region
  type            = var.linode.worker.type
  image           = var.linode.worker.os
  tags            = [ var.application.label ]
  private_ip      = true
  authorized_keys = [ linode_sshkey.application.ssh_key ]
  depends_on      = [ linode_instance.manager ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ip_address
      user        = var.linode.worker.user
      private_key = var.application.privateKey
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.linode.worker.label}",
      "apt -y update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim",
      "export K3S_TOKEN=${var.application.token}",
      "export K3S_URL=https://${linode_instance.manager.ip_address}:6443",
      "export INSTALL_K3S_EXEC=agent",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ip_address}"
    ]
  }
}

# Create the cluster load balancer instance.
resource "linode_nodebalancer" "application" {
  label                = var.application.label
  region               = var.linode.region
  client_conn_throttle = var.linode.balancer.connectionThrottle
  tags                 = [ var.application.label ]
  depends_on           = [ linode_instance.manager, linode_instance.worker ]
}

# Create the load balancer configuration.
resource "linode_nodebalancer_config" "application" {
  nodebalancer_id = linode_nodebalancer.application.id
  port            = var.linode.balancer.healthCheck.port
  protocol        = var.linode.balancer.healthCheck.protocol
  check           = var.linode.balancer.healthCheck.protocol
  check_path      = var.linode.balancer.healthCheck.path
  check_attempts  = var.linode.balancer.healthCheck.attempts
  check_interval  = var.linode.balancer.healthCheck.interval
  check_timeout   = var.linode.balancer.healthCheck.timeout
  stickiness      = var.linode.balancer.healthCheck.stickiness
  algorithm       = var.linode.balancer.healthCheck.algorithm
  depends_on      = [ linode_nodebalancer.application ]
}

# Add the cluster manager node in load balancer.
resource "linode_nodebalancer_node" "manager" {
  label           = linode_instance.manager.label
  nodebalancer_id = linode_nodebalancer.application.id
  config_id       = linode_nodebalancer_config.application.id
  address         = "${linode_instance.manager.private_ip_address}:${var.linode.balancer.healthCheck.port}"
  weight          = 50
  depends_on      = [ linode_nodebalancer_config.application ]
}

# Add the cluster worker node in load balancer.
resource "linode_nodebalancer_node" "worker" {
  label           = linode_instance.worker.label
  nodebalancer_id = linode_nodebalancer.application.id
  config_id       = linode_nodebalancer_config.application.id
  address         = "${linode_instance.worker.private_ip_address}:${var.linode.balancer.healthCheck.port}"
  weight          = 50
  depends_on      = [ linode_nodebalancer_config.application ]
}