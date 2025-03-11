resource "aws_instance" "web" {
    ami = "ami-0e1bed4f06a3b463d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    key_name = "new-kp"
    security_groups = [aws_security_group.ec2_sg.id]
    tags = {
        Name = "wed-server"
    }
}