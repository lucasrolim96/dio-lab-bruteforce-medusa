# Guia de Mitigação e Hardening de Serviços

O objetivo principal de qualquer teste de intrusão é diagnosticar vulnerabilidades para orientar a implementação de controles defensivos eficientes.

Abaixo estão as medidas de segurança recomendadas para conter ataques de força bruta, dicionário e password spraying.

---

## 1. Políticas de Bloqueio de Conta (Account Lockout)

### No Linux com PAM (`pam_faillock`)
O módulo `pam_faillock` é o padrão atual em distribuições Linux (Debian, Ubuntu e RHEL).

Para configurar no arquivo `/etc/pam.d/common-auth`:
```pam
auth required pam_faillock.so preauth audit silent deny=5 unlock_time=900
auth [default=1 success=ignore] pam_unix.so nullok_secure
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900
auth sufficient pam_faillock.so authsucc
```

- `deny=5`: Bloqueia o usuário após 5 tentativas consecutivas incorretas.
- `unlock_time=900`: Mantém a conta bloqueada durante 15 minutos (900 segundos).

---

## 2. Rate Limiting com Fail2Ban

O **Fail2Ban** monitora os arquivos de log do sistema e insere automaticamente regras no firewall (`iptables` ou `nftables`) para bloquear IPs com excesso de erros.

### Proteção para FTP (`/etc/fail2ban/jail.local`):
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
- Bloqueia o IP por 1 hora se ocorrerem 3 falhas em um intervalo de 10 minutos.

---

## 3. Defesa contra Password Spraying

Como o Password Spraying testa uma única senha contra vários usuários diferentes, ele não atinge o limite de tentativas por conta. As melhores defesas são:

1. **Autenticação de Dois Fatores (MFA / 2FA):**  
   Impedir autenticações puramente baseadas em senha nos pontos de acesso externo (VPN, portais web e SSH).
2. **Lista de Senhas Proibidas (*Password Blacklist*):**  
   Impedir a definição de senhas fracas ou previsíveis (nomes da empresa, datas, estações do ano como `Verao@2024`).
3. **Detecção Comportamental em SIEM / SOC:**  
   Regras de correlação para alertar quando o mesmo endereço IP de origem gerar falhas de logon em mais de 3 nomes de usuários distintos em um período curto.

---

## 4. Hardening do Serviço Samba / SMB

Em servidores Linux que utilizam Samba (`/etc/samba/smb.conf`):

```ini
[global]
    # Desativar versão obsoleta do protocolo SMB (SMBv1)
    server min protocol = SMB2_10
    client min protocol = SMB2_10

    # Forçar assinatura digital de pacotes
    server signing = mandatory

    # Desabilitar sessões anônimas e contas de convidado
    restrict anonymous = 2
    map to guest = Never
```

---

## 5. Proteções em Aplicações Web

1. **Desafios CAPTCHA:** Ativar CAPTCHA progressivo após a 2ª tentativa de logon incorreta.
2. **Atraso Progressivo (*Tarpitting*):** Introduzir um pequeno atraso (1 a 3 segundos) nas respostas de login com falha, o que reduz drasticamente a taxa de requisições de ferramentas automatizadas.
3. **Web Application Firewall (WAF):** Aplicar limites de taxa (*rate limit*) de requisições POST para a rota de autenticação.
