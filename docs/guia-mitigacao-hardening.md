# 🛡️ Guia Completo de Mitigação, Hardening e Defesa Ativa

Em uma auditoria de segurança ética (*Red Team* ou *Blue Team*), o objetivo final de demonstrar vulnerabilidades de autenticação é fornecer recomendações técnicas precisas para fechar as brechas identificadas.

Abaixo estão as estratégias de mitigação organizadas por camadas de defesa.

---

## 1. Políticas de Bloqueio de Conta (*Account Lockout*)

O bloqueio temporário impede ataques de força bruta direcionados a um único usuário.

### No Linux (PAM - Pluggable Authentication Modules)
Utilize o módulo `pam_faillock` (padrão em distribuições modernas como Debian/Ubuntu/RHEL):

Edite `/etc/pam.d/common-auth`:
```pam
auth required pam_faillock.so preauth audit silent deny=5 unlock_time=900
auth [default=1 success=ignore] pam_unix.so nullok_secure
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900
auth sufficient pam_faillock.so authsucc
```
* **Parâmetros:**
  * `deny=5`: Bloqueia o acesso após 5 tentativas consecutivas incorretas.
  * `unlock_time=900`: Mantém a conta bloqueada por 15 minutos (900 segundos).

---

## 2. Implementação de Rate Limiting com Fail2Ban

O **Fail2Ban** monitora os arquivos de log do sistema (`/var/log/auth.log`, `/var/log/vsftpd.log`, logs do Apache/Nginx) e insere regras dinâmicas no firewall (`iptables`/`nftables`) para banir o endereço IP de onde partem os ataques.

### Protegendo o Serviço FTP (vsftpd)
No arquivo `/etc/fail2ban/jail.local`:
```ini
[vsftpd]
enabled  = true
port     = ftp,ftp-data,ftps,ftps-data
filter   = vsftpd
logpath  = /var/log/vsftpd.log
maxretry = 3
findtime = 600
bantime  = 3600
```
* Qualquer IP que erre 3 tentativas em uma janela de 10 minutos terá seu tráfego banido por 1 hora no nível de kernel.

---

## 3. Defesas contra Password Spraying

O *Password Spraying* foi concebido exatamente para burlar o *Account Lockout*, pois o atacante realiza poucas tentativas por usuário distribuídas em centenas de contas.

### Medidas de Mitigação:
1. **Autenticação Multifator (MFA/2FA):** Mesmo que o atacante descubra que a senha é `123456` ou `Empresa@2026`, ele não terá acesso sem a chave física (FIDO2/WebAuthn) ou token TOTP.
2. **Listas de Bloqueio de Senhas Conhecidas (*Password Blacklists*):**
   * Impedir que colaboradores escolham senhas fracas, palavras do dicionário corporativo ou senhas que constem em vazamentos públicos (*Have I Been Pwned API*).
3. **Análise Comportamental (UEBA) no SIEM:**
   * Configurar alertas quando um único endereço IP ou subnet tentar autenticar em mais de 3 contas diferentes em um intervalo curto de tempo.

---

## 4. Hardening do Serviço SMB (Samba / Windows)

No Metasploitable 2 e em redes antigas, o SMB costuma permitir sessões nulas (*Null Sessions*), enumeração irrestrita de usuários e ausência de assinatura de pacotes.

### Recomendações de Hardening (`/etc/samba/smb.conf`):
```ini
[global]
    # Desabilitar protocolos inseguros e legados (SMBv1)
    server min protocol = SMB2_10
    client min protocol = SMB2_10

    # Forçar assinatura digital de pacotes SMB
    server signing = mandatory

    # Impedir acesso anônimo/convidado (Guest/Null Session)
    restrict anonymous = 2
    map to guest = Never
```

---

## 5. Proteção de Aplicações Web (DVWA / Portais de Login)

Para proteger formulários web contra Hydra, Medusa ou scripts customizados:

1. **Desafio CAPTCHA:**
   * Ativar desafios Cloudflare Turnstile ou Google reCAPTCHA v3 após a 2ª tentativa incorreta.
2. **Mecanismo de Backoff Exponencial (*Tarpitting*):**
   * Adicionar um delay artificial de resposta a cada tentativa consecutiva falha (1s, 2s, 4s, 8s). Isso destrói a eficiência de ferramentas multithread.
3. **Web Application Firewall (WAF):**
   * Configurar regras ModSecurity (OWASP Core Rule Set) ou AWS WAF para inspecionar requisições POST frequentes ao endpoint de autenticação.

---

## 6. Matriz de Detecção (Blue Team / SOC)

| Evento / Log | ID do Evento (Windows) | Arquivo de Log (Linux) | Assinatura de Alerta |
| :--- | :--- | :--- | :--- |
| **Tentativa de Força Bruta** | Event ID 4625 (Falha de Logon) | `/var/log/auth.log` | Mais de 10 falhas consecutivas para o mesmo `TargetUserName`. |
| **Password Spraying** | Event ID 4625 com alto volume | `/var/log/auth.log` | Múltiplos eventos 4625 com o mesmo `SourceNetworkAddress` visando diferentes usuários. |
| **Logon Bem-Sucedido Suspeito** | Event ID 4624 (Logon bem-sucedido) | `/var/log/auth.log` | Evento 4624 imediatamente precedido por múltiplos 4625 da mesma origem. |
