# Desafio Técnico - Analista de Infraestrutura Web (Linux)

Este repositório contém as entregas do desafio técnico para a posição de Analista de Infraestrutura Web. O objetivo destas resoluções é demonstrar não apenas a capacidade de provisionar serviços, mas o domínio sobre **idempotência, resiliência, automação e diagnóstico** em ambientes de hospedagem compartilhada e cloud.

Cada etapa foi documentada em sua respectiva pasta, detalhando a parte teórica, a arquitetura das soluções propostas e as instruções literais de validação.

## 🗂️ Estrutura do Repositório

* **`pergunta1/` - Diagnóstico de 502 (Nginx + PHP-FPM):** 
  Contém a fundamentação teórica de troubleshooting e o script `health_check.sh`. O script foi projetado para execução segura via `cron`, implementando controle de concorrência (`flock`) para evitar efeito cascata em caso de indisponibilidade prolongada.
* **`pergunta2/` - Virtual Host Nginx + LiteSpeed para WordPress:** 
  Arquivo de configuração com regras de proxy reverso encaminhando para o LSPHP. Inclui regras de segurança (bloqueio de scripts em uploads), otimização de estáticos e regras estritas de bypass de LSCache para sessões logadas e rotas administrativas.
* **`pergunta3/` - E-mail e Deliverability (Tríade DNS):** 
  Documentação didática para o cliente final e o script `check_deliverability.sh`. O código utiliza `dig` para auditar SPF, DKIM, DMARC e rDNS/PTR, com tratamento de erros de rede para entregar uma saída limpa e profissional.
* **`pergunta4/` - Containers (Docker & Cultura DevOps):** 
  Deploy de stack web (`docker-compose.yml` com Nginx, PHP-FPM e MariaDB) focada em testar a imutabilidade do ambiente e a persistência de volumes de banco de dados através da destruição e recriação dos containers.
* **`pergunta5/` - Provisionamento Automático (Puppet):** 
  O núcleo de Infraestrutura como Código (IaC). Um módulo Puppet parametrizado (`client`) que orquestra a criação segura e multi-tenant de clientes. O módulo foca estritamente em **idempotência**, utilizando validação de estado para garantir que reexecuções não causem *configuration drift* ou perda de dados.

## 🤖 Observação sobre uso de IA

Conforme permitido pelo enunciado do desafio, este teste foi produzido com auxílio de Inteligência Artificial (Claude e Gemini).
A IA foi utilizada de forma colaborativa como *pair programmer* para:
* Acelerar a estruturação inicial dos diretórios e scaffolding de código.
* Refinar a sintaxe declarativa do Puppet e validar a lógica de dependências do grafo de compilação.
* Polir a formatação de saída de scripts Bash para garantir padrões de infraestrutura e silenciar erros de `stderr`.
* Debater e aplicar conceitos arquiteturais de idempotência e segurança nas configurações de Virtual Host.

Todas as soluções geradas foram criticamente revisadas, testadas isoladamente e validadas em ambiente de laboratório antes da consolidação final.

## 💻 Ambiente de Teste e Homologação

Os scripts, manifests e configurações foram exaustivamente validados localmente utilizando a seguinte arquitetura:

* **Sistema Operacional:** Ubuntu 22.04 LTS (Jammy Jellyfish) rodando via WSL 2.
* **Utilitários de Rede:** `bind9-dnsutils` (para chamadas do comando `dig`).
* **Web Stack Local:** Pacotes nativos `nginx` e `php8.1-fpm` (para testes de sintaxe e scripts de health check).
* **Docker:** Docker Engine (`docker-ce`) e plugin V2 (`docker-compose-plugin`) instalados via repositório oficial da Docker para garantir suporte moderno à sintaxe do Compose.
* **Puppet:** Puppet Agent versão 8, instalado através do repositório oficial da PuppetLabs, executado via `puppet apply` (arquitetura masterless) com execuções prévias em modo simulação (`--noop`).