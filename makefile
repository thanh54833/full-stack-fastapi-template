
p_c:
	git add . && git commit -m "Update Document" || true
	git pull --rebase 2>/dev/null || true
	git push -u origin HEAD

# Cấu hình deploy SSH
SSH_HOST ?= 10.10.13.103
SSH_USER ?= devops
SSH_PASS ?= devops@123
REMOTE_DIR ?= src
REMOTE_REPO_DIR ?= dev_hub
GIT_USERNAME ?= thanh54833
GIT_TOKEN ?=
# Đổi URL repo nếu cần (định dạng owner/repo)
GIT_REPO_PATH ?= thanh54833/dev_hub.git

k:
	npx vibe-kanban

c:
	npx -y @anthropic-ai/claude-code

o:
	npx -y opencode-ai@latest

.PHONY: dev dev_d devbackend devfrontend kill killbackend killfrontend redev setup install p_c k c o deploy_ssh deply_ssh u_d

# Link local khi chạy bằng các target trong file này:
# - Backend: http://localhost:8000
# - Frontend: http://localhost:5173
#
# Link server (deploy_ssh):
# - Backend: http://10.10.13.103:8000
# - Frontend: http://10.10.13.103:5173 (Docker)

# Development stack chuẩn cho project hiện tại (FastAPI + React + Docker Compose).
dev: kill
	docker compose watch

dev_d: kill
	@echo "Starting docker compose stack in background..."
	docker compose up -d --build

devbackend:
	cd backend && uv sync && fastapi dev app/main.py

devfrontend:
	cd frontend && bun install && bun run dev

kill:
	-docker compose stop

killbackend:
	-docker compose stop backend

killfrontend:
	-docker compose stop frontend

redev: kill
	docker compose up --build --force-recreate

setup:
	cd backend && uv sync
	cd frontend && bun install

install: setup

u_d:
	docker compose up --build -d

d_s:
	@sshpass -p '$(SSH_PASS)' ssh -o StrictHostKeyChecking=no $(SSH_USER)@$(SSH_HOST) "set -e; cd '$(REMOTE_DIR)'; if [ ! -d '$(REMOTE_REPO_DIR)' ]; then git clone 'https://$(GIT_USERNAME):$(GIT_TOKEN)@github.com/$(GIT_REPO_PATH)' '$(REMOTE_REPO_DIR)'; fi; cd '$(REMOTE_REPO_DIR)'; if [ ! -d .git ]; then echo 'Thu muc $(REMOTE_DIR)/$(REMOTE_REPO_DIR) khong phai git repo'; exit 128; fi; git remote set-url origin 'https://$(GIT_USERNAME):$(GIT_TOKEN)@github.com/$(GIT_REPO_PATH)'; git stash push -u -m 'auto-deploy-ssh' >/dev/null 2>&1 || true; git fetch origin master; git checkout -B master origin/master; DOCKER_BUILDKIT=0 docker compose build; docker compose up -d --no-build; echo 'Docker compose started'"

deply_ssh: deploy_ssh


s:
	python3 -m http.server 5500