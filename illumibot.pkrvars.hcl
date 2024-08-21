gpu_instance_types         = ["g6.xlarge"]
image_tag                  = "v18.2-cuda12.1"
image_local_name           = "illumibot-worker:v18.2-cuda12.1"
image_repository           = "illumibot-worker"
ami_version_illumibot      = "20240820"
models_ami_version         = "20240820"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-kernel-5.10-gpu-hvm-2.0.20240818-x86_64-ebs"
