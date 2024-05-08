gpu_instance_types         = ["g6.xlarge"]
image_tag                  = "v14.0-cuda11.8"
image_local_name           = "illumibot-worker:v14.0-cuda11.8"
image_repository           = "illumibot-worker"
ami_version_illumibot      = "20240318"
models_ami_version         = "20240318"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-gpu-hvm-2.0.20240305-x86_64-ebs"
