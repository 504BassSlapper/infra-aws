output "public_ip" {
    value = aws_instance.root-instance.public_ip
    description = "Public ip"
  
}