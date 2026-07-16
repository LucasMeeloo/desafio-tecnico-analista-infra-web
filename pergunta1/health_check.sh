#!/usr/bin/env bash
# health_check.sh
# Verifica a saúde do Nginx e PHP-FPM. Desenvolvido para execução via cron.
# Utiliza flock para evitar execuções concorrentes (idempotência operacional).

set -euo pipefail

LOG_FILE="/var/log/health_check.log"
NGINX_URL="http://127.0.0.1/"
PHP_FPM_SERVICE="php8.1-fpm" 
NGINX_SERVICE="nginx"

# Lock file para evitar encavalamento de cron
LOCK_FILE="/tmp/health_check.lock"

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

alert() {
    local message="$1"
    # Em produção, isso poderia ser um cURL para um webhook do Slack/Teams/Zabbix
    log "[ALERTA CRÍTICO] $message"
}

check_services() {
    if ! systemctl is-active --quiet "$NGINX_SERVICE"; then
        alert "Serviço Nginx está inativo."
        return 1
    fi

    if ! systemctl is-active --quiet "$PHP_FPM_SERVICE"; then
        alert "Serviço PHP-FPM ($PHP_FPM_SERVICE) está inativo."
        return 1
    fi
}

check_http_response() {
    # Testa a resposta HTTP com timeout de 5 segundos
    local http_code
    http_code=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "$NGINX_URL" || echo "000")

    if [[ "$http_code" == "000" ]]; then
        alert "Timeout ou falha ao conectar no Nginx em $NGINX_URL."
        return 1
    elif [[ "$http_code" =~ ^5 ]]; then
        alert "Nginx retornou erro de servidor: HTTP $http_code."
        return 1
    fi
}

main() {
    # Garante execução exclusiva via file lock
    exec 9> "$LOCK_FILE"
    if ! flock -n 9; then
        log "[AVISO] Script já está em execução. Saindo para evitar sobreposição."
        exit 1
    fi

    check_services
    check_http_response
}

# Executa o main passando todos os argumentos
main "$@"