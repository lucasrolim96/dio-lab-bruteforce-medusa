# ⚖️ Comparativo Técnico de Ferramentas de Auditoria e Força Bruta

No ecossistema de testes de intrusão e auditoria de segurança (Kali Linux), existem diversas ferramentas para quebra de credenciais e simulação de força bruta. Cada uma possui uma arquitetura distinta, focando em diferentes camadas (rede vs offline, protocolos genéricos vs aplicações especializadas).

---

## 📊 Matriz Comparativa

| Ferramenta | Tipo de Ataque | Arquitetura | Protocolos / Alvos | Principais Vantagens | Principais Limitações |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Medusa** | Online (Rede) | Multithread baseada em módulos C dinâmicos (`.mod`) | +20 protocolos (FTP, SSH, SMB, HTTP, MySQL, Telnet, VNC, etc.) | Extremamente rápido, modular, suporta paralelização por host e por usuário, código limpo e estável. | Módulo HTTP para formulários complexos exige sintaxe manual mais detalhada que Hydra. |
| **THC-Hydra** | Online (Rede) | Multithread com suporte massivo a protocolos | +50 protocolos (HTTP GET/POST Forms, SSH, RDP, SMB, Cisco, etc.) | Grande versatilidade para aplicações web modernas (suporte nativo a CSRF, cookies, proxy SOCKS5). | Uso agressivo de recursos; pode gerar falso-positivos em redes instáveis se não calibrado com `-W` e `-t`. |
| **Ncrack** | Online (Rede) | Orientada a eventos (*event-driven*, criada pelo time do Nmap) | SSH, RDP, FTP, Telnet, HTTP, SMB, VNC, ORA, etc. | Motor de temporização dinâmico adaptativo; lida com conexões de rede lentas ou congestionadas sem travar. | Menor variedade de módulos que o Hydra; desenvolvimento mais espaçado. |
| **Patator** | Online (Rede) | Multithread modular escrita em Python | HTTP, SMB, SSH, DNS, SNMP, LDAP, MSSQL, VNC, etc. | Altamente customizável via regex e scripts; excelente para cenários onde ferramentas em C não oferecem flexibilidade. | Desempenho bruto de requisições por segundo ligeiramente inferior ao Medusa/Hydra por ser Python. |
| **John the Ripper** | Offline (Hash Cracking) | Algoritmos de CPU otimizados (OpenMP, SIMD, SSE, AVX) e GPU | Quebra de hashes locais (`/etc/shadow`, NTLM, Kerberos, ZIP, PDF) | Reconhecimento automático de cifras, modos incrementais, regras de mutação inteligentes (*mangling rules*). | Não realiza ataques diretos contra serviços de rede (atua pós-enumeração ou pós-exfiltração). |
| **WPScan** | Aplicação Web Especializada | Scanner e brute-force baseado em Ruby | Exclusivo para CMS WordPress (XML-RPC, wp-login.php) | Enumera plugins, temas, usuários e explora vulnerabilidades conhecidas da base WPScan com facilidade. | Restrito ao ecossistema WordPress. |

---

## 🔍 Análise Detalhada das Ferramentas do Curso

### 1. Medusa vs THC-Hydra
* **Medusa:** Projetado para resolver problemas de gerenciamento de threads e instabilidade encontrados em versões mais antigas de ferramentas de auditoria. Ele oferece paralelismo em nível de host, usuário e senha, mantendo um pool de threads gerenciado de forma controlada. Excelente para serviços com sockets de alta velocidade como FTP, Telnet e SMB.
* **Hydra:** É o canivete suíço dos testes de formulários web. Seu módulo `http-post-form` permite mapear parâmetros de URL, cookies de sessão, valores de retorno de erro e campos de CSRF com facilidade.

### 2. Ncrack e a herança do Nmap
* Desenvolvido para avaliações de larga escala. Se uma rede possui centenas de hosts vulneráveis a senhas fracas em SSH ou RDP, o Ncrack monitora o tempo de resposta da rede e ajusta automaticamente o envio de pacotes, evitando sobrecarregar o firewall ou derrubar o serviço.

### 3. John the Ripper (Ataque Offline)
* Diferente do Medusa, que depende da latência da rede e das respostas de socket TCP/UDP, o John the Ripper roda localmente processando bilhões de hashes por segundo. Ele é empregado quando o pentester consegue extrair o arquivo `/etc/shadow` de uma máquina Linux ou as bases SAM/NTDS de um controlador de domínio Windows.

### 4. Patator (Abordagem Modular Python)
* Muito utilizado quando as ferramentas convencionais falham em lidar com payloads específicos, como autenticação de duplo fator que aceita certos formatos, ou serviços customizados que precisam de pré-tratamento de dados antes de cada requisição.
