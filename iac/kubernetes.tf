# Apply the stack in the application cluster nodes.
resource "null_resource" "apply-stack" {
  # Trigger definition to execute.
  triggers = {
    always_run = timestamp()
  }

  # Upload the apply script into the manager node.
  provisioner "file" {
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    source      = "applyStack.sh"
    destination = "/tmp/applyStack.sh"
  }

  # Upload the stack file into the manager node.
  provisioner "file" {
    # Node connection definition.
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    source      = "kubernetes.yml"
    destination = "/tmp/kubernetes.yml"
  }

  # Upload the stack environment variables file into the manager node.
  provisioner "file" {
    # Node connection definition.
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    source      = ".env"
    destination = "/tmp/.env"
  }

  # Apply the stack.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    inline = [
      "cd /tmp",
      "chmod +x applyStack.sh",
      "./applyStack.sh",
      "rm -f applyStack.sh"
    ]
  }

  depends_on = [ linode_instance.manager, linode_instance.worker ]
}