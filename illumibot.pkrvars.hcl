gpu_instance_types         = ["g6.xlarge"]
image_tag                  = "v15.0-cuda11.8"
image_local_name           = "illumibot-worker:v15.0-cuda11.8"
image_repository           = "illumibot-worker"
ami_version_illumibot      = "20240509"
models_ami_version         = "20240509"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-gpu-hvm-2.0.20240424-x86_64-ebs"
