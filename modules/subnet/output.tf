output "id" {
  value = "${data.aws_vpc.defaultvpc.id}"
}

output "subnets_layer1" {
  value = "${aws_subnet.workerlayer1.*.id}"
}

output "subnets_layer2" {
  value = "${aws_subnet.workerlayer2.*.id}"
}


output "subnets_public" {
  value = "${aws_subnet.public.*.id}"
}

output "private_route_tables" {
  value = "${aws_route_table.private.*.id}"
}

output "availability_zones" {
  value = "${data.aws_availability_zones.azs.names}"
}
