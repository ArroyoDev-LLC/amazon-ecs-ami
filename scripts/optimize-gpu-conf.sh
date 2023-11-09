#!/bin/bash
set -ex

if [[ $AMI_TYPE != "al2gpu" && $AMI_TYPE != "al2keplergpu" ]]; then
    exit 0
fi

# Enable nvidia-persistenced service
sudo systemctl enable --now nvidia-persistenced

# Get the instance type of the current EC2 instance
instance_type=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
instance_family=$(echo $instance_type | cut -d'.' -f1)

# Check if the instance family is g2, g3, or p2 and execute the command
if [[ "$instance_family" == "g2" || "$instance_family" == "g3" || "$instance_family" == "p2" ]]; then
    sudo nvidia-smi --auto-boost-default=0
fi

# Execute the command based on the instance type family
case $instance_family in
    g3)
        sudo nvidia-smi -ac 2505,1177
        ;;
    g4dn)
        sudo nvidia-smi -ac 5001,1590
        ;;
    g5)
        sudo nvidia-smi -ac 6250,1710
        ;;
    p2)
        sudo nvidia-smi -ac 2505,875
        ;;
    p3)
        sudo nvidia-smi -ac 877,1530
        ;;
    p3dn)
        sudo nvidia-smi -ac 877,1530
        ;;
    p4dn)
        sudo nvidia-smi -ac 1215,1410
        ;;
    p4de)
        sudo nvidia-smi -ac 1593,1410
        ;;
    p5)
        sudo nvidia-smi -ac 2619,1980
        ;;
    *)
        echo "No specific nvidia-smi command for this instance type family."
        ;;
esac
