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

-- 3. Habilitar Segurança em Nível de Linha (RLS - Row Level Security)
ALTER TABLE public.atendimentos ENABLE ROW LEVEL SECURITY;

-- 4. Políticas de Acesso Seguro (RLS)
-- Permite que os usuários autenticados da empresa gerenciem os atendimentos
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

-- 5. Habilitar Supabase Realtime para Sincronização Instantânea Celular <-> Computador
ALTER PUBLICATION supabase_realtime ADD TABLE public.atendimentos;

-- 6. Trigger Opcional para updated_at (compatível com o parser web do Supabase)
DROP TRIGGER IF EXISTS trigger_atendimentos_updated_at ON public.atendimentos;
DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;

CREATE FUNCTION public.handle_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_atendimentos_updated_at
    BEFORE UPDATE ON public.atendimentos
    FOR EACH ROW
    EXECUTE PROCEDURE public.handle_updated_at();
