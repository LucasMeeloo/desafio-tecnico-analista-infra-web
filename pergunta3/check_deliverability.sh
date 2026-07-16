#!/usr/bin/env bash
# check_deliverability.sh
# Verifica SPF, DKIM (opcional), DMARC e PTR/rDNS de um domínio.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Uso: $0 <dominio> [seletor_dkim]"
    exit 1
fi

DOMAIN="$1"
DKIM_SELECTOR="${2:-}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    local status="$1"
    local message="$2"
    if [[ "$status" == "OK" ]]; then
        echo -e "[ ${GREEN}OK${NC} ] $message"
    else
        echo -e "[ ${RED}FALHA${NC} ] $message"
    fi
}

check_spf() {
    local spf_record
    spf_record=$(dig +short TXT "$DOMAIN" | { grep -i "v=spf1" || true; } | tr -d '"')
    if [[ -n "$spf_record" ]]; then
        print_status "OK" "SPF encontrado: $spf_record"
    else
        print_status "FALHA" "Registro SPF ausente no TXT do dominio."
    fi
}

check_dmarc() {
    local dmarc_record
    dmarc_record=$(dig +short TXT "_dmarc.$DOMAIN" | { grep -i "v=DMARC1" || true; } | tr -d '"')
    if [[ -n "$dmarc_record" ]]; then
        print_status "OK" "DMARC encontrado: $dmarc_record"
    else
        print_status "FALHA" "Registro DMARC ausente em _dmarc.$DOMAIN"
    fi
}

check_dkim() {
    if [[ -z "$DKIM_SELECTOR" ]]; then
        echo -e "[ AVISO ] DKIM ignorado. Forneca o seletor como segundo argumento."
        return
    fi
    local dkim_record
    dkim_record=$(dig +short TXT "${DKIM_SELECTOR}._domainkey.${DOMAIN}" | { grep -i "v=DKIM1" || true; } | tr -d '"')
    if [[ -n "$dkim_record" ]]; then
        print_status "OK" "DKIM encontrado para seletor '$DKIM_SELECTOR': $dkim_record"
    else
        print_status "FALHA" "Registro DKIM ausente em ${DKIM_SELECTOR}._domainkey.${DOMAIN}"
    fi
}

check_ptr() {
    local mx_record mail_ip ptr_record
    mx_record=$(dig +short MX "$DOMAIN" | sort -n | head -n 1 | awk '{print $2}')
    
    if [[ -n "$mx_record" ]]; then
        mail_ip=$(dig +short A "$mx_record" | tail -n 1)
    else
        mail_ip=$(dig +short A "$DOMAIN" | tail -n 1)
    fi

    if [[ -z "${mail_ip:-}" ]]; then
        print_status "FALHA" "Nao foi possivel resolver o IP para $DOMAIN ou seus MX."
        return
    fi

    ptr_record=$(dig +short -x "$mail_ip" 2>/dev/null | grep -v ";;" | tail -n 1)
    if [[ -n "$ptr_record" ]]; then
        print_status "OK" "rDNS/PTR para o IP $mail_ip aponta para: $ptr_record"
    else
        print_status "FALHA" "rDNS/PTR ausente para o IP $mail_ip."
    fi
}

report() {
    echo "========================================"
    echo " Relatorio de Deliverability: $DOMAIN"
    echo "========================================"
    check_spf
    check_dmarc
    check_dkim
    check_ptr
    echo "========================================"
}

report