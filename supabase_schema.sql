-- ==============================================================================
-- SCHEMA SUPABASE: AHS Climatização | Ar Condicionado e Elétrica
-- CRM de Serviços e Orçamentos com Sincronização em Tempo Real (Realtime) e RLS
-- ==============================================================================

-- 1. Criação da Tabela Principal de Atendimentos
CREATE TABLE IF NOT EXISTS public.atendimentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    cliente_nome TEXT NOT NULL,
    telefone TEXT,
    categoria TEXT NOT NULL DEFAULT 'Ar-Condicionado' CHECK (categoria IN ('Ar-Condicionado', 'Elétrica', 'Ambos')),
    servico_a_prestar TEXT NOT NULL,
    servico_prestado TEXT DEFAULT '',
    valor_passado NUMERIC(10,2) DEFAULT 0.00,
    valor_a_cobrar NUMERIC(10,2) DEFAULT 0.00,
    sessao TEXT NOT NULL DEFAULT 'Novo Contato' CHECK (
        sessao IN (
            'Novo Contato',
            'Orçamento Enviado',
            'Aguardando Aprovação',
            'Serviço Agendado',
            'Serviço Prestado',
            'A Cobrar',
            'Concluído / Pago'
        )
    ),
    bairro_endereco TEXT DEFAULT '',
    observacoes TEXT DEFAULT '',
    historico_alteracoes JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Índices para Otimização de Consultas Rápidas no PWA e Desktop
CREATE INDEX IF NOT EXISTS idx_atendimentos_user_id ON public.atendimentos(user_id);
CREATE INDEX IF NOT EXISTS idx_atendimentos_sessao ON public.atendimentos(sessao);
CREATE INDEX IF NOT EXISTS idx_atendimentos_categoria ON public.atendimentos(categoria);
CREATE INDEX IF NOT EXISTS idx_atendimentos_created_at ON public.atendimentos(created_at DESC);

-- 3. Função e Trigger para Atualizar o Campo `updated_at` Automaticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_atendimentos_updated_at ON public.atendimentos;
CREATE TRIGGER trigger_atendimentos_updated_at
    BEFORE UPDATE ON public.atendimentos
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 4. Habilitar Segurança em Nível de Linha (RLS - Row Level Security)
ALTER TABLE public.atendimentos ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para Usuários Autenticados (Acesso Completo aos Seus Próprios Registros)
DROP POLICY IF EXISTS "Usuários autenticados podem visualizar seus atendimentos" ON public.atendimentos;
CREATE POLICY "Usuários autenticados podem visualizar seus atendimentos"
    ON public.atendimentos
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários autenticados podem criar atendimentos" ON public.atendimentos;
CREATE POLICY "Usuários autenticados podem criar atendimentos"
    ON public.atendimentos
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários autenticados podem atualizar seus atendimentos" ON public.atendimentos;
CREATE POLICY "Usuários autenticados podem atualizar seus atendimentos"
    ON public.atendimentos
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários autenticados podem excluir seus atendimentos" ON public.atendimentos;
CREATE POLICY "Usuários autenticados podem excluir seus atendimentos"
    ON public.atendimentos
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Política alternativa (opcional/modo equipe): Se quiser permitir que qualquer usuário autenticado da empresa veja os registros:
-- CREATE POLICY "Equipe autenticada pode gerenciar atendimentos"
--     ON public.atendimentos FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 5. Habilitar Supabase Realtime para Sincronização Instantânea Celular <-> Computador
-- Garante que a tabela 'atendimentos' emita eventos INSERT, UPDATE e DELETE via WebSocket
ALTER PUBLICATION supabase_realtime ADD TABLE public.atendimentos;

-- Comentários informativos
COMMENT ON TABLE public.atendimentos IS 'Tabela de clientes e ordens de serviços da AHS Climatização | Ar Condicionado e Elétrica';
COMMENT ON COLUMN public.atendimentos.historico_alteracoes IS 'Array JSON com histórico de alterações de valores, sessões e notas com timestamp';
