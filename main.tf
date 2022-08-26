data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "jenkins_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "Jenkins-server"
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [module.jenkins_sg.security_group_id]
  subnet_id              = "subnet-050271cf11d4ee8fc"
  iam_instance_profile   = "LabInstanceProfile"
  user_data              = file("./dependencias.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_eip" "jenkins-ip" {
  instance = module.jenkins_ec2_instance.id
  vpc      = true
}

data "aws_vpc" "catapimba_vpc" {
  filter {
    name      ="tag:Name"
    values    = ["catapimba-corps-vpc"]
    }
}

module "jenkins_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security Group para o ambiente Jenkins"
  vpc_id      = data.aws_vpc.catapimba_vpc.id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp","ssh-tcp"]
  egress_rules             = [ "all-all" ]
}
