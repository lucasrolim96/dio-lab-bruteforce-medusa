# Medusa Cheat Sheet - Referência Rápida

O **Medusa** é uma ferramenta de auditoria de segurança paralela e modular para testes de força bruta e dicionário contra serviços de autenticação em rede.

---

## Sintaxe Geral

```bash
medusa [-h host | -H file] [-u username | -U file] [-p password | -P file] -M module [OPÇÕES]
```

---

## Parâmetros e Opções Principais

### Definição de Alvos
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-h <target>` | Define um único host alvo (IP ou hostname). | `-h 192.168.56.101` |
| `-H <file>` | Especifica um arquivo com múltiplos alvos. | `-H alvos.txt` |
| `-j <n>` | Número de hosts a testar simultaneamente (padrão: 1). | `-j 5` |

### Definição de Usuários
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-u <username>` | Testa apenas um usuário específico. | `-u root` |
| `-U <file>` | Especifica arquivo com lista de usuários (wordlist). | `-U users.txt` |

### Definição de Senhas
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-p <password>` | Testa uma senha específica (útil para Password Spraying). | `-p 123456` |
| `-P <file>` | Especifica arquivo com lista de senhas (wordlist). | `-P passwords.txt` |
| `-C <file>` | Arquivo com pares de credenciais (`usuario:senha`). | `-C combos.txt` |

### Módulos e Portas
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-M <module>` | Define o módulo do serviço a ser testado. | `-M ftp` |
| `-m <options>` | Passa parâmetros adicionais ao módulo escolhido. | `-m DIR:/dvwa/vulnerabilities/brute/` |
| `-n <port>` | Sobrescreve a porta padrão do serviço. | `-n 2121` |
| `-s` | Habilita conexão SSL/TLS. | `-s` |

### Controle de Execução e Performance
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-t <threads>` | Total de threads concorrentes por host (padrão: 16). | `-t 4` |
| `-T <hosts>` | Total de hosts testados simultaneamente. | `-T 2` |
| `-f` | *(Stop on first success)* Para a execução no momento em que encontrar a primeira credencial válida no host. | `-f` |
| `-F` | Para o teste para o usuário atual após achar a senha, mas continua para os próximos usuários. | `-F` |
| `-r <n>` | Intervalo em segundos entre tentativas de login. | `-r 2` |

### Nível de Log e Saída
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-v <1-6>` | Nível de verbosidade (1 = apenas erros, 4 = detalhado, 6 = debug completo). | `-v 4` |
| `-O <file>` | Arquivo para gravar os resultados positivos obtidos. | `-O resultado.txt` |
| `-e [n/s/ns]` | Verificações extras: `n` (senha em branco), `s` (senha igual ao usuário). | `-e ns` |

---

## Módulos Disponíveis no Kali Linux

Para listar todos os módulos instalados:
```bash
medusa -d
```

| Módulo | Protocolo / Serviço | Porta Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `ftp` | File Transfer Protocol | 21 | Suporta conexões passivas e ativas |
| `ssh` | Secure Shell | 22 | Autenticação SSH v2 via libssh2 |
| `http` | Servidor Web HTTP | 80 / 443 | Autenticação HTTP básica e formulários simples |
| `smbnt` | Samba / Windows SMB | 139 / 445 | Autenticação NTLM em compartilhamentos de arquivos |
| `mysql` | MySQL Database Server | 3306 | Conexão direta a servidores MySQL |
| `mssql` | Microsoft SQL Server | 1433 | Autenticação em instâncias MSSQL |
| `vnc` | Virtual Network Computing | 5900 | Autenticação de sessões VNC |
| `telnet` | Telnet | 23 | Protocolo legado de terminal em texto claro |

---

## Exemplos Práticos

### 1. Auditoria de FTP com parada no primeiro acerto
```bash
medusa -h 192.168.56.101 -U users.txt -P passwords.txt -M ftp -f -v 4
```

### 2. Password Spraying em SMB
```bash
medusa -h 192.168.56.101 -U smb_users.txt -p "msfadmin" -M smbnt -t 2
```

### 3. Teste em SSH com verificação de senha em branco e senha igual ao usuário
```bash
medusa -h 192.168.56.101 -u root -P passwords.txt -M ssh -e ns
```
