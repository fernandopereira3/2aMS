# 🤖 Agente Autônomo de Monitoramento de Sistema (2aMS)

Um agente inteligente em PowerShell que coleta informações completas sobre o status da máquina de forma autônoma, agora com **interface gráfica** e funcionalidades avançadas de gerenciamento de sistema.

## 🎯 Novidades da Versão Atual

### 🖥️ **Interface Gráfica (GUI)**
- **Nova interface visual** com botões organizados por categoria
- **Execução simplificada** - basta clicar nos botões
- **Feedback em tempo real** com barra de status
- **Logs automáticos** salvos por usuário e data
- **Área de resultados** com scroll para visualização completa

### 📦 **Gerenciamento de Programas**
- **WinGet Integration**: Verificação, atualização e listagem de pacotes
- **Instalação Automática**: Programas essenciais (Chrome, Office, Steam, etc.)
- **Importação de Pacotes**: Suporte ao arquivo `packages.json`
- **Backup de Arquivos**: Salvamento automático no servidor de rede

## 📋 Funcionalidades Completas

### 🖥️ Sistema Operacional
- Nome e versão do Windows
- Build e informações detalhadas
- Memória física total
- Informações do processador

### 🔧 Hardware
- **CPU**: Nome, núcleos, threads, velocidade
- **Memória**: Capacidade total, velocidade, fabricante
- **Discos**: Espaço total, livre, sistema de arquivos

### 🌐 Rede
- Adaptadores de rede ativos
- Configurações de IP
- Status das conexões

### ⚡ Performance
- Uso da CPU em tempo real
- Uso da memória RAM
- Top 10 processos por consumo de CPU

### 🛠️ Serviços
- Status de serviços críticos do Windows
- Verificação de integridade

### 📊 Eventos do Sistema
- Eventos críticos das últimas 24 horas
- Análise de logs do sistema

### 🔄 Atualizações
- Verificação de atualizações pendentes
- Status do Windows Update
- **WinGet**: Atualização automática de todos os pacotes

### 🛡️ Segurança
- Status do Windows Defender
- Proteção em tempo real
- Última verificação de antivírus

### 📦 **Gerenciamento de Programas (NOVO)**
- **Verificação do WinGet**: Status de instalação e funcionalidade
- **Atualização Automática**: `winget upgrade --all` com feedback
- **Lista de Pacotes**: Visualização de programas instalados via WinGet
- **Instalação Base**: Programas essenciais (Chrome, Office, Steam, Discord, etc.)
- **Importação**: Instalação em lote via `packages.json`

### 💾 **Backup e Arquivos (NOVO)**
- **Save-Files**: Backup automático para servidor de rede
- **Verificação de Conectividade**: Testa acesso ao servidor antes do backup
- **Tratamento de Erros**: Mensagens claras para problemas de rede
- **Organização**: Pastas nomeadas com computador e data

### 💡 Recomendações Automáticas
- Alertas de alto uso de CPU/RAM
- Avisos de pouco espaço em disco
- Sugestões de otimização

## 🚀 Como Usar

### 🎨 **Interface Gráfica (Recomendado)**
```powershell
.\2aMS-GUI.ps1
```

**Funcionalidades da GUI:**
- **17 botões organizados** por categoria de diagnóstico
- **Cores diferenciadas** para fácil identificação
- **Barra de status** com feedback em tempo real
- **Área de resultados** com scroll automático
- **Logs automáticos** salvos por usuário e data

### 📝 **Linha de Comando (Clássico)**
```powershell
.\2aMS.ps1
```

### Opções Disponíveis

1. **Diagnóstico Único**: Executa uma análise completa uma vez
2. **Monitoramento Contínuo (30 min)**: Executa análises a cada 30 minutos
3. **Monitoramento Contínuo (60 min)**: Executa análises a cada 60 minutos
4. **Sair**: Encerra o agente

### 🔧 **Funcionalidades Avançadas**

#### Instalação de Programas Base
```powershell
Install-BasePrograms
```
**Instala automaticamente:**
- Google Chrome
- Microsoft Visual C++ Redistributables (2012, 2013, 2015+)
- Spotify
- Discord
- Steam
- Microsoft Office

#### Importação de Pacotes
```powershell
Import-BasePrograms
```
Utiliza o arquivo `packages.json` para instalação em lote.

#### Backup de Arquivos
```powershell
Save-Files
```
Faz backup para o servidor `ADICIONE O SERVIDOR QUE IRÁ FAZER O BACKUP` com verificação de conectividade.

### Execução como Administrador

Para obter informações mais detalhadas, execute o PowerShell como Administrador:

1. Clique com botão direito no PowerShell
2. Selecione "Executar como administrador"
3. Execute o script: `.\2aMS.ps1` ou `.\2aMS-GUI.ps1`

## 📁 Estrutura de Arquivos

O agente gera automaticamente:

- **Logs detalhados**: `system_status_YYYYMMDD_HHMMSS.log`
- **Relatórios com timestamp** para rastreamento histórico

## 🎯 Status do Sistema

O agente classifica o sistema em três categorias:

- 🟢 **SAUDÁVEL**: Sistema funcionando normalmente
- 🟡 **ATENÇÃO**: Alguns recursos com uso elevado
- 🔴 **CRÍTICO**: Problemas detectados que requerem atenção

## ⚙️ Requisitos

- Windows 10/11
- PowerShell 5.1 ou superior
- Permissões de usuário (Administrador recomendado)

## 🔧 Personalização

Você pode modificar:

- **Intervalos de monitoramento**: Altere os valores em `Start-ContinuousMonitoring`
- **Serviços monitorados**: Modifique o array `$criticalServices`
- **Thresholds de alerta**: Ajuste os valores de CPU/RAM nos alertas

## 📈 Exemplo de Saída

```
🤖 AGENTE AUTÔNOMO DE MONITORAMENTO DE SISTEMA
==================================================
1. Executar diagnóstico completo (uma vez)
2. Iniciar monitoramento contínuo (30 min)
3. Iniciar monitoramento contínuo (60 min)
4. Sair
==================================================

============================================================
  INFORMAÇÕES DO SISTEMA OPERACIONAL
============================================================

WindowsProductName    : Windows 11 Pro
WindowsVersion        : 25H2
TotalPhysicalMemory   : 17179869184

🔥 Uso médio da CPU: 15.2%
🧠 Uso da Memória: 45.8%

🎯 Status Geral do Sistema: SAUDÁVEL
```

## 🛟 Solução de Problemas

### Erro de Permissões
- Execute como Administrador
- Verifique a política de execução: `Set-ExecutionPolicy RemoteSigned`

### Comandos não Reconhecidos
- Alguns comandos podem não estar disponíveis em versões antigas do Windows
- O agente trata erros automaticamente e continua a execução

### Performance Lenta
- O primeiro diagnóstico pode demorar mais
- Execuções subsequentes são mais rápidas

## 📝 Logs

Todos os diagnósticos são salvos em arquivos de log com timestamp:
- Formato: `system_status_YYYYMMDD_HHMMSS.log`
- Localização: Mesmo diretório do script
- Conteúdo: Resumo das informações coletadas

## 🔄 Próximas Funcionalidades

### 🚧 Em Desenvolvimento

- Interface gráfica (GUI)
- Dashboard web
- Alertas por email
- ✅ **Limpador de Sistema** (disponível em `limpador.ps1`)
- Relatórios em HTML
- Integrações com sistemas de monitoramento

### 💡 Sugestões Bem-Vindas!

Tem ideias para melhorar o 2aMS? Suas sugestões são muito importantes!

- 🐛 Reporte bugs
- 💡 Sugira novas funcionalidades
- 🤝 Contribua com código
- ⭐ Avalie o projeto

---

**Desenvolvido para monitoramento autônomo e inteligente de sistemas Windows** 🚀

*"A melhor ferramenta é aquela que evolui com as necessidades da comunidade"* ✨