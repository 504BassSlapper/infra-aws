output "instance_info" {
    value = [aws_instance.root-instance.availability_zone,
                aws_instance.root-instance.public_ip,
                aws_instance.root-instance.id]
    description = "instance_info"
  
}