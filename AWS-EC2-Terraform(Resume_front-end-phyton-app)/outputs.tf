output "Web-link" {
  value     = join ("", ["http://", aws_instance.server.public_dns, ":", "8080" ])
}