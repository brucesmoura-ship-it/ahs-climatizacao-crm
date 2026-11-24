# AHS Climatização | Ar Condicionado e Elétrica — CRM por Comando de Voz & Realtime

Aplicação Web Progressiva (PWA) completa, responsiva e instalável, projetada especificamente para a operação em campo e escritório da **AHS Climatização & Soluções Elétricas**.

![Identidade Visual AHS](logo.jpg)

---

## 🚀 Principais Funcionalidades

1. **Reconhecimento & Ditado por Comando de Voz (PT-BR):**
   - **Assistente Inteligente (NLP):** Diga frases naturais como:  
     *"Novo cliente Marcos Paulo, ar condicionado, limpeza de split e carga de gás, orçamento 350 reais, a cobrar 350"*  
     O CRM detecta e preenche automaticamente o nome, segmento, descrição da demanda e valores.
   - **Ditado de Laudo Técnico:** Botão de microfone dedicado ao lado dos campos de demanda e serviço prestado para o técnico falar com as mãos livres no local de atendimento.
   - **Comandos de Navegação:** *"Buscar Camila"*, *"Filtrar Ar Condicionado"*, *"Ver Elétrica"*, *"Ver Finanças"*.
   - **Feedback por Síntese de Voz (TTS):** Respostas em áudio confirmando ações.

2. **Fluxo em 7 Etapas / Sessões do Atendimento:**
   - `1. Novo Contato`
   - `2. Orçamento Enviado`
   - `3. Aguardando Aprovação`
   - `4. Serviço Agendado`
   - `5. Serviço Prestado`
   - `6. A Cobrar`
   - `7. Concluído / Pago`

3. **Arquitetura em Nuvem com Supabase (PostgreSQL + Auth + Realtime):**
   - Sincronização bidirecional em tempo real (WebSockets): qualquer atualização no celular reflete instantaneamente no computador do escritório sem recarregar a página.
   - Segurança em Nível de Linha (**Row Level Security - RLS**) para proteger os orçamentos e dados dos clientes.
   - Trigger automático de `updated_at`.
   - Histórico de auditoria em `jsonb` registrando cada transição de etapa e alteração de valores.
   - Modo Demonstração / Offline integrado para testes imediatos sem necessidade de configuração prévia.

4. **Ferramentas Práticas para o Técnico em Campo:**
   - **Disparo no WhatsApp:** 1 clique para enviar mensagem profissional com o resumo do orçamento, valores e status para o cliente.
   - **Ordem de Serviço & Orçamento Imprimível (PDF):** Visualização e impressão formatada com logo oficial da AHS, discriminação dos serviços, termo de garantia de 90 dias e campos de assinatura.
   - **Dashboard Financeiro:** Contadores em tempo real de Volume Total Orçado, Saldo a Cobrar (Pendente) e Faturamento Concluído.

5. **PWA Instalável no Celular e Desktop:**
   - Suporte a instalação como aplicativo nativo via Chrome, Edge, Safari e Android.
   - Manifesto com ícones em alta resolução gerados a partir do logotipo oficial da AHS.
   - Service Worker para cache rápido e funcionamento offline.

---

## 🗄️ Como Configurar o Banco no Supabase

1. Crie um projeto gratuito em [supabase.com](https://supabase.com).
2. Acesse o **SQL Editor** do seu painel Supabase.
3. Abra o arquivo `supabase_schema.sql` deste projeto, copie todo o conteúdo e clique em **Run**.
4. No menu lateral do Supabase, vá em **Project Settings -> API** e copie:
   - **Project URL**
   - **Project API Keys (`anon` `public`)**
5. No CRM da AHS, clique no botão **Supabase** no canto superior direito e cole as duas chaves. Pronto! A sincronização em tempo real estará ativa.

---

## 💻 Como Rodar Localmente

Você pode abrir o arquivo `index.html` diretamente em qualquer navegador moderno ou rodar um servidor web local com Python:

```bash
# Na pasta do projeto:
python -m http.server 3000
```

Acesse no navegador: `http://localhost:3000`

---

## 📱 Como Instalar no Celular (PWA)

1. Abra o link da aplicação no Chrome (Android) ou Safari (iPhone).
2. No Chrome: clique no banner **"Instalar App AHS Climatização"** ou no menu `⋮ -> Instalar aplicativo`.
3. No iPhone (Safari): toque no botão de compartilhar e selecione **"Adicionar à Tela de Início"**.
