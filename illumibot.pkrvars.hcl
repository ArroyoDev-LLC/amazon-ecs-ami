gpu_instance_types         = ["g5.2xlarge"]
image_tag                  = "v13.1-cuda11.8"
image_local_name           = "illumibot-worker:v13.1-cuda11.8"
image_repository           = "illumibot-worker"
ami_version_illumibot      = "20240313"
models_ami_version         = "20240313"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-gpu-hvm-2.0.20240305-x86_64-ebs"
