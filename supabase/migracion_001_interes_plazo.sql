-- Migracion: agrega tasa de interes lineal y plazo a los prestamos "yo_presto"
-- Correr en Supabase SQL Editor (proyecto tgyzzfdwfwkfoohsxhpr)

alter table prestamos
  add column if not exists tasa_interes numeric(5,2),
  add column if not exists plazo_tipo text,
  add column if not exists plazo_cantidad integer,
  add column if not exists fecha_vencimiento date;

alter table prestamos
  drop constraint if exists prestamos_plazo_tipo_check;

alter table prestamos
  add constraint prestamos_plazo_tipo_check check (plazo_tipo in ('mensual', 'quincenal'));
