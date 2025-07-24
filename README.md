# 🤖 Agente Autônomo de Monitoramento de Sistema

Um agente inteligente em PowerShell que coleta informações completas sobre o status da máquina de forma autônoma.

## 📋 Funcionalidades

O agente coleta automaticamente as seguintes informações:

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

### 🛡️ Segurança
- Status do Windows Defender
- Proteção em tempo real
- Última verificação de antivírus

### 💡 Recomendações Automáticas
- Alertas de alto uso de CPU/RAM
- Avisos de pouco espaço em disco
- Sugestões de otimização

## 🚀 Como Usar

### Execução Simples
```powershell
.\bot.ps1
```

### Opções Disponíveis

1. **Diagnóstico Único**: Executa uma análise completa uma vez
2. **Monitoramento Contínuo (30 min)**: Executa análises a cada 30 minutos
3. **Monitoramento Contínuo (60 min)**: Executa análises a cada 60 minutos
4. **Sair**: Encerra o agente

### Execução como Administrador

Para obter informações mais detalhadas, execute o PowerShell como Administrador:

1. Clique com botão direito no PowerShell
2. Selecione "Executar como administrador"
3. Execute o script: `.\2aMS.ps1`

## 📁 Arquivos Gerados

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