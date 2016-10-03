/*
  Windows Servers
*/
resource "aws_security_group" "windows" {
    name = "windows_sg"
    description = "Allow incoming RDP WinRM connections."

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 5985
        to_port = 5985
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${var.aws_default_vpc}"

    tags {
        Name = "WINDOWSSG"
    }
}
