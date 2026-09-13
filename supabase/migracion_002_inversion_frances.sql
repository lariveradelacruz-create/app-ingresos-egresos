-- Migracion: agrega tipo "inversion" y metodo de interes frances (cuota fija)
-- Correr en Supabase SQL Editor (proyecto tgyzzfdwfwkfoohsxhpr)

alter table prestamos
  add column if not exists metodo_interes text,
  add column if not exists cuota_mensual numeric(12,2);

alter table prestamos
  add constraint prestamos_metodo_interes_check check (metodo_interes in ('lineal', 'frances'));

alter table prestamos
  drop constraint if exists prestamos_tipo_check;

alter table prestamos
  add constraint prestamos_tipo_check check (tipo in ('me_prestan', 'yo_presto', 'inversion'));
