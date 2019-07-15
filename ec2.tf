variable "PUBLIC_SSH_KEY" {
  type = "string"
}

locals {
  server_dl_url  = "https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar"
  startup_script = <<EOT
    #!bin/bash
    cd /home/ec2-user
    yum update -y
    yum upgrade -y
    yum install java-1.8.0-openjdk-headless.x86_64 -y
    runuser -l ec2-user -c 'aws s3 cp s3://${aws_s3_bucket.persistent-storage.id}/backup-current.tar.gz ~'
    runuser -l ec2-user -c 'tar -xvf backup-current.tar.gz'
    rm backup-current.tar.gz
    if [ ! -f server.jar ]; then
      runuser -l ec2-user -c 'wget ${local.server_dl_url}'
    fi
    if [ ! -f eula.txt ]; then
      runuser -l ec2-user -c 'echo "eula=true" >> eula.txt'
    fi
    # echo "@hourly /home/ec2-user/dobackup.sh" >> /etc/crontab
    runuser -l ec2-user -c 'java -Xmx3072M -Xms1024M -jar server.jar nogui'
  EOT
}

resource "aws_key_pair" "server-key" {
  key_name = "MinecraftServerKey"
  public_key = "${var.PUBLIC_SSH_KEY}"
}


resource "aws_launch_template" "server-template" {
  name = "MinecraftServerLaunchTemplate"
  description = "Template for minecraft spot instances"
  image_id = "ami-0d8f6eb4f641ef691"
  instance_type = "c5d.large"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.minecraft-server.name}"
  }

  key_name = "${aws_key_pair.server-key.key_name}"

  network_interfaces {
    description = "Public internet interface."
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups = ["${aws_security_group.mc-server-sg.id}"]
    subnet_id = "${aws_subnet.main.id}"
  }

  user_data = "${base64encode(local.startup_script)}"
  depends_on = ["aws_internet_gateway.main"]
  tags = {
    Project = "minecraft"
  }

}
