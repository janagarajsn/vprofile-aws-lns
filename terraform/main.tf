# Use the default VPC of the region
data "aws_vpc" "default" {
    default = true
}

# Use all the subnets in the default VPC
data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

# Launch Template that uses the AMI and includes a User Data script to deploy the WAR file
resource "aws_launch_template" "vprofile-app-lt" {
    name = "vprofile-app-lt"
    image_id = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    vpc_security_group_ids = [var.security_group_id]
    #user_data = base64encode(<<-EOF
    #          #!/bin/bash
    #          aws s3 cp s3://${var.bucket_name}/vprofile-v2.war /var/lib/tomcat9/webapps/ROOT.war
    #          systemctl restart tomcat
    #          EOF
    #)
    user_data = base64encode(<<-EOF
              #!/bin/bash
              curl -u ${var.nexus_user}:${var.nexus_pass} http://${var.nexus_ip}:8081/repository/maven-releases/com/visualpathit/vprofile/v2/vprofile-v2.war -o /var/lib/tomcat9/webapps/ROOT.war
              systemctl restart tomcat
              EOF
    )
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "vprofile-asg" {
    name = "vprofile-asg"
    launch_template {
        id = aws_launch_template.vprofile-app-lt.id
        version = "$Latest"
    }
    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_capacity
    target_group_arns = [aws_lb_target_group.vprofile-alb-tg.arn]
    vpc_zone_identifier = data.aws_subnets.default.ids # High availability
}

# Create an Elastic Load Balancer
resource "aws_lb" "vprofile-alb" {
    name = "vprofile-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.elb_security_group_id]
    subnets = data.aws_subnets.default.ids # High availability
}

# Create an ALB Target Group
resource "aws_lb_target_group" "vprofile-alb-tg" {
    name = "vprofile-alb-tg"
    port = 8080
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = data.aws_vpc.default.id

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        path = "/login"
        port = 8080
        matcher = "200"
    }
}

# Create an ALB Listener that forwards traffic to the Target Group in port 80
resource "aws_lb_listener" "vprofile-alb-listener" {
    load_balancer_arn = aws_lb.vprofile-alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        target_group_arn = aws_lb_target_group.vprofile-alb-tg.arn
        type = "forward"
    }
}

# Create an ALB Listener Rule that forwards traffic to the Target Group in port 443
resource "aws_lb_listener" "vprofile-alb-listener-https" {
    load_balancer_arn = aws_lb.vprofile-alb.arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = var.certificate_arn # Certificate mandatory for https

    default_action {
        target_group_arn = aws_lb_target_group.vprofile-alb-tg.arn
        type = "forward"
    }
}

# Output
output "alb_dns_name" {
    value = aws_lb.vprofile-alb.dns_name
}

output "asg_name" {
    value = aws_autoscaling_group.vprofile-asg.name
}