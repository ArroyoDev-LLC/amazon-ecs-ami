#!/usr/bin/env bash

set -e

declare -a MODEL_TYPES=(
	annotators
	clip_vision
	codeformer
	controlnet
	esrgan
	gfpgan
	lora
	safety_checker
	ti
	vae
	compvis
)

MODELS_DIR="/mnt/models"
BUCKET_NAME="illumibot-models"
BUCKET_PATH="illumibot-models"

BUCKET_URI="s3://${BUCKET_NAME}/${BUCKET_PATH}"

prepare_deps() {
	sudo yum install -y zstd unzip
	sudo yum remove -y awscli || true
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
}

prepare_env() {
	sudo mkdir -p $MODELS_DIR
	sudo /usr/local/bin/aws configure set s3_use_accelerate_endpoint true
}

download_archive() {
	local key model_type="${1?Missing name}"
	key="${BUCKET_URI}/${model_type}.tar.zst"
	echo "Retrieving: ${key}"
	sudo /usr/local/bin/aws s3 cp "$key" "$MODELS_DIR/"
}

unpack_archives() {
	echo "Unpacking..."
	sudo find "$MODELS_DIR" -type f -name '*.tar.zst' -execdir sh -c 'zstd -T0 --progress -d "$1" --output-dir-flat . && tar -xf "${1%.zst}" && rm "${1%.zst}"' sh {} \; -exec rm {} \;
}

install_models() {
	echo "Downloading models ($BUCKET_URI -> $MODELS_DIR)"
	# download and unpack one-by-one to free up space taken by archives
	for model in "${MODEL_TYPES[@]}"; do
		echo "Handling: ${model}"
		download_archive "$model"
		echo "Archive downloaded. Disk Space:"
		sudo df -h
		unpack_archives
		echo "Archive unpacked. Disk Space:"
		sudo df -h
		echo "Current Models:"
		sudo ls -al "$MODELS_DIR" || true
	done

	echo "Updating permissions"
	sudo chown -R ec2-user "$MODELS_DIR"
	echo "Done!"
}

main() {
	prepare_deps
	prepare_env
	install_models
}

main
