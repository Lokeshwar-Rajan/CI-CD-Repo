output "vpc_id"                 { 
  value = aws_vpc.myvpc.id 
}
output "public_subnet_ids"      { 
  value = aws_subnet.public[*].id 
}
output "private_subnet_ids"     { 
  value = aws_subnet.private[*].id 
}
output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}
output "igw_id"                 { 
  value = aws_internet_gateway.myvpc.id
}
output "nat_gateway_ids"        {
   value = aws_nat_gateway.myvpc[*].id 
}
output "public_route_table_id" {
  value = aws_route_table.public-web.id
}
 
output "private-app-1_route_table_id" {
  value = aws_route_table.private-app-1.id
}
output "private-app-2_route_table_id" {
  value = aws_route_table.private-app-2.id
} 
# output "db_route_table_id" {
#   value = aws_route_table.db.id
  
# }
