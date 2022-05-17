output "aws_alb_target_group" {
    value = aws_alb_target_group.myapp-tg.arn
}

output "arn" {
    value = aws_alb.alb.dns_name
}