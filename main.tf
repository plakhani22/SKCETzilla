resource "aws_vpc" "test_vpc"{
  cidr_block = "172.172.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags{
    Name = "test_vpc"
  }
}

resource "aws_internet_gateway" "test_igw"{
  vpc_id = "${aws_vpc.test_vpc.id}"

    tags {
      Name = "test_igw"
    }
}

resource "aws_subnet" "test_subnet_1" {
  vpc_id            = "${aws_vpc.test_vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "${cidrsubnet(aws_vpc.test_vpc.cidr_block, 4, 1)}"

  tags {
      Name = "test_subnet_1_public"
    }
}

resource "aws_subnet" "test_subnet_2" {
  vpc_id            = "${aws_vpc.test_vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "${cidrsubnet(aws_vpc.test_vpc.cidr_block, 4, 2)}"

  tags {
      Name = "test_subnet_2_private"
    }
}

resource "aws_subnet" "test_subnet_3" {
  vpc_id            = "${aws_vpc.test_vpc.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "${cidrsubnet(aws_vpc.test_vpc.cidr_block, 4, 3)}"

  tags {
      Name = "test_subnet_3_public"
    }
}

resource "aws_subnet" "test_subnet_4" {
  vpc_id            = "${aws_vpc.test_vpc.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "${cidrsubnet(aws_vpc.test_vpc.cidr_block, 4, 4)}"

  tags {
      Name = "test_subnet_4_private"
    }
}

resource "aws_route_table" "test_public_rt"{
  vpc_id = "${aws_vpc.test_vpc.id}"

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id =  "${aws_internet_gateway.test_igw.id}"
  }

  tags {
    Name = "test_public_rt"
  }
}

resource "aws_route_table" "test_private_rt"{
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name = "test_privat_rt"
  }
}

resource "aws_route_table_association" "route1" {
  subnet_id      = "${aws_subnet.test_subnet_1.id}"
  route_table_id = "${aws_route_table.test_public_rt.id}"
}

resource "aws_route_table_association" "route2" {
  subnet_id      = "${aws_subnet.test_subnet_2.id}"
  route_table_id = "${aws_route_table.test_private_rt.id}"
}

resource "aws_route_table_association" "route3" {
  subnet_id      = "${aws_subnet.test_subnet_3.id}"
  route_table_id = "${aws_route_table.test_public_rt.id}"
}

resource "aws_route_table_association" "route4" {
  subnet_id      = "${aws_subnet.test_subnet_4.id}"
  route_table_id = "${aws_route_table.test_private_rt.id}"
}

resource "aws_network_acl" "test_nacl"{
  vpc_id = "${aws_vpc.test_vpc.id}"
  subnet_ids = ["${aws_subnet.test_subnet_1.id}","${aws_subnet.test_subnet_2.id}","${aws_subnet.test_subnet_3.id}","${aws_subnet.test_subnet_4.id}"]

  tags {
    Name = "test_nacl"
  }

   ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_security_group" "test_security_group"{
  name = "test_security_group"
  description = "test security group in terraform"
  vpc_id = "${aws_vpc.test_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}


resource "aws_instance" "test_ec2"{
	ami = "ami-04169656fea786776"
	instance_type = "t2.micro"
	key_name = "RDBTest"
	vpc_security_group_ids = ["${aws_security_group.test_security_group.id}"]
	subnet_id = "${aws_subnet.test_subnet_3.id}"
	associate_public_ip_address = true

	tags {
		Name = "test_ec2"
	}
}

resource "aws_db_subnet_group" "test_subnet_group" {
  name       = "test_subnet_group"
  subnet_ids = ["${aws_subnet.test_subnet_2.id}", "${aws_subnet.test_subnet_4.id}"]

  tags {
    Name = "test_subnet_group"
  }
}

resource "aws_db_instance" "test_rds" {
  name = "test_rds"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "test_mysql"
  username             = "parikshit"
  password             = "Reena0707"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.test_security_group.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.test_subnet_group.id}"
  skip_final_snapshot = true
  tags {
  	Name = "test_rds"
  }
}


output "security_group_id"{
	value = "${aws_security_group.test_security_group.id}"
}

output "nacl_id"{
	value = "${aws_network_acl.test_nacl.id}"
}

output "route_table_public"{
	value = "${aws_route_table.test_public_rt.id}"
}

output "route_table_private"{
	value = "${aws_route_table.test_private_rt.id}"
}

output "subnet_id_1"{
	value = "${aws_subnet.test_subnet_1.id}"
}

output "subnet_id_2"{
	value = "${aws_subnet.test_subnet_2.id}"
}

output "subnet_id_3"{
	value = "${aws_subnet.test_subnet_3.id}"
}

output "igw_id"{
	value = "${aws_internet_gateway.test_igw.id}"
}

output "vpc_id"{
	value = "${aws_vpc.test_vpc.id}"
}
