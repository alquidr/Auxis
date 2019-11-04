# Terraform Code definition.
provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}

# NETWORKING INFRAESTRUCTURE

# Main VPC
resource "aws_vpc" "qrvey-VPC" {
    cidr_block = "10.0.0.0/16"
}

# Subnet Configuration.
resource "aws_subnet" "qrvey-Subnet" {
    vpc_id = "${aws_vpc.qrvey-VPC.id}"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
}

# Internet Gateway.
resource "aws_internet_gateway" "qrvey-IGW" {
    vpc_id = "${aws_vpc.qrvey-VPC.id}"
}

# Route Table.
resource "aws_route" "qrvey-Route" {
    route_table_id = "${aws_vpc.qrvey-VPC.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.qrvey-IGW.id}"
}

# Associate Route Table To Subnet 10.0.0.0/24
resource "aws_route_table_association" "route_assoc" {
    subnet_id = "${aws_subnet.qrvey-Subnet.id}"
    route_table_id = "${aws_route.qrvey-Route.route_table_id}"
}

# Main Security Group.
resource "aws_security_group" "qrvey-secGroup" {
    name = "main_security_group"
    vpc_id = "${aws_vpc.qrvey-VPC.id}"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocols
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Nginx Instance Security Group.
resource "aws_security_group" "qrvey-SecGroup-Nginx" {
    name = "nginx_security_group"
    vpc_id = "${aws_vpc.qrvey-VPC.id}"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Ec2 Nginx instance.
resource "aws_instance" "qrvey-Nginx" {
    ami = "ami-00eb20669e0990cb4"
    instance_type = "t2.micro"
    key_name = "earned"
    subnet_id = "${aws_subnet.qrvey-Subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.qrvey-SecGroup-Nginx.id}"]

    provisioner "chef" {
        server_url = "https://api.chef.io/organizations/qrvey-test"
        client_options  = ["chef_license 'accept'"]
        node_name = "qrvey-test"
        user_key = "${file("./chef-repo/.chef/yarnedo.pem")}"
        user_name = "yarnedo"
        recreate_client = true
        run_list = ["nginx-server::default"]
        
        connection {
            type = "ssh"
            host = "${self.public_ip}"
            agent = true
            private_key = "${file("earned.pem")}"
            user = "ec2-user"
        }
    }
}

# Load Balancer Definition.
resource "aws_elb" "qrvey-ELB" {
    name = "qrvey-ELB"
    instances = ["${aws_instance.qrvey-Nginx.id}"]
    security_groups = ["${aws_security_group.qrvey-secGroup.id}"]
    subnets = ["${aws_subnet.qrvey-Subnet.id}"]

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
}

output "LOAD_BALANCER_URL" {
  value = "http://${aws_elb.qrvey-ELB.dns_name}"
}

