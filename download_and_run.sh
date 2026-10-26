#!/usr/bin/env bash

set -euo pipefail

# ----------------------------- НАСТРОЙКИ ------------------------------------
REPO_URL="https://github.com/sled-tut/shvirtd-example-python.git"
BRANCH="main"                          # ветка (можно оставить пустой "")
TARGET_DIR="/opt"            # куда клонировать
COMPOSE_FILE="compose.yaml"            # имя compose-файла

log()  { printf '\033[1;34m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }


log "Проверяю Git на сервере…"
if !  command -v git >/dev/null 2>&1; then
  log "Git не установлен — ставлю через apt-get…"
  export DEBIAN_FRONTEND=noninteractive; apt-get update -qq && apt-get install -y git
else
  log "Git уже установлен."
fi

log "Клонирую ${REPO_URL} в ${TARGET_DIR}…"

if [ -d '${TARGET_DIR}/.git' ]; then
  echo 'Репозиторий уже существует — обновляю git pull.'
  cd '${TARGET_DIR}' && git pull --ff-only
else
  rm -r ${TARGET_DIR}
  git clone  ${REPO_URL} ${TARGET_DIR}
fi

log "Поднимаю проект через ${COMPOSE_FILE}…"
cd ${TARGET_DIR}
[ -f "compose.yaml" ] || { echo 'Не найден ${COMPOSE_FILE} в ${TARGET_DIR}'; exit 1; }

docker compose -f ${COMPOSE_FILE} up -d --build
docker compose -f ${COMPOSE_FILE} ps

log "Готово ✅  Проект развёрнут!"

