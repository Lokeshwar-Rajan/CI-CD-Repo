resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "myvpc" {
  vpc_id = aws_vpc.myvpc.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-${var.azs[count.index]}"
    Tier = "Web"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  tags = {
    Name = "${var.vpc_name}-private-${var.azs[count.index % length(var.azs)]}"
    Tier = "App"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index % length(var.azs)]
  tags = {
    Name = "${var.vpc_name}-db-${var.azs[count.index % length(var.azs)]}"
    Tier = "DB"
  }
  
}

resource "aws_eip" "nat" {
  count  = length(var.nat_gw_subnet_indexes)
  domain = "vpc"
  tags = { Name = "${var.vpc_name}-nat-eip-${count.index+1}" }
}

resource "aws_nat_gateway" "myvpc" {
  count         = length(var.nat_gw_subnet_indexes)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.nat_gw_subnet_indexes[count.index]].id
  tags          = { Name = "${var.vpc_name}-natgw-${count.index+1}" }
  depends_on    = [aws_internet_gateway.myvpc]
}

resource "aws_route_table" "public-web" {
  vpc_id = aws_vpc.myvpc.id
  tags = { Name = "web-route-table" }
}
 
resource "aws_route_table" "private-app-1" {
  vpc_id = aws_vpc.myvpc.id
  tags = { Name = "app1-route-table" }
}
resource "aws_route_table" "private-app-2" {
  vpc_id = aws_vpc.myvpc.id
  tags  = { Name = "app2-route-table"}
}
# resource "aws_route_table" "db" {
  # vpc_id = aws_vpc.myvpc.id
  # tags  = { Name = "db-route-table"}
# }

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public-web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myvpc.id
}
 
resource "aws_route" "app-nat-1" {
  route_table_id         = aws_route_table.private-app-1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.myvpc[0].id
}
resource "aws_route" "app-nat-2" {
  route_table_id = aws_route_table.private-app-2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.myvpc[1].id  
}

resource "aws_route_table_association" "web" {
  count = length(var.public_subnet_cidrs)
  subnet_id     = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-web.id
}
 
resource "aws_route_table_association" "app1" {
  count  = length(var.private_subnet_cidrs)
  subnet_id     = aws_subnet.private[0].id
  route_table_id = aws_route_table.private-app-1.id
}

resource "aws_route_table_association" "app2" {
  count  = length(var.private_subnet_cidrs)
  subnet_id     =  aws_subnet.private[1].id
  route_table_id = aws_route_table.private-app-2.id
}

# resource "aws_route_table_association" "db" {
#   count  = length(var.db_subnet_cidrs)
#   subnet_id     =  aws_subnet.db[count.index].id
#   route_table_id = aws_route_table.private-app-2.id
# }