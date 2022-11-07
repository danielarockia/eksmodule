resource "aws_subnet" "workerlayer1" {
  count             = "${var.private_subnets_count}"
  #vpc_id            = "${data.aws_vpc.defaultvpc.id}"
  vpc_id            = "${data.aws_vpc.defaultvpc.id}"
  #cidr_block        = "${cidrsubnet(data.aws_vpc.defaultvpc.cidr_block, var.newbits - element(split("/", data.aws_vpc.defaultvpc.cidr_block), 1), count.index)}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.defaultvpc.cidr_block, var.newbits - element(split("/", data.aws_vpc.defaultvpc.cidr_block), 1), 130 + count.index)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  
  tags = {
    Name         = "${upper(format("WORKER-LAYER1-Z%s", substr(element(data.aws_availability_zones.azs.names, count.index), -1, -1)))}"
    BUSINESSUNIT = "${var.businessunit}"
    immutable_metadata = "${format("{\"purpose\": \"WORKER-LAYER1\"}")}"
  }
}

resource "aws_subnet" "workerlayer2" {
  count             = "${var.private_subnets_count}"
  vpc_id            = "${data.aws_vpc.defaultvpc.id}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.defaultvpc.cidr_block, var.newbits - element(split("/", data.aws_vpc.defaultvpc.cidr_block), 1), 140 + count.index)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  
  tags = {
    Name         = "${upper(format("WORKER-LAYER2-Z%s", substr(element(data.aws_availability_zones.azs.names, count.index), -1, -1)))}"
    BUSINESSUNIT = "${var.businessunit}"
    immutable_metadata = "${format("{\"purpose\": \"WORKER-LAYER2\"}")}"
  }
}



resource "aws_subnet" "public" {
  count             = "${var.subnets_count}"
  vpc_id            = "${data.aws_vpc.defaultvpc.id}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.defaultvpc.cidr_block, var.newbits - element(split("/", data.aws_vpc.defaultvpc.cidr_block), 1), 120 + count.index)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  tags = {
    Name         = "${upper(format("%s-PUB-Z%s", var.name_prefix, substr(element(data.aws_availability_zones.azs.names, count.index), -1, -1)))}"
    BUSINESSUNIT = "${var.businessunit}"
    immutable_metadata = "${format("{\"purpose\": \"%s-PUB\"}", var.name_prefix)}"
  }
}

# # resource "aws_internet_gateway" "igw" {
# #   vpc_id = "${data.aws_vpc.defaultvpc.id}"
# #   tags   = "${merge(var.tags, tomap({"Name"= var.name_prefix}))}"
# # }

resource "aws_eip" "nat" {
  count = "${var.subnets_count}"
  vpc   = true
}

resource "aws_nat_gateway" "ngw" {
  count         = "${var.subnets_count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  tags          = "${merge(var.tags, tomap({"Name"= upper(format("%s-NGW-Z%s", var.name_prefix, substr(element(data.aws_availability_zones.azs.names, count.index), -1, -1)))}))}"
}

resource "aws_route_table" "public" {
  vpc_id = "${data.aws_vpc.defaultvpc.id}"
  tags   = "${merge(var.tags, tomap({"Name"= upper(format("%s-RTB-PUBLIC", var.name_prefix))}))}"
}

resource "aws_route" "public_internet" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  #gateway_id             = "${aws_internet_gateway.igw.id}"
  gateway_id             = "${data.aws_internet_gateway.internatgateway.internet_gateway_id}"
}

resource "aws_route_table_association" "public" {
  count          = "${var.subnets_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  count  = "${var.private_subnets_count}"
  vpc_id = "${data.aws_vpc.defaultvpc.id}"
  tags   = "${merge(var.tags, tomap({"Name"= upper(format("%s-RTB-PRIVATE-Z%s", var.name_prefix, substr(element(data.aws_availability_zones.azs.names, count.index), -1, -1)))}))}"
}

resource "aws_route" "private_internet" {
  count                  = "${var.private_subnets_count}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
}

resource "aws_route_table_association" "private-l1" {
  count          = "${var.private_subnets_count}"
  subnet_id      = "${element(aws_subnet.workerlayer1.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "private-l2" {
  count          = "${var.private_subnets_count}"
  subnet_id      = "${element(aws_subnet.workerlayer2.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}


