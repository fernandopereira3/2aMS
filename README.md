# 🤖 Agente Autônomo de Monitoramento de Sistema (2aMS)

Um agente inteligente em PowerShell que coleta informações completas sobre o status da máquina de forma autônoma, com **interface gráfica** e funcionalidades avançadas de gerenciamento de sistema e diagnóstico de rede.

## 🎯 Novidades da Versão Atual

### 🌐 **Ferramentas de Diagnóstico de Rede**
- **Teste de Ping Avançado**: Verificação de conectividade com resolução de nomes de host
- **Mapeamento de Subredes**: Identificação de dispositivos ativos em múltiplas subredes
- **Logs Automáticos**: Registro detalhado de resultados com data e hora
- **Versão Linux**: Script shell equivalente para ambientes Unix/Linux

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
- **Teste de Ping**: Verificação de conectividade com resolução de nomes
- **Mapeamento de Subredes**: Identificação de dispositivos em múltiplas subredes

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

### 📦 **Gerenciamento de Programas**
- **Verificação do WinGet**: Status de instalação e funcionalidade
- **Atualização Automática**: `winget upgrade --all` com feedback
- **Lista de Pacotes**: Visualização de programas instalados via WinGet
- **Instalação Base**: Programas essenciais (Chrome, Office, Steam, Discord, etc.)
- **Importação**: Instalação em lote via `packages.json`
- **Exportação**: Geração de arquivo de pacotes com nome personalizado

### 💾 **Backup e Arquivos**
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

### 📝 **Linha de Comando (Clássico)**
```powershell
.\2aMS.ps1
```

### 🌐 **Ferramentas de Diagnóstico de Rede**
```powershell
.\test_con.ps1  # Para Windows
./test_con.sh   # Para Linux
```

### Opções Disponíveis no Diagnóstico de Rede

1. **Teste com local conhecido**: Verifica conectividade em um segmento específico (ex: 192.168.1.x)
2. **Teste de locais**: Verifica conectividade em múltiplas subredes (ex: 192.168.x.1)

## 🔧 Compatibilidade

- **Windows**: Todas as funcionalidades disponíveis
- **Linux/macOS**: Suporte parcial via script shell para diagnóstico de rede

## 📄 Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.