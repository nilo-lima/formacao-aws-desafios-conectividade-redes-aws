# ADR-002: Key pair RSA separado para Windows

## Status
Aceita (correcao em apply)

## Contexto
A chave inicial gerada para o lab usou Ed25519 (mais moderno e seguro). Durante o terraform apply, o RunInstances da EC2 Windows retornou erro: "ED25519 key pairs are not supported with Windows AMIs".

## Decisao
Criar um segundo `aws_key_pair` (RSA 4096) exclusivo para a instancia Windows. Manter Ed25519 para instancias Linux. Adicionar variavel `windows_public_key_path` separada.

## Consequencias
- Positivas: cada OS usa o tipo de chave mais adequado; a chave RSA tambem e necessaria para descriptografar a senha inicial do Administrator no console AWS.
- Negativas: dois key pairs para gerenciar; a chave RSA privada precisa estar em formato PEM classico (nao OpenSSH) para o console AWS aceitar na funcao "Get Windows Password".
- Riscos: usuario pode esquecer de converter a chave RSA para PEM antes de tentar descriptografar a senha (comando: `ssh-keygen -p -m PEM -f ~/.ssh/bia-lab-03-win -N "" -P ""`).
