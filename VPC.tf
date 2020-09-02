provider "aws" {
    access_key = "AKIASW4XQ5NXWAGFLAVT"
    secret_key = "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"
    region =   "eu-west-1"
}

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
        Name = "prod-vpc"
  }
}

 resource "aws_internet_gateway" "my-INGW" { 
 	vpc_id = "${aws_vpc.prod-vpc.id}" 

    tags = { 
 		Name = "my-INGW" 
	} 
 }

resource "aws_subnet" "Public-subnet" { 
 	vpc_id = "${aws_vpc.prod-vpc.id}"
     cidr_block = "10.0.1.0/24"

    tags = { 
 		Name = "Public-subnet" 
	} 
}
resource "aws_subnet" "Private-subnet" { 
 	vpc_id = "${aws_vpc.prod-vpc.id}" 
     cidr_block = "10.0.2.0/24"

    tags = { 
 		Name = "Private-subnet" 
	} 
}

resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    route {
     cidr_block = "0.0.0.0/0"
      gateway_id ="${aws_internet_gateway.my-INGW.id}"
    }
       
      tags = {
          Name = "public-rt"
      }
}
resource "aws_route_table" "Private-rt" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    route {
     cidr_block = "0.0.0.0/0"
      gateway_id ="${aws_internet_gateway.my-INGW.id}"
    }
       
      tags = {
          Name = "Private-rt"
      }
}


     