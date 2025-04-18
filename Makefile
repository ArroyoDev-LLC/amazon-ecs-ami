PACKER_VERSION := 1.7.4
KERNEL := $(shell uname -s | tr A-Z a-z)
ARCH := $(shell uname -m)
ECR_TOKEN := $(shell aws ecr get-login-password --region us-east-1)

ifeq (${ARCH},arm64)
	ARCH_ALT=arm64
endif
ifeq (${ARCH},aarch64)
	ARCH_ALT=arm64
endif
ifeq (${ARCH},x86_64)
	ARCH_ALT=amd64
endif

PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_${KERNEL}_${ARCH_ALT}.zip"
SHFMT_URL="https://github.com/mvdan/sh/releases/download/v3.4.0/shfmt_v3.4.0_${KERNEL}_${ARCH_ALT}"
SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/v0.7.2/shellcheck-v0.7.2.${KERNEL}.${ARCH}.tar.xz"

packer:
	curl -fLSs ${PACKER_URL} -o ./packer.zip
	unzip ./packer.zip
	rm ./packer.zip

release-al1.auto.pkrvars.hcl:
	echo "Missing configuration file: release-al1.auto.pkrvars.hcl."
	exit 1

release-al2.auto.pkrvars.hcl:
	echo "Missing configuration file: release-al2.auto.pkrvars.hcl."
	exit 1

release-al2023.auto.pkrvars.hcl:
	echo "Missing configuration file: release-al2023.auto.pkrvars.hcl."
	exit 1

.PHONY: check-region
check-region:
	@bash -c "if [ -z ${REGION} ]; then echo 'ERROR: REGION variable must be set. Example: \"REGION=us-west-2 make al2\"'; exit 1; fi"

.PHONY: check-vars
check-vars:
	@bash -c "if [ -z ${ILLUMI_AMI_BUILD_DATE} ]; then echo 'ERROR: ILLUMI_AMI_BUILD_DATE variable must be set. Example: \"ILLUMI_AMI_BUILD_DATE=20241008 make illumibot\"'; exit 1; fi"
	@bash -c "echo 'Using build date: ${ILLUMI_AMI_BUILD_DATE}'"
	@bash -c "echo 'Using build version: ${ILLUMI_VERSION}'"

.PHONY: init
init: packer
	./packer init .

.PHONY: packer-fmt
packer-fmt: packer
	./packer fmt -check .

.PHONY: validate
validate: check-region init
	./packer validate --syntax-only -var-file illumibot.pkrvars.hcl -var "region=${REGION}" .
	- ./packer validate -var-file illumibot.pkrvars.hcl -var "region=${REGION}" .

.PHONY: al1
al1: check-region init validate release-al1.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al1" -var "region=${REGION}" .

.PHONY: al2
al2: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2" -var "region=${REGION}" .

.PHONY: al2arm
al2arm: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2arm" -var "region=${REGION}" .

.PHONY: al2gpu
al2gpu: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2gpu" -var "region=${REGION}" .

.PHONY: al2keplergpu
al2keplergpu: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2keplergpu" -var "region=${REGION}" .

.PHONY: al2inf
al2inf: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2inf" -var "region=${REGION}" .

.PHONY: al2kernel5dot10
al2kernel5dot10: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2kernel5dot10" -var "region=${REGION}" .

.PHONY: al2kernel5dot10arm
al2kernel5dot10arm: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2kernel5dot10arm" -var "region=${REGION}" .

.PHONY: al2kernel5dot10gpu
al2kernel5dot10gpu: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2kernel5dot10gpu" -var "region=${REGION}" .

.PHONY: al2kernel5dot10inf
al2kernel5dot10inf: check-region init validate release-al2.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2kernel5dot10inf" -var "region=${REGION}" .

.PHONY: al2023
al2023: check-region init validate release-al2023.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2023" -var "region=${REGION}" .

.PHONY: al2023arm
al2023arm: check-region init validate release-al2023.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2023arm" -var "region=${REGION}" .

.PHONY: al2023neu
al2023neu: check-region init validate release-al2023.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2023neu" -var "region=${REGION}" .

.PHONY: al2023gpu
al2023gpu: check-region init validate release-al2023.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.al2023gpu" -var "region=${REGION}" .

.PHONY: illumibot-models
illumibot-models: check-region init validate release.auto.pkrvars.hcl
	./packer build -only="amazon-ebs.illumibot-models" -var "region=${REGION}" -var-file illumibot.pkrvars.hcl -var "ecr_token=$(ECR_TOKEN)" .

.PHONY: illumibot
illumibot: check-region check-vars init validate
	./packer build -only="amazon-ebs.illumibot-worker" -var "ami_version_illumibot=${ILLUMI_AMI_BUILD_DATE}" -var "image_tag=${ILLUMI_VERSION}" -var "image_local_name=illumibot-worker:${ILLUMI_VERSION}" -var "region=${REGION}" -var-file illumibot.pkrvars.hcl -var "ecr_token=$(ECR_TOKEN)" -var "security_group_id=$(AWS_SECURITY_GROUP)" -var "subnet_id=$(AWS_SUBNET_ID)" -var "vpc_id=$(AWS_VPC_ID)" .


shellcheck:
	curl -fLSs ${SHELLCHECK_URL} -o /tmp/shellcheck.tar.xz
	tar -xvf /tmp/shellcheck.tar.xz -C /tmp --strip-components=1
	mv /tmp/shellcheck ./shellcheck
	rm /tmp/shellcheck.tar.xz

shfmt:
	curl -fLSs ${SHFMT_URL} -o ./shfmt
	chmod +x ./shfmt

.PHONY: fmt
fmt: packer shfmt
	./packer fmt .
	./shfmt -l -s -w -i 4 ./*.sh ./*/*.sh ./*/*/*.sh

.PHONY: static-check
static-check: packer-fmt shfmt shellcheck
	REGION=us-west-2 make validate
	./shfmt -d -s -w -i 4 ./*.sh ./*/*.sh ./*/*/*.sh
	./shellcheck --severity=error --exclude=SC2045 ./*.sh ./*/*.sh ./*/*/*.sh

.PHONY: clean
clean:
	-rm manifest.json
	-rm shellcheck
	-rm shfmt
	-rm packer
