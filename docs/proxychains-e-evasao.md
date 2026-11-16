# Proxychains: Rotação de IP, Evasão e Resposta Defensiva

O **Proxychains** é uma ferramenta utilitária amplamente utilizada no Kali Linux para encapsular conexões TCP de aplicações de linha de comando através de servidores proxy (SOCKS4, SOCKS5 e HTTP) ou pela rede Tor.

Em auditorias de segurança e simulações de autenticação, o uso de proxies encadeados é comumente estudado como forma de contornar bloqueios simples baseados exclusivamente no endereço IP de origem (*IP-based Rate Limiting*).

---

## 1. Como Funciona o Proxychains

O Proxychains atua injetando-se dinamicamente nas chamadas de rede da aplicação (via biblioteca `libproxychains.so` e mecanismo `LD_PRELOAD`). Quando o Medusa, Hydra ou Nmap tenta abrir um socket TCP (`connect()`), a chamada é interceptada e redirecionada através dos proxies definidos no arquivo de configuração `/etc/proxychains4.conf`.

### Modos de Operação no `/etc/proxychains4.conf`:
- **`strict_chain` (Cadeia Estrita):** Os pacotes passam rigorosamente por todos os proxies listados, na ordem exata. Se um dos proxies falhar, toda a conexão é interrompida.
- **`dynamic_chain` (Cadeia Dinâmica):** Semelhante à estrita, porém ignora automaticamente proxies que estejam inativos ou fora do ar, garantindo que o tráfego continue fluindo.
- **`random_chain` (Cadeia Aleatória):** Escolhe aleatoriamente proxies da lista a cada conexão estabelecida. É a opção utilizada quando o objetivo é alternar o IP de saída entre requisições.

---

## 2. Exemplo de Configuração e Uso no Kali Linux

### Configuração básica com serviço Tor:
1. Iniciar o daemon do Tor:
   ```bash
   sudo service tor start
   ```
2. No arquivo `/etc/proxychains4.conf`, garantir que o modo dinâmico ou aleatório esteja ativo e a porta SOCKS local configurada:
   ```ini
   dynamic_chain
   proxy_dns
   tcp_read_time_out 15000
   tcp_connect_time_out 8000

   [ProxyList]
   # Protocolo  IP         Porta
   socks5       127.0.0.1  9050
   ```

3. Executando o Medusa através do Proxychains:
   ```bash
   proxychains4 medusa -h 192.168.56.101 -u msfadmin -P wordlists/passwords_common.txt -M ftp -t 1
   ```

---

## 3. Limitações Técnicas do Proxychains em Ataques de Força Bruta

Embora a alternância de endereços IP dificulte a aplicação de banimentos por IP puro, seu emprego em testes de força bruta enfrenta restrições operacionais severas:

1. **Impacto Drástico de Latência:**
   - O Medusa atinge sua velocidade máxima abrindo dezenas de conexões diretas por segundo com o socket local.
   - Ao passar por múltiplos nós de proxy ou pela rede de circuitos do Tor, cada tentativa de login pode levar de 2 a 8 segundos para obter resposta, tornando o teste de dicionários médios (como `rockyou.txt`) inviável pelo tempo necessário.
2. **Concorrência e Perda de Sockets:**
   - Proxies gratuitos e nós Tor frequentemente limitam o número de conexões paralelas ou sofrem com *timeouts* frequentes, gerando falsos negativos no relatório de auditoria.
   - Para uso com Proxychains, a quantidade de threads do Medusa precisa ser reduzida drasticamente (geralmente `-t 1` ou `-t 2`).

---

## 4. Por que a Rotação de IP Não Contorna Controles Modernos (Visão Blue Team)

Na perspectiva de defesa (*Blue Team*), arquiteturas de segurança maduras não dependem exclusivamente da filtragem de IPs de origem:

1. **Bloqueio por Conta (*Account Lockout Policy*):**
   - Políticas de bloqueio a nível de usuário (como o módulo Linux `pam_faillock` ou diretivas do Active Directory) contam falhas associadas ao **nome de usuário** (`TargetUserName`). Se a conta `admin` receber 5 erros consecutivos, ela será travada independentemente de os pacotes terem vindo de 5 IPs diferentes.
2. **Listas de Reputação e Feeds de Ameaças (*Threat Intelligence*):**
   - Firewalls de Próxima Geração (NGFW) e WAFs (Cloudflare, AWS WAF, Akamai) utilizam listas públicas e comerciais de nós de saída do Tor e proxies abertos. Conexões originadas desses nós são bloqueadas por padrão ou desafiadas antes mesmo de atingirem a aplicação.
3. **Desafios Interativos (CAPTCHA e WAF):**
   - Aplicações web modernas disparam desafios interativos (Google reCAPTCHA, Cloudflare Turnstile) quando detectam padrões automatizados ou reputação de IP duvidosa, impedindo requisições automatizadas sem intervenção humana.
4. **Autenticação Multifator (MFA):**
   - Mesmo que a rotação de IPs permita descobrir uma senha corporativa fraca, o acesso continua inviabilizado pela exigência do token temporal (TOTP) ou chave física de segurança.
