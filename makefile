
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

.PHONY: dev dev_d kill killbackend killfrontend redev setup install p_c k c o deploy_ssh deply_ssh u_d

# Link local khi chạy bằng các target trong file này:
# - Backend: http://localhost:8002
# - Frontend: http://localhost:3002
#
# Link server (deploy_ssh):
# - Backend: http://10.10.13.103:8002
# - Frontend: http://10.10.13.103:3002 (Docker)

# Một shell duy nhất: job nền không bị kill khi shell recipe kết thúc; wait chờ đúng 2 tiến trình.
dev: kill
	@echo "Starting backend and frontend..."; \
	(cd backend && python3 -m venv venv && ./venv/bin/pip install -r requirements.txt -q && ./venv/bin/python -m uvicorn main:app --reload --host 0.0.0.0 --port 8002) & \
	(cd frontend && npm run dev) & \
	echo "Backend: http://localhost:8002"; \
	echo "Frontend: http://localhost:3002"; \
	wait

dev_d: kill
	@echo "Starting backend and frontend in background..."; \
	nohup sh -c "cd backend && python3 -m venv venv && ./venv/bin/pip install -r requirements.txt -q && ./venv/bin/python -m uvicorn main:app --reload --host 0.0.0.0 --port 8002" > /tmp/dev_hub_backend.log 2>&1 & \
	nohup sh -c "cd frontend && npm run dev -- --port 3002" > /tmp/dev_hub_frontend.log 2>&1 & \
	echo "Backend running on :8002 (log: /tmp/dev_hub_backend.log)"; \
	echo "Frontend running on :3002 (log: /tmp/dev_hub_frontend.log)"

devbackend:
	cd backend && python3 -m venv venv && ./venv/bin/pip install -r requirements.txt -q; ./venv/bin/python -m uvicorn main:app --reload --host 0.0.0.0 --port 8002

devfrontend:
	cd frontend && npm run dev

kill:
	@for p in $$(lsof -nP -iTCP:8002 -sTCP:LISTEN -t 2>/dev/null); do kill -9 $$p; done
	@for p in $$(lsof -nP -iTCP:3002 -sTCP:LISTEN -t 2>/dev/null); do kill -9 $$p; done

killbackend:
	@for p in $$(lsof -nP -iTCP:8002 -sTCP:LISTEN -t 2>/dev/null); do kill -9 $$p; done

killfrontend:
	@for p in $$(lsof -nP -iTCP:3002 -sTCP:LISTEN -t 2>/dev/null); do kill -9 $$p; done

redev: kill
	@(cd backend && python3 -m venv venv && ./venv/bin/pip install -r requirements.txt -q && ./venv/bin/python -m uvicorn main:app --reload --host 0.0.0.0 --port 8002) & \
	(cd frontend && npm run dev) & \
	wait

setup:
	cd backend && test -d venv || python3 -m venv venv && ./venv/bin/pip install -r requirements.txt
	cd frontend && npm install

install: setup

u_d:
	docker compose up --build -d

d_s:
	@sshpass -p '$(SSH_PASS)' ssh -o StrictHostKeyChecking=no $(SSH_USER)@$(SSH_HOST) "set -e; cd '$(REMOTE_DIR)'; if [ ! -d '$(REMOTE_REPO_DIR)' ]; then git clone 'https://$(GIT_USERNAME):$(GIT_TOKEN)@github.com/$(GIT_REPO_PATH)' '$(REMOTE_REPO_DIR)'; fi; cd '$(REMOTE_REPO_DIR)'; if [ ! -d .git ]; then echo 'Thu muc $(REMOTE_DIR)/$(REMOTE_REPO_DIR) khong phai git repo'; exit 128; fi; git remote set-url origin 'https://$(GIT_USERNAME):$(GIT_TOKEN)@github.com/$(GIT_REPO_PATH)'; git stash push -u -m 'auto-deploy-ssh' >/dev/null 2>&1 || true; git fetch origin master; git checkout -B master origin/master; DOCKER_BUILDKIT=0 docker compose build; docker compose up -d --no-build; echo 'Docker compose started'"

deply_ssh: deploy_ssh


s:
	python3 -m http.server 5500