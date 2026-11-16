#!/usr/bin/env bash
# ==============================================================================
# Script: network_recon.sh
# Finalidade: Reconhecimento e validação de conectividade com a VM vulnerável
# Bootcamp Santander Cibersegurança - DIO
# ==============================================================================

TARGET_IP="${1:-192.168.56.101}"

echo "=================================================="
echo "[+] Iniciando Reconhecimento da Rede do Laboratório"
echo "[+] Alvo Definido: $TARGET_IP"
echo "=================================================="

# 1. Teste de Conectividade ICMP (Ping)
echo -e "\n[*] 1. Testando conectividade com o alvo via ICMP..."
if ping -c 2 -W 2 "$TARGET_IP" > /dev/null 2>&1; then
    echo "[+] Alvo $TARGET_IP esta acessivel e respondendo ao ping."
else
    echo "[-] AVISO: Alvo nao respondeu ao ping. Verifique se as VMs estao na mesma rede Host-Only."
fi

# 2. Varredura Rápida de Serviços Principais (FTP, SSH, HTTP, SMB)
echo -e "\n[*] 2. Executando varredura direcionada via Nmap (Portas 21, 22, 80, 139, 445)..."
nmap -p 21,22,80,139,445 -sV -sC -Pn "$TARGET_IP" -oN "recon_${TARGET_IP}.txt"

echo -e "\n[✓] Varredura concluída! Resultado salvo em recon_${TARGET_IP}.txt"
echo "=================================================="
