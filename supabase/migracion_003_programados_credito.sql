-- Migracion: movimientos programados (fecha futura, no cuentan hasta confirmarse)
-- y tipo "credito" (prestamos bancarios con cronograma de cuotas)
-- Correr en Supabase SQL Editor (proyecto tgyzzfdwfwkfoohsxhpr)

alter table movimientos
  add column if not exists estado text not null default 'confirmado';

alter table movimientos
  add constraint movimientos_estado_check check (estado in ('confirmado', 'programado'));

create index if not exists idx_movimientos_estado on movimientos(estado);

alter table prestamos
  drop constraint if exists prestamos_tipo_check;

alter table prestamos
  add constraint prestamos_tipo_check check (tipo in ('me_prestan', 'yo_presto', 'inversion', 'credito'));
