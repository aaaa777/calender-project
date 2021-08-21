
create procedure create_account(v_account_name_id varchar(30), v_account_name varchar(30), v_account_mail varchar(255), inout _account_id bigint default 0)
language sql
as $$
  begin;
    insert into AccountList(account_name_id, account_name, account_mail)
      values(v_account_name_id, v_account_name, v_account_mail)
      returning account_id into _account_id;
  commit;
$$;

create procedure create_organization(v_organization_name varchar(30), v_organization_address varchar(30), v_organization_author_account_id varchar(30), inout _organization_id bigint default 0)
language sql
as $$
  begin;
    insert into OrganizationList(organization_name, organization_address, organization_author_account_id)
      values(organization_name, organization_address, organization_author_account_id)
      returning organization_id into _organization_id;
  commit;
$$;

create procedure create_group(v_member_id bigint, v_group_name varchar(30), v_group_phone_number bigint, inout _group_id bigint)
language sql
as $$
  begin;
    insert into GroupList(group_name, organization_id, group_author_member_id, group_phone_number)
    values(v_group_name, '' , v_member_id, v_group_phone_number)
    returning group_id into _group_id;
  commit;
$$;

create procedure create_plan()
language sql
as $$
  begin;

  commit;
$$;

create procedure authorize_user(account_id bigint, account_password text, inout _access_token)
language sql
as $$
  
$$;
