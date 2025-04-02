gpu_instance_types         = ["g6.xlarge"]
image_tag                  = "v1.5.1-cuda12.6"
image_local_name           = "illumibot-worker:v1.5.1-cuda12.6"
image_repository           = "illumibot-worker"
ami_version_illumibot      = "20250401"
models_ami_version         = "20250401"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-kernel-5.10-gpu-hvm-2.0.20250321-x86_64-ebs"
