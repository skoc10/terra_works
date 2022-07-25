# Set up the full test farm of Jenkins
# Usage (Windows):
#   1. [Generate your SSH public and private keys](https://docs.joyent.com/public-cloud/getting-started/ssh-keys/generating-an-ssh-key-manually/manually-generating-your-ssh-key-in-windows)
#   2. Save your private key (*.ppk) generated in step one
#   3. Replace the following "ssh_public_key_data" and "ssh_private_key_data" with your generated keys (you can see both raw data and file path are used here)
#   4. Run "terraform init" "terraform plan" "terraform apply"
#   5. Remember your {public_ip} from the terraform output which is your host IP address
#   6. Remember the "admin_username" specified below
#   7. Using the above information to remote connect to your Jenkins machine by [Putty](https://support.rackspace.com/how-to/logging-in-with-an-ssh-private-key-on-windows/#log-in-to-putty-with-the-private-key)
#   8. Set up SSH port forwarding using [Putty](http://realprogrammers.com/how_to/set_up_an_ssh_tunnel_with_putty.html)
#      - Source port: 12345 (Or any port your like)
#      - Destination: 127.0.0.1:8080
#   9. Open a browser and navigate to "http://localhost:12345" locally
#  10. Following the instructions to initialize the Jenkins
#
# Usage (Ubuntu):
#   You are a Linux guy, you could figure it out by yourself.

module "test-farm-jenkins" {
  source               = "../../"
  location             = "westus3"
  resource_group_name  = "jenkins-test-farm"
  admin_username       = "tfmod-jenkins"
  public_domain_name   = "tfci"
  ssh_public_key_data  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDInRoIuLrp9RaBXe+RR1DwZuCcf1+DckNi5CMBuyU9fGdO+Ny98O8q1xJ0PnDg4xfFdcitdTCkkW6uDCtvzJ7BfXUV+FzZIfe0El4aGoN8OxCxd/rh1nLPJ/8FTBh+tpczt9sIhVQQY6lqywMI3Cb4NkkSDeFRHQAP2rNEmRiDPcZt/DE+bnpLXojxQpJknfBodPMph/F201SCY/hiGgz4I4qa5jr9FLC1rPYkihrB0XZuiWR6vHv8+HmSdncXYToTc3OiIBIe8ObAOkRMncsEcJ80s92AjjfhwfBvphl38bQRAdHNLmiy/IyqD+uReLsWLrVJVV5N1QBXS+l8FtyBChzRzLMFNmxBFP2A7v5AzOtjkkJX8s+Vgxz1oPIWoUNKFXVgPrdH+TAaHY6qjAT6TZTaWwD5t+fbcxqVvWUqAlFgoSReF6k3EkRPEdd1+Yxiw5RTLZqZdrGwRKseLDQ1t4Mgaf5ABZrrSOQAaxxxQMk9I1X5MpszXF5asyFebyk= skoc@volosoftmacsMBP"
  ssh_private_key_data = "${file("/Users/skoc/.ssh/id_rsa")}"
}

output "public_ip" {
  value = "${module.test-farm-jenkins.virtual_machine_public_ip}"
}

output "dns" {
  value = "${module.test-farm-jenkins.virtual_machine_dns_name}"
}
