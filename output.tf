output "hello-world" {
  description = "Print a Hello World text output"
  value       = "hello world"
}

output "vpc_id" {
  description = "Output the ID for the primary VPC"
  value       = aws_vpc.vpc.id
}

output "public_url" {
  description = "Public URL for our Web Server"
  value       = "https://${aws_instance.ubuntu_server.private_ip}:8080/index.html"
}

output "vpc_information" {
  description = "VPC information about env"
  value       = "Your ${aws_vpc.vpc.tags.Environment} VPC has an ID of ${aws_vpc.vpc.id}"
}

output "vpc_ubuntuserver" {
  description = "VPC for web server"
  value = "Your VPC web server is ${aws_instance.ubuntu_server.arn}"
}

output "vpc_webserver" {
  description = "VPC for web server"
  value = "Your VPC web server is ${aws_instance.web_server.arn}"
}