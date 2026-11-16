@echo off
chcp 65001 > nul
echo ==============================================================================
echo Publicando o Projeto no GitHub (lucasrolim96/dio-lab-bruteforce-medusa)
echo ==============================================================================
echo.
echo Certifique-se de que você já criou o repositório no GitHub:
echo Nome: dio-lab-bruteforce-medusa (Publico e Vazio)
echo Link: https://github.com/new
echo.
pause
echo Enviando commits para o GitHub...
git push -u origin main
echo.
if %errorlevel% equ 0 (
    echo [SUCESSO] Projeto enviado com sucesso para o seu GitHub!
    echo Acesse: https://github.com/lucasrolim96/dio-lab-bruteforce-medusa
) else (
    echo [ERRO] Ocorreu um problema ao enviar. Verifique se o repositorio foi criado no GitHub.
)
pause
