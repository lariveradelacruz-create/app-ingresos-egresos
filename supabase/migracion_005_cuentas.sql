-- Migracion: cuentas (donde esta fisicamente el dinero) por contexto
-- Correr en Supabase SQL Editor (proyecto tgyzzfdwfwkfoohsxhpr)

create table if not exists cuentas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  contexto text not null check (contexto in ('personal', 'negocio')),
  orden integer not null default 0,
  created_at timestamptz not null default now()
);

alter table cuentas enable row level security;

create policy "cuentas_all_authenticated" on cuentas
  for all to authenticated using (true) with check (true);

grant select, insert, update, delete on cuentas to authenticated;

alter table movimientos
  add column if not exists cuenta_id uuid references cuentas(id) on delete set null;

create index if not exists idx_movimientos_cuenta on movimientos(cuenta_id);

-- Cuentas por defecto (edita los nombres o agrega mas desde la app)
insert into cuentas (nombre, contexto, orden)
select 'Billetera (efectivo)', 'personal', 1
where not exists (select 1 from cuentas where contexto = 'personal');

insert into cuentas (nombre, contexto, orden)
select 'Caja / Cofre', 'negocio', 1
where not exists (select 1 from cuentas where contexto = 'negocio');

-- Deja los movimientos existentes ligados a la cuenta por defecto de su contexto,
-- para que el detalle por cuenta cuadre con el saldo total que ya ves hoy.
update movimientos m
set cuenta_id = c.id
from cuentas c
where m.cuenta_id is null
  and c.contexto = m.contexto
  and c.nombre = case when m.contexto = 'negocio' then 'Caja / Cofre' else 'Billetera (efectivo)' end;
