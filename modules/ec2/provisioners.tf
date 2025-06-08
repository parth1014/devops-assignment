/*
  null_resource "run_provisioners"

  This resource uses SSH provisioners to deploy and run a Dockerized web application
  on the AWS EC2 instance after it is created.

  - Copies the application directory from local (var.web_app_dir_path) to the instance at /tmp.
  - Waits for cloud-init to complete to ensure Docker is installed.
  - Builds a Docker image from the copied Dockerfile.
  - Runs the Docker container exposing port 8081.
  
  The SSH connection uses the dynamically created private key file and connects to
  either the EC2 instance public IP or associated Elastic IP (EIP) based on var.enable_eip.

  Depends on EC2 instance and EIP resources to ensure proper creation order.
*/

resource "null_resource" "run_provisioners" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.priv_key_output_path}/${var.instance_name}-priv-key-${random_id.file_suffix.id}.pem")
    host        = var.enable_eip ? aws_eip.eip[0].public_ip : aws_instance.web.public_ip
  }

  provisioner "file" {
    source      = var.web_app_dir_path
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for docker to install'; sleep 10; done",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "docker build -t flask:v1 -f /tmp/app/Dockerfile /tmp/app/",
      "docker run -dit --name flask-app -p 8081:8081 flask:v1"
    ]
  }

  depends_on = [aws_instance.web, aws_eip.eip]
}
