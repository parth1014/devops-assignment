# Outputs the public web address of the deployed web application.
output "app_web_address" {
    value = "http://${module.web_app.ec2_pub_ip}:8081/api/v1/"
}