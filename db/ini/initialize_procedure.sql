
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

create procedure create_group()
language sql
as $$
  begin;

  commit;
$$;

create procedure create_plan()
language sql
as $$
  begin;

  commit;
$$;
