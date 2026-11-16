# Comparativo de Ferramentas de Força Bruta e Auditoria de Senhas

No ecossistema do Kali Linux existem diversas ferramentas para auditoria de credenciais. Cada uma foi desenvolvida com arquiteturas e propósitos específicos (ataques em rede versus ataques locais em hashes, serviços genéricos versus aplicações web complexas).

---

## Matriz Comparativa

| Ferramenta | Camada | Arquitetura | Protocolos Suportados | Vantagens | Limitações |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Medusa** | Online (Rede) | Multithread em C modular | Mais de 20 protocolos (FTP, SSH, SMB, HTTP, MySQL, Telnet, VNC) | Rápida, baixo consumo de memória, código muito estável para sockets de rede. | Formulários web complexos exigem sintaxe manual avançada. |
| **THC-Hydra** | Online (Rede) | Multithread de alto volume | Mais de 50 protocolos (HTTP GET/POST Forms, SSH, RDP, SMB) | Referência para autenticação web; suporta cookies, tokens de sessão e proxies. | Pode gerar falsos positivos se a rede estiver instável e as threads muito altas. |
| **Ncrack** | Online (Rede) | Orientada a eventos (projeto Nmap) | SSH, RDP, FTP, Telnet, HTTP, SMB, VNC | Motor dinâmico que calibra o envio de pacotes conforme o estado e latência da rede. | Menor número de módulos prontos em comparação com o Hydra. |
| **Patator** | Online (Rede) | Modular em Python | HTTP, SMB, SSH, DNS, SNMP, LDAP, MSSQL | Extremamente flexível para respostas customizadas e expressões regulares (regex). | Desempenho de requisições por segundo um pouco menor por ser interpretada em Python. |
| **John the Ripper** | Offline (Host) | Otimizada para CPU/GPU | Quebra de hashes locais (`/etc/shadow`, NTLM, hashes Kerberos) | Modos incrementais e regras de mutação avançadas (*wordlist mangling*). | Não realiza conexões diretas contra portas de rede online. |
| **WPScan** | Web Especializada | Scanner em Ruby | Exclusivo para WordPress (XML-RPC e wp-login.php) | Enumera temas, plugins, versões e usuários conhecidos antes de testar logins. | Funciona exclusivamente contra o CMS WordPress. |

---

## Análise Técnica dos Cenários

### Medusa vs THC-Hydra
- O **Medusa** se destaca pela estabilidade no tratamento de conexões paralelas com portas TCP puras (como FTP na porta 21 e SMB na porta 445). Ele raramente derruba os sockets locais durante o teste.
- O **Hydra** é indispensável quando o alvo é uma aplicação web moderna (como o DVWA). Como páginas de login web retornam status 200 tanto para sucesso quanto para falha, o Hydra permite passar a expressão exata de falha (`F=...`) e os cabeçalhos de Cookie com facilidade.

### Ataques Online vs Ataques Offline (John the Ripper)
- Ferramentas como Medusa, Hydra e Ncrack dependem diretamente da velocidade de resposta do servidor e da latência da rede (geralmente dezenas a centenas de tentativas por segundo).
- O **John the Ripper**, por outro lado, atua offline: uma vez que o auditor consegue o dump dos hashes de senha do sistema, o ataque roda diretamente na CPU/GPU local, testando centenas de milhares a milhões de combinações por segundo.
