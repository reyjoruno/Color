-- Run once in Supabase > SQL Editor > New query.
-- Each account may read and modify only its own inventory.
begin;
create table if not exists public.paint_inventory (
 user_id uuid not null references auth.users(id) on delete cascade,
 product_id text not null check (length(product_id) between 1 and 120),
 quantity integer check (quantity is null or quantity between 0 and 999),
 remaining text not null default '' check (remaining in ('', '少', '中', '大')),
 updated_at timestamptz not null default now(),
 primary key (user_id, product_id)
);
alter table public.paint_inventory enable row level security;
revoke all on public.paint_inventory from anon;
revoke all on public.paint_inventory from public;
revoke all on public.paint_inventory from authenticated;
grant select, insert, update on public.paint_inventory to authenticated;
drop policy if exists "Read own paint inventory" on public.paint_inventory;
create policy "Read own paint inventory" on public.paint_inventory
 for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "Insert own paint inventory" on public.paint_inventory;
create policy "Insert own paint inventory" on public.paint_inventory
 for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Update own paint inventory" on public.paint_inventory;
create policy "Update own paint inventory" on public.paint_inventory
 for update to authenticated using ((select auth.uid()) = user_id)
 with check ((select auth.uid()) = user_id);
create or replace function public.paint_inventory_set_updated_at()
 returns trigger language plpgsql set search_path = '' as $$
 begin new.updated_at = now(); return new; end;
$$;
drop trigger if exists paint_inventory_updated_at on public.paint_inventory;
create trigger paint_inventory_updated_at before update on public.paint_inventory
 for each row execute function public.paint_inventory_set_updated_at();
commit;
