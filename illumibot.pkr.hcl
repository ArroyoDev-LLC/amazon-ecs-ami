locals {
  ami_name_illumibot        = "adev-illumibot-gpu-hvm-2.0.${var.ami_version_illumibot}-${var.image_tag}-x86_64-ebs"
  ami_name_illumibot_models = "adev--models-gpu-hvm-2.0.${var.models_ami_version}-x86_64-ebs"
}

source "amazon-ebs" "illumibot" {
  #ami_name          = "${local.ami_name_illumibot}"
  #ami_description   = "Illumibot Amazon Linux AMI 2.0.${var.ami_version_illumibot} x86_64 ECS HVM GP2"
  instance_type     = var.gpu_instance_types[0]
  subnet_id         = var.subnet_id
  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  launch_block_device_mappings {
    #volume_size           = var.block_device_size_gb
    volume_size           = 60
    delete_on_termination = true
    volume_type           = "gp3"
    device_name           = "/dev/xvda"
    #iops                  = 4000
    throughput = 500
  }
  region = var.region
  #  source_ami_filter {
  #    filters = {
  #      name = "${var.source_ami_illumibot}"
  #    }
  #    owners      = [var.source_ami_illumibot_owner]
  #    most_recent = true
  #  }
  ssh_interface = "public_ip"
  ssh_username  = "ec2-user"
  temporary_iam_instance_profile_policy_document {
    Statement {
      Action = ["s3:*", "fsx:*"]
      Effect = "Allow"
      Resource = ["*"]
    }
    Version = "2012-10-17"
  }
  tags = {
    os_version          = "Amazon Linux 2"
    source_image_name   = "{{ .SourceAMIName }}"
    ecs_runtime_version = "Docker version ${var.docker_version}"
    ecs_agent_version   = "${var.ecs_agent_version}"
    ami_type            = "al2gpu"
    ami_version         = "2.0.${var.ami_version_illumibot}"
    illumibot_version   = "${var.image_tag}"
  }
}

build {
  #sources = ["source.amazon-ebs.illumibot"]

  source "amazon-ebs.illumibot" {
    name            = "illumibot-models"
    ami_name        = local.ami_name_illumibot_models
    ami_description = "Illumibot Amazon Linux AMI 2.0.${var.ami_version_illumibot} x86_64 ECS HVM GP3 Models Base"
    source_ami_filter {
      filters = {
        name = "${var.source_ami_illumibot}"
      }
      owners      = [var.source_ami_illumibot_owner]
      most_recent = true
    }
    temporary_iam_instance_profile_policy_document {
      Statement {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["*"]
      }
      Version = "2012-10-17"
    }
  }

  source "amazon-ebs.illumibot" {
    name            = "illumibot-worker"
    ami_name        = local.ami_name_illumibot
    ami_description = "Illumibot Amazon Linux AMI 2.0.${var.ami_version_illumibot} x86_64 ECS HVM GP3"
    source_ami_filter {
      filters = {
        name = "${var.source_ami_illumibot}"
      }
      owners      = [var.source_ami_illumibot_owner]
      most_recent = true
    }
    #    source_ami_filter {
    #      filters = {
    #        name = "${local.ami_name_illumibot_models}"
    #      }
    #      owners      = [var.source_ami_illumibot_worker_owner]
    #      most_recent = true
    #    }
  }

  provisioner "shell" {
    script = "scripts/setup-illumibot-fsx.sh"
    only   = ["amazon-ebs.illumibot-worker"]
  }

  provisioner "shell" {
    environment_vars = [
      "AMI_TYPE=${source.name}",
      "AIR_GAPPED=${var.air_gapped}"
    ]
    script = "scripts/optimize-gpu-conf.sh"
  }

  provisioner "shell" {
    script = "scripts/install-illumibot-models.sh"
    only   = ["amazon-ebs.illumibot-models"]
  }

  # provisioner "shell" {
  #   environment_vars = [
  #     "REGION=${var.region}",
  #     "IMAGE_REGISTRY=${var.image_registry}",
  #     "IMAGE_REPOSITORY=${var.image_repository}",
  #     "IMAGE_TAG=${var.image_tag}",
  #     "IMAGE_LOCAL_NAME=${var.image_local_name}",
  #     "ECR_TOKEN=${var.ecr_token}"
  #   ]
  #   script = "scripts/bake-docker.sh"
  #   only   = ["amazon-ebs.illumibot-worker"]
  # }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }

}

