resource "aws_instance" "web" {
  ami           = "ami-00b8917ae86a424c9"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}