gpu_instance_types         = ["g5.2xlarge"]
image_tag                  = "v10.9-cuda11.8"
image_local_name           = "illumibot-worker:v10.9-cuda11.8"
image_repository           = "illumibot-worker"
ami_version                = "20231211"
source_ami_illumibot_owner = "amazon"
source_ami_illumibot       = "amzn2-ami-ecs-gpu-hvm-2.0.20231204-x86_64-ebs"
