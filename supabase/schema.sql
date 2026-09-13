-- App Ingresos y Egresos — esquema inicial
-- Correr completo en Supabase SQL Editor (proyecto tgyzzfdwfwkfoohsxhpr)

-- ============================================================
-- TABLA: prestamos
-- Cubre ambos sentidos: alguien te presta a ti (ej. tu esposa),
-- o tú le prestas a alguien y luego te devuelven / generas interés.
-- ============================================================
create table if not exists prestamos (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('me_prestan', 'yo_presto')),
  contraparte text not null,              -- ej. "Esposa", "Juan Pérez"
  monto_inicial numeric(12,2) not null,
  saldo_pendiente numeric(12,2) not null, -- para 'yo_presto' incluye el interés (monto + interes)
  tasa_interes numeric(5,2),              -- % lineal sobre el monto, solo 'yo_presto'
  interes numeric(12,2) default 0,        -- interés calculado = monto_inicial * tasa_interes/100
  plazo_tipo text check (plazo_tipo in ('mensual', 'quincenal')),
  plazo_cantidad integer,                 -- cantidad de meses/quincenas, hasta 3 meses
  fecha_vencimiento date,
  fecha_inicio date not null default current_date,
  estado text not null default 'activo' check (estado in ('activo', 'pagado')),
  notas text,
  created_at timestamptz not null default now()
);

-- ============================================================
-- TABLA: movimientos
-- Todo ingreso/egreso, incluidos los generados por préstamos
-- (desembolso, pago, cobro, interés). Cada uno puede llevar foto
-- de sustento (captura de Yape, transferencia, etc.).
-- ============================================================
create table if not exists movimientos (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('ingreso', 'egreso')),
  categoria text not null,                -- 'otro_ingreso','gasto','prestamo_recibido','pago_prestamo_recibido','prestamo_otorgado','cobro_prestamo_otorgado','interes_prestamo', etc.
  descripcion text,
  monto numeric(12,2) not null,
  fecha date not null default current_date,
  foto_url text,                          -- URL pública del bucket 'sustentos'
  prestamo_id uuid references prestamos(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists idx_movimientos_fecha on movimientos(fecha desc);
create index if not exists idx_movimientos_prestamo on movimientos(prestamo_id);

-- ============================================================
-- RLS — proyecto de uso personal (tú + tu esposa), sin
-- granularidad por fila, control real vía Supabase Auth.
-- ============================================================
alter table prestamos enable row level security;
alter table movimientos enable row level security;

create policy "prestamos_all_authenticated" on prestamos
  for all to authenticated using (true) with check (true);

create policy "movimientos_all_authenticated" on movimientos
  for all to authenticated using (true) with check (true);

-- Si el proyecto tiene desactivado "Automatically expose new tables",
-- estos GRANT son obligatorios (RLS controla filas, no privilegios de tabla):
grant select, insert, update, delete on prestamos, movimientos to authenticated;

-- ============================================================
-- STORAGE — bucket para las capturas/sustentos (Yape, transferencias)
-- Crear el bucket "sustentos" como PÚBLICO desde el dashboard
-- (Storage → New bucket → Public bucket: ON) y luego correr esto:
-- ============================================================
create policy "sustentos_insert_authenticated" on storage.objects
  for insert to authenticated with check (bucket_id = 'sustentos');

create policy "sustentos_update_authenticated" on storage.objects
  for update to authenticated using (bucket_id = 'sustentos');

create policy "sustentos_delete_authenticated" on storage.objects
  for delete to authenticated using (bucket_id = 'sustentos');
