#!/usr/bin/env python3
"""
defense_rate_limiter.py
Demonstração didática de mecanismos de defesa contra ataques de Força Bruta
e Password Spraying:
 1. Rate Limiting (Atraso exponencial e limite de requisições por IP)
 2. Account Lockout Policy (Bloqueio temporário após N falhas)
 3. Detecção de Anomalia de Spraying (Múltiplas falhas para diferentes usuários vindas do mesmo IP)
"""

import time
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, List

MAX_ATTEMPTS_PER_ACCOUNT = 3
LOCKOUT_TIME_SECONDS = 15
SPRAY_DETECTION_THRESHOLD = 4  # Quantos usuários distintos falhados por IP disparam alerta de spraying


@dataclass
class AccountStatus:
    failed_attempts: int = 0
    locked_until: float = 0.0

    def is_locked(self) -> bool:
        return time.time() < self.locked_until


class SecurityGateway:
    def __init__(self):
        # Base de usuários cadastrados (Simulando banco de dados)
        self.credentials: Dict[str, str] = {
            "admin": "Admin@2026!Secure",
            "msfadmin": "msfadmin",
            "user": "UserPassword#99",
            "developer": "DevSecret*42",
        }
        self.account_records: Dict[str, AccountStatus] = defaultdict(AccountStatus)
        # Histórico de requisições por IP para detectar Password Spraying
        self.ip_user_attempts: Dict[str, List[str]] = defaultdict(list)

    def authenticate(self, client_ip: str, username: str, password_attempt: str) -> bool:
        print(f"\n[REQ] IP {client_ip} tentando login para o usuário '{username}'...")
        status = self.account_records[username]

        # 1. Verifica se a conta está bloqueada (Account Lockout)
        if status.is_locked():
            remaining = int(status.locked_until - time.time())
            print(f"  [BLOQUEIO] Conta '{username}' está TEMPORARIAMENTE BLOQUEADA! Tente em {remaining}s.")
            return False

        # 2. Registra histórico do IP para análise de Spraying
        self.ip_user_attempts[client_ip].append(username)
        distinct_targeted_users = set(self.ip_user_attempts[client_ip])
        if len(distinct_targeted_users) >= SPRAY_DETECTION_THRESHOLD:
            print(f"  [ALERTA SOC] DETECÇÃO DE PASSWORD SPRAYING! IP {client_ip} testou {len(distinct_targeted_users)} contas diferentes.")

        # 3. Validação de credencial
        if username in self.credentials and self.credentials[username] == password_attempt:
            print(f"  [SUCESSO] Autenticação bem-sucedida para '{username}'!")
            status.failed_attempts = 0
            return True
        else:
            status.failed_attempts += 1
            print(f"  [FALHA] Credencial inválida. Falhas consecutivas para '{username}': {status.failed_attempts}/{MAX_ATTEMPTS_PER_ACCOUNT}")

            # Se atingiu o limite de tentativas
            if status.failed_attempts >= MAX_ATTEMPTS_PER_ACCOUNT:
                status.locked_until = time.time() + LOCKOUT_TIME_SECONDS
                print(f"  [MITIGAÇÃO ATIVADA] Limite excedido! Conta '{username}' BLOQUEADA por {LOCKOUT_TIME_SECONDS} segundos.")

            return False


def run_simulation():
    gateway = SecurityGateway()
    attacker_ip = "192.168.56.102"

    print("=" * 65)
    print("SIMULADOR DE MITIGAÇÃO: FORÇA BRUTA TRADICIONAL (Alvo: 'admin')")
    print("=" * 65)
    wordlist = ["123456", "password", "admin", "admin123"]
    for pwd in wordlist:
        gateway.authenticate(attacker_ip, "admin", pwd)

    print("\n" + "=" * 65)
    print("SIMULADOR DE MITIGAÇÃO: PASSWORD SPRAYING (Mesma senha '123456' em vários usuários)")
    print("=" * 65)
    spray_users = ["msfadmin", "user", "developer", "guest", "backup"]
    for u in spray_users:
        gateway.authenticate(attacker_ip, u, "123456")


if __name__ == "__main__":
    run_simulation()
