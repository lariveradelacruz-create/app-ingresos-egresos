-- Migracion: separa Personal / Negocio, y agrega "eventos" para el negocio de sonido
-- Correr en Supabase SQL Editor (proyecto tgyzzfdwfwkfoohsxhpr)

create table if not exists eventos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,             -- ej. "Evento A", "Cumpleaños Juan"
  lugar text,
  fecha date not null default current_date,
  notas text,
  created_at timestamptz not null default now()
);

alter table eventos enable row level security;

create policy "eventos_all_authenticated" on eventos
  for all to authenticated using (true) with check (true);

grant select, insert, update, delete on eventos to authenticated;

alter table movimientos
  add column if not exists contexto text not null default 'personal',
  add column if not exists evento_id uuid references eventos(id) on delete set null;

alter table movimientos
  add constraint movimientos_contexto_check check (contexto in ('personal', 'negocio'));

create index if not exists idx_movimientos_contexto on movimientos(contexto);
create index if not exists idx_movimientos_evento on movimientos(evento_id);
