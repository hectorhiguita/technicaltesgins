output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.Amrize_Testing_LB.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.Amrize_Testing_LB.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.Amrize_Testing_LB.arn
}
