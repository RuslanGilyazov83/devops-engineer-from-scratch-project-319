test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build

# -----------------------------
# Terraform (Yandex Cloud)
# -----------------------------
# Все параметры для backend (bucket/keys) задаём через переменные окружения:
# TF_STATE_BUCKET, TF_STATE_KEY, TF_STATE_ACCESS_KEY, TF_STATE_SECRET_KEY
#
# Зеркало провайдеров (если registry.terraform.io недоступен):
# terraform/terraform_mirror.tfrc подключается через TF_CLI_CONFIG_FILE.

TF_CLI_CONFIG_FILE := $(CURDIR)/terraform/terraform_mirror.tfrc
export TF_CLI_CONFIG_FILE

# Провайдер Terraform ждёт var.yc_* — это переменные Terraform, их задают как TF_VAR_yc_*.
# Удобно экспортировать YC_* из yc init (YC_CLOUD_ID, YC_FOLDER_ID, …) — пробросим в TF_VAR_*.
TF_VAR_yc_cloud_id ?= $(YC_CLOUD_ID)
TF_VAR_yc_folder_id ?= $(YC_FOLDER_ID)
TF_VAR_yc_zone ?= $(YC_ZONE)
TF_VAR_yc_token ?= $(YC_TOKEN)
export TF_VAR_yc_cloud_id TF_VAR_yc_folder_id TF_VAR_yc_zone TF_VAR_yc_token

tf-init:
	cd terraform && terraform init \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="key=$(TF_STATE_KEY)" \
		-backend-config="access_key=$(TF_STATE_ACCESS_KEY)" \
		-backend-config="secret_key=$(TF_STATE_SECRET_KEY)"

tf-fmt:
	cd terraform && terraform fmt -recursive

tf-validate:
	cd terraform && terraform validate

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply

# Без вопроса yes (удобно, если make «глотает» stdin в WSL)
tf-apply-auto:
	cd terraform && terraform apply -auto-approve

# Apply точечно (например, только security group), чтобы не трогать остальное.
tf-apply-auto-target:
	cd terraform && terraform apply -auto-approve -target="$(TARGET)"

tf-destroy:
	cd terraform && terraform destroy

.PHONY: tf-init tf-fmt tf-validate tf-plan tf-apply tf-apply-auto tf-apply-auto-target tf-destroy
