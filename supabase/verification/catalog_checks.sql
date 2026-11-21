-- Read-only verification queries
select count(*) as public_tables from information_schema.tables where table_schema='public' and table_type='BASE TABLE';
select count(*) as rls_disabled from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind='r' and not c.relrowsecurity;
select count(*) as policies from pg_policies where schemaname='public';
select count(*) as tenant_select_policies from pg_policies where schemaname='public' and policyname='tenant_select';
select count(*) as global_roles from public.roles where school_id is null;
select count(*) as permissions from public.permissions;
select count(*) as role_permission_mappings from public.role_permissions;
select count(*) as currency_references from public.currency_definitions;
