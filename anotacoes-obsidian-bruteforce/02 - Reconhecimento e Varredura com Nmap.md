---
title: "02 - Reconhecimento e Varredura com Nmap"
tags:
  - reconnaissance
  - nmap
  - port-scanning
  - services
created: 2024-11-17
type: guide
status: completed
---

# 🔍 02 - Reconhecimento e Varredura com Nmap

> [!abstract] Objetivo do Módulo
> Mapear o espaço de portas abertas na máquina alvo vulnerável (`192.168.56.101`), identificar versões exatas dos softwares de rede em execução e selecionar os serviços de autenticação que serão auditados no laboratório.

---

## 1. Estratégia de Varredura

Antes de disparar qualquer ataque de força bruta, o reconhecimento fornece inteligência fundamental:
- Quais portas estão abertas?
- Qual o daemon específico (ex: `vsftpd` vs `ProFTPD`)?
- Existem vulnerabilidades conhecidas ou portas alternativas abertas?

---

## 2. Execução da Varredura no Kali Linux

### Comando de Varredura Direcionada:
```bash
nmap -p 21,22,80,139,445 -sV -sC -Pn 192.168.56.101 -oN nmap_recon.txt
```

> [!tip] Detalhamento das Flags do Nmap:
> - `-p 21,22,80,139,445`: Foca nas portas de interesse para auditoria de credenciais.
> - `-sV`: *(Service Version)* Interroga os banners de serviço para descobrir a versão exata do software.
> - `-sC`: Executa scripts NSE (*Nmap Scripting Engine*) padrão para enumeração segura.
> - `-Pn`: Desabilita a detecção preliminar de host ativo (evita bloqueios por ausência de resposta ICMP).
> - `-oN nmap_recon.txt`: Salva o resultado em formato legível de texto.

---

## 3. Saída do Terminal e Análise de Serviços

```text
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-11-17 10:15 -03
Nmap scan report for 192.168.56.101
Host is up (0.00042s latency).

PORT    STATE SERVICE     VERSION
21/tcp  open  ftp         vsftpd 2.3.4
22/tcp  open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
80/tcp  open  http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
|_http-title: Metasploitable2 - Linux
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)

Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

> [!screenshot] Registro Visual Recomendado
> Capture o terminal com a saída do Nmap e salve em `attachments/`:
> ![[02_nmap_scan_result.png|750]]
> *Figura 2: Resultado da varredura Nmap detalhando serviços e portas abertas.*

---

## 4. Tabela de Serviços Mapeados para Auditoria

| Porta | Protocolo | Serviço / Daemon | Cenário de Teste Planejado |
| :---: | :---: | :--- | :--- |
| **21** | TCP | `vsftpd 2.3.4` (FTP) | [[03 - Ataque em FTP com Medusa\|Ataque de Dicionário com Medusa]] |
| **80** | TCP | `Apache 2.2.8` (DVWA) | [[04 - Força Bruta Web no DVWA\|Automação de Formulário Web]] |
| **139 / 445** | TCP | `Samba 3.X` (SMB) | [[05 - Enumeração e Password Spraying em SMB\|Password Spraying Corporativo]] |

---

## 🔗 Próximo Passo
- Avançar para: [[03 - Ataque em FTP com Medusa]]
