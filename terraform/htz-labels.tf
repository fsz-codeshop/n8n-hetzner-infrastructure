# Wait for cloud-init to finish on both nodes
resource "time_sleep" "wait_for_cloud_init" {
  depends_on = [
    hcloud_server.eu_manager_01,
    hcloud_server.eu_data_01
  ]

  create_duration = "3m"
}

resource "terraform_data" "label_data_01" {
  triggers_replace = [
    hcloud_server.eu_data_01.id,
    hcloud_server.eu_manager_01.id
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = local_sensitive_file.private_key.content
    host        = hcloud_server.eu_manager_01.ipv4_address
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "# Wait for the label script to be created by cloud-init",
      "while [ ! -f /usr/local/bin/swarm-label-node.sh ]; do echo 'Waiting for swarm-label-node.sh...'; sleep 10; done",
      "chmod +x /usr/local/bin/swarm-label-node.sh",
      "/usr/local/bin/swarm-label-node.sh ${hcloud_server.eu_data_01.name} data"
    ]
  }

  depends_on = [
    time_sleep.wait_for_cloud_init
  ]
}
