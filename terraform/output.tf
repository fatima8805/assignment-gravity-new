output "public_ip" {
  value = aws_instance.terraform-instance.public_ip
}

output "instance_id" {
  value = aws_instance.terraform-instance.id
}