-- XEN SCHOOL MANAGEMENT v1: verified-user school provisioning
-- Creates a school in onboarding status and bootstraps its first owner membership.
-- The owner role copies school_admin permissions (not platform-owner permissions).
create or replace function public.provision_school_for_current_user(
  p_legal_name text,
  p_display_name text,
  p_slug text,
  p_country_code text default 'ZW',
  p_currency_code text default 'USD',
  p_timezone text default 'Africa/Harare'
)
returns table (school_id uuid, school_slug text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_school_id uuid;
  v_membership_id uuid;
  v_role_id uuid;
  v_template_role_id uuid;
  v_email_confirmed timestamptz;
begin
  if v_user_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  select u.email_confirmed_at into v_email_confirmed
  from auth.users u
  where u.id = v_user_id;

  if v_email_confirmed is null then
    raise exception 'Please verify your email before creating a school' using errcode = '42501';
  end if;

  if p_legal_name is null or length(trim(p_legal_name)) < 2 or length(trim(p_legal_name)) > 160 then
    raise exception 'Legal name must be between 2 and 160 characters' using errcode = '22023';
  end if;
  if p_display_name is null or length(trim(p_display_name)) < 2 or length(trim(p_display_name)) > 100 then
    raise exception 'Display name must be between 2 and 100 characters' using errcode = '22023';
  end if;
  if p_slug is null or p_slug !~ '^[a-z0-9](?:[a-z0-9-]{1,58}[a-z0-9])$' then
    raise exception 'School URL slug must be 3–60 lowercase letters, numbers or hyphens' using errcode = '22023';
  end if;
  if p_country_code is null or p_country_code !~ '^[A-Z]{2}$' then
    raise exception 'Country code must be a two-letter uppercase ISO code' using errcode = '22023';
  end if;
  if p_currency_code is null or p_currency_code !~ '^[A-Z]{3}$' then
    raise exception 'Currency code must be a three-letter uppercase ISO code' using errcode = '22023';
  end if;
  if p_timezone is null or length(trim(p_timezone)) < 3 or length(trim(p_timezone)) > 80 then
    raise exception 'Timezone is invalid' using errcode = '22023';
  end if;

  insert into public.schools(slug,legal_name,display_name,country_code,default_currency,timezone,status)
  values (p_slug,trim(p_legal_name),trim(p_display_name),p_country_code,p_currency_code,trim(p_timezone),'onboarding')
  returning id into v_school_id;

  insert into public.school_memberships(school_id,user_id,status,joined_at)
  values (v_school_id,v_user_id,'active',now())
  returning id into v_membership_id;

  select r.id into v_template_role_id
  from public.roles r
  where r.school_id is null and r.role_key = 'school_admin' and r.status = 'active'
  limit 1;

  if v_template_role_id is null then
    raise exception 'School administrator role template is not configured' using errcode = '55000';
  end if;

  insert into public.roles(school_id,role_key,display_name,description,is_system,status)
  values (v_school_id,'school_owner','School Owner','Initial verified school owner; school-scoped administrator permissions.',true,'active')
  returning id into v_role_id;

  insert into public.role_permissions(role_id,permission_id)
  select v_role_id,rp.permission_id
  from public.role_permissions rp
  where rp.role_id = v_template_role_id;

  insert into public.membership_roles(school_id,membership_id,role_id,granted_by,valid_from)
  values (v_school_id,v_membership_id,v_role_id,v_user_id,now());

  return query select v_school_id,p_slug;
end;
$$;

revoke all on function public.provision_school_for_current_user(text,text,text,text,text,text) from public, anon;
grant execute on function public.provision_school_for_current_user(text,text,text,text,text,text) to authenticated;
