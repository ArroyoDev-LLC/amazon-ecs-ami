gpu_instance_types         = ["g6.xlarge"]
image_tag                  = "v16.2-cuda12.1"
image_local_name           = "illumibot-worker:v16.2-cuda12.1"
image_repository           = "illumibot-worker"
ami_version_illumibot      = "20240514"
models_ami_version         = "20240514"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-gpu-hvm-2.0.20240424-x86_64-ebs"
