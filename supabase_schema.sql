-- ============================================================================
-- SUPABASE SCHEMA PARA BUS_SCHEDULES
-- ============================================================================
-- Este arquivo SQL cria a estrutura completa de banco de dados no Supabase
-- para suportar sincronização com a aplicação Flutter.
--
-- Copie e cole este código no Supabase SQL Editor para criar:
-- 1. Tabela bus_schedules
-- 2. Índices para performance
-- 3. Políticas de Row Level Security (RLS)
-- 4. Triggers para timestamps automáticos
-- ============================================================================

-- ============================================================================
-- 1. CRIAR TABELA BUS_SCHEDULES
-- ============================================================================

CREATE TABLE IF NOT EXISTS bus_schedules (
  -- Chave primária
  id TEXT PRIMARY KEY,
  
  -- Dados da rota
  route_name TEXT NOT NULL,
  destination TEXT NOT NULL,
  origin TEXT,
  departure_time TEXT NOT NULL,
  
  -- Status e acessibilidade
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
  accessibility BOOLEAN DEFAULT FALSE,
  
  -- Tarifa
  fare DECIMAL(10, 2),
  
  -- Paradas intermediárias (JSON array)
  stops TEXT,  -- Serializado como JSON: ["Parada 1", "Parada 2"]
  
  -- Informações adicionais
  duration_minutes INTEGER,
  distance_km DECIMAL(10, 2),
  bus_type TEXT,  -- "Standard", "Express", "Acessible"
  operator_name TEXT,
  
  -- Timestamps (automáticos)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Soft delete (opcional)
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Comentário para documentação
COMMENT ON TABLE bus_schedules IS 'Armazena agendamentos de ônibus sincronizados do aplicativo Flutter';
COMMENT ON COLUMN bus_schedules.id IS 'Identificador único (UUID ou string)';
COMMENT ON COLUMN bus_schedules.updated_at IS 'Modificado automaticamente em UPDATE (essencial para sync incremental)';
COMMENT ON COLUMN bus_schedules.stops IS 'JSON array com nomes de paradas intermediárias';

-- ============================================================================
-- 2. CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================================================

-- Índice para sincronização incremental (CRÍTICO)
CREATE INDEX IF NOT EXISTS idx_bus_schedules_updated_at 
ON bus_schedules(updated_at DESC);

-- Índice para buscas comuns
CREATE INDEX IF NOT EXISTS idx_bus_schedules_route_name 
ON bus_schedules(route_name);

CREATE INDEX IF NOT EXISTS idx_bus_schedules_destination 
ON bus_schedules(destination);

CREATE INDEX IF NOT EXISTS idx_bus_schedules_status 
ON bus_schedules(status);

-- Índice para soft delete (se usar)
CREATE INDEX IF NOT EXISTS idx_bus_schedules_deleted_at 
ON bus_schedules(deleted_at) WHERE deleted_at IS NULL;

-- ============================================================================
-- 3. CRIAR FUNÇÃO PARA ATUALIZAR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_bus_schedules_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. CRIAR TRIGGER PARA ATUALIZAR TIMESTAMP
-- ============================================================================

DROP TRIGGER IF EXISTS update_bus_schedules_timestamp_trigger 
ON bus_schedules;

CREATE TRIGGER update_bus_schedules_timestamp_trigger
BEFORE UPDATE ON bus_schedules
FOR EACH ROW
EXECUTE FUNCTION update_bus_schedules_timestamp();

-- ============================================================================
-- 5. HABILITAR ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE bus_schedules ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. POLÍTICAS RLS - OPÇÃO A: PÚBLICAS (Desenvolvimento)
-- ============================================================================
-- Use esta opção se QUALQUER PESSOA pode ler os dados
-- (ex: aplicativo mobile sem autenticação)

DROP POLICY IF EXISTS "Allow public read" ON bus_schedules;
DROP POLICY IF EXISTS "Allow public insert" ON bus_schedules;
DROP POLICY IF EXISTS "Allow public update" ON bus_schedules;
DROP POLICY IF EXISTS "Allow public delete" ON bus_schedules;

CREATE POLICY "Allow public read"
ON bus_schedules FOR SELECT
USING (true);

CREATE POLICY "Allow public insert"
ON bus_schedules FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow public update"
ON bus_schedules FOR UPDATE
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow public delete"
ON bus_schedules FOR DELETE
USING (true);

-- ============================================================================
-- 7. POLÍTICAS RLS - OPÇÃO B: APENAS AUTENTICADOS (Produção)
-- ============================================================================
-- Descomente esta seção se APENAS usuários autenticados podem acessar
-- (substitua a seção anterior)

/*
DROP POLICY IF EXISTS "Allow read for authenticated users" ON bus_schedules;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON bus_schedules;
DROP POLICY IF EXISTS "Allow update for authenticated users" ON bus_schedules;
DROP POLICY IF EXISTS "Allow delete for authenticated users" ON bus_schedules;

CREATE POLICY "Allow read for authenticated users"
ON bus_schedules FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Allow insert for authenticated users"
ON bus_schedules FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow update for authenticated users"
ON bus_schedules FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow delete for authenticated users"
ON bus_schedules FOR DELETE
USING (auth.role() = 'authenticated');
*/

-- ============================================================================
-- 8. INSERIR DADOS DE TESTE (OPCIONAL)
-- ============================================================================

-- Descomente para adicionar dados de teste

/*
INSERT INTO bus_schedules (id, route_name, destination, origin, departure_time, status, accessibility, fare)
VALUES
  ('1', 'Rota 101', 'Centro', 'Bairro A', '08:00', 'active', false, 5.50),
  ('2', 'Rota 102', 'Shopping', 'Bairro B', '10:30', 'active', true, 6.00),
  ('3', 'Rota 103', 'Terminal', 'Bairro C', '14:00', 'active', false, 4.50),
  ('4', 'Rota 104', 'Estação', 'Bairro D', '16:30', 'inactive', false, 5.50),
  ('5', 'Rota 105', 'Hospital', 'Bairro E', '19:00', 'active', true, 7.00);

-- Selecionar para verificar
SELECT * FROM bus_schedules ORDER BY created_at DESC;
*/

-- ============================================================================
-- 9. QUERIES ÚTEIS PARA TESTES
-- ============================================================================

-- Ver todas as rotas
-- SELECT * FROM bus_schedules WHERE deleted_at IS NULL ORDER BY updated_at DESC;

-- Ver rotas modificadas desde uma hora atrás
-- SELECT * FROM bus_schedules 
-- WHERE updated_at > NOW() - INTERVAL '1 hour' 
--   AND deleted_at IS NULL
-- ORDER BY updated_at DESC;

-- Ver rotas ativas
-- SELECT * FROM bus_schedules WHERE status = 'active' AND deleted_at IS NULL;

-- Ver rotas com acessibilidade
-- SELECT * FROM bus_schedules WHERE accessibility = true AND deleted_at IS NULL;

-- Ver contagem por status
-- SELECT status, COUNT(*) as count FROM bus_schedules WHERE deleted_at IS NULL GROUP BY status;

-- ============================================================================
-- 10. VERIFICAR STATUS DO RLS
-- ============================================================================

-- Para verificar se as políticas estão corretas:
-- SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'bus_schedules';
-- SELECT policyname, permissive, roles, qual FROM pg_policies WHERE tablename = 'bus_schedules';

-- ============================================================================
-- CHECKLIST DE SETUP
-- ============================================================================

/*
✅ Checklist de Setup no Supabase:

1. PREPARAÇÃO
   [ ] Abrir Supabase SQL Editor
   [ ] Copiar todo este arquivo (ou seção por seção)
   [ ] Colar no SQL Editor

2. CRIAR TABELA
   [ ] Executar: Seção 1 (CREATE TABLE)
   [ ] Verificar: Tabela aparece em "Tables" no sidebar

3. CRIAR ÍNDICES
   [ ] Executar: Seção 2 (CREATE INDEX)
   [ ] Motivo: Performance para sincronização incremental

4. CRIAR FUNÇÃO E TRIGGER
   [ ] Executar: Seções 3-4
   [ ] Resultado: updated_at se atualiza automaticamente em UPDATE

5. HABILITAR RLS
   [ ] Executar: Seção 5 (ALTER TABLE ENABLE ROW LEVEL SECURITY)

6. DEFINIR POLÍTICAS
   [ ] Escolher: Opção A (público) OU Opção B (autenticado)
   [ ] Executar: Uma das duas seções
   [ ] Testar: SELECT sem autenticação deve retornar dados

7. TESTAR DADOS
   [ ] Executar: Seção 8 (INSERT de teste)
   [ ] Verificar: SELECT retorna 5 linhas
   [ ] Opcional: Excluir dados de teste depois

8. VERIFICAÇÃO FINAL
   [ ] Abrir "Table Editor" → bus_schedules
   [ ] Verificar que dados aparecem
   [ ] Verificar timestamps (created_at, updated_at preenchidos)

9. VERIFICAR PERFORMANCE
   [ ] Abrir "Database" → "Indexes"
   [ ] Verificar que idx_bus_schedules_updated_at existe
   [ ] Isso é crítico para sync rápida

10. CONFIGURAR NO APP
    [ ] Adicionar URL do Supabase em main.dart
    [ ] Adicionar anonKey do Supabase em main.dart
    [ ] Executar: flutter run
    [ ] Testar: syncFromServer() deve funcionar

✅ TUDO PRONTO PARA USAR!
*/

-- ============================================================================
-- BACKUP DE SEGURANÇA
-- ============================================================================

-- Para fazer backup:
-- pg_dump -h db.xxxxx.supabase.co -U postgres -d postgres > backup.sql

-- Para restaurar:
-- psql -h db.xxxxx.supabase.co -U postgres -d postgres < backup.sql

-- ============================================================================
-- MIGRAÇÃO FUTURA (Se modificar schema)
-- ============================================================================

/*
Se no futuro precisar adicionar/remover colunas:

1. Adicionar coluna:
   ALTER TABLE bus_schedules ADD COLUMN nova_coluna TEXT;

2. Remover coluna:
   ALTER TABLE bus_schedules DROP COLUMN coluna_antiga;

3. Mudar tipo:
   ALTER TABLE bus_schedules ALTER COLUMN coluna_antiga TYPE novo_tipo;

4. Criar nova versão da chave de sync:
   UPDATE shared_preferences SET value = NULL WHERE key = 'bus_schedules_last_sync_v1';
   -- Isso força sincronização completa na próxima vez
*/

-- ============================================================================
-- FIM DO SCHEMA SUPABASE
-- ============================================================================
