# 📖 Medusa Cheat Sheet & Guia de Referência Rápida

O **Medusa** é uma ferramenta de auditoria de segurança e ataque de força bruta paralela, modular e de alta velocidade para quebra de credenciais em serviços de rede. Desenvolvido para ser mais estável e modular que seus antecessores.

---

## 🚀 Sintaxe Geral

```bash
medusa [-h host | -H file] [-u username | -U file] [-p password | -P file] -M module [OPÇÕES]
```

---

## 📌 Parâmetros e Opções Principais

### 1. Definição de Alvos
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-h <target>` | Define um único host alvo (IP ou hostname). | `-h 192.168.56.101` |
| `-H <file>` | Especifica um arquivo com múltiplos endereços de destino. | `-H alvos.txt` |
| `-j <n>` | Número de hosts a serem testados simultaneamente (padrão: 1). | `-j 5` |

### 2. Definição de Usuários
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-u <username>` | Testa apenas um usuário específico. | `-u root` |
| `-U <file>` | Especifica um arquivo de lista de usuários (wordlist). | `-U users.txt` |

### 3. Definição de Senhas
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-p <password>` | Testa uma senha específica (útil para **Password Spraying**). | `-p 123456` |
| `-P <file>` | Especifica um arquivo de lista de senhas (wordlist). | `-P passwords.txt` |
| `-C <file>` | Arquivo de credenciais combinadas no formato `usuario:senha`. | `-C combos.txt` |

### 4. Controle de Módulos e Portas
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-M <module>` | Nome do módulo de serviço a ser executado. | `-M ftp` |
| `-m <options>` | Parâmetro adicional específico passado ao módulo. | `-m DIR:/dvwa/vulnerabilities/brute/` |
| `-n <port>` | Sobrescreve a porta padrão do serviço. | `-n 2121` |
| `-s` | Habilita conexão SSL/TLS. | `-s` |

### 5. Controle de Execução e Performance
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-t <threads>` | Total de threads simultâneas por host (padrão: 16). | `-t 4` |
| `-T <hosts>` | Total de hosts testados concorrentemente. | `-T 2` |
| `-f` | **Stop on first success:** Interrompe a execução assim que encontrar a primeira credencial válida para o host. | `-f` |
| `-F` | Interrompe o teste para o usuário atual assim que achar a senha dele, mas continua testando outros usuários. | `-F` |
| `-r <n>` | Intervalo em segundos entre tentativas de login (útil contra Rate Limiting). | `-r 2` |

### 6. Verbosidade e Saída
| Flag | Descrição | Exemplo |
| :--- | :--- | :--- |
| `-v <1-6>` | Nível de verbosidade (1 = erros graves, 4 = padrão detalhado, 6 = debug profundo). | `-v 4` |
| `-O <file>` | Arquivo onde os resultados bem-sucedidos serão gravados. | `-O resultado.txt` |
| `-e [n/s/ns]` | Modificadores extras de verificação: `n` (senha nula), `s` (senha igual ao usuário). | `-e ns` |

---

## 🛠️ Módulos Mais Populares do Medusa

Para listar todos os módulos disponíveis no Kali Linux:
```bash
medusa -d
```

| Módulo | Protocolo / Serviço | Porta Padrão | Observações |
| :--- | :--- | :--- | :--- |
| `ftp` | File Transfer Protocol | 21 | Suporta modo passivo/ativo |
| `ssh` | Secure Shell | 22 | Requer biblioteca `libssh2` |
| `http` | HTTP / Formulários Web | 80 / 443 | Suporta autenticação básica, Digest e Forms |
| `smbnt` | Server Message Block / Samba | 139 / 445 | Autenticação NTLM para Windows/Linux |
| `mysql` | MySQL Database Server | 3306 | Conexão direta ao banco |
| `mssql` | Microsoft SQL Server | 1433 | Autenticação SQL Server |
| `vnc` | Virtual Network Computing | 5900 | Apenas autenticação por senha |
| `smtp` | Simple Mail Transfer Protocol | 25 | Testa autenticação SMTP AUTH |
| `telnet` | Telnet | 23 | Protocolo em texto claro legado |

---

## 💡 Exemplos Práticos de Execução

### 1. Auditoria de FTP com parada na primeira credencial encontrada
```bash
medusa -h 192.168.56.101 -U users.txt -P passwords.txt -M ftp -f -v 4
```

### 2. Password Spraying em SMB (Mesma senha contra todos os usuários)
```bash
medusa -h 192.168.56.101 -U smb_users.txt -p "Empresa@2026" -M smbnt -t 2
```

### 3. Teste em SSH com verificação de senha em branco e senha igual ao usuário
```bash
medusa -h 192.168.56.101 -u root -P passwords.txt -M ssh -e ns
```

### 4. Força Bruta em Autenticação Web HTTP Basic
```bash
medusa -h 192.168.56.101 -U users.txt -P passwords.txt -M http -m USER-AGENT:"Mozilla/5.0"
```
