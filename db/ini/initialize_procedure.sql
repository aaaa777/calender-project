/*トークンはプロシージャ側で検証*/

drop procedure RegisterAccessToken(bigint, varchar, text);
create procedure RegisterAccessToken(v_account_id bigint, v_account_password varchar(30), inout access_token text default null)
as $$
  declare
    -- access_token alias for $3;
  begin
    /*--- account_name_idの存在確認 と パスワード確認 ---*/
    if not (select exists (select true from account_info(v_account_id))) or not is_valid_password(v_account_id, v_account_password) then
      return;
    end if;

    insert into AccessToken(account_id) values(v_account_id) returning AccessToken.access_token into $3;
  end;
$$ language plpgsql;


create procedure IsValidToken(v_account_id bigint, v_access_token text, inout result boolean default null)
as $$
  begin
    if not (select true from MemberList as mlist where mlist.account_id = v_account_id) then
      return;
    end if;
    result := is_valid_token(v_account_id, v_access_token);
  end;
$$ language plpgsql;


drop procedure CreateAccount(varchar, varchar, varchar, text, bigint);
create procedure CreateAccount(v_name_id varchar(30), v_name varchar(30), v_mail varchar(255), v_raw_password text, inout account_id bigint default null)
as $$
  declare
    -- account_id alias for $5;
    new_salt text = gen_salt('bf');
  begin
    insert into AccountList(name_id, name, mail)
      values(v_name_id, v_name, v_mail)
      returning AccountList.account_id into $5;
    raise notice '$5: %', $5;
    perform add_password(account_id, v_raw_password);
  end;
$$ language plpgsql;


drop procedure if exists UpdateAccount(bigint, varchar, varchar, varchar);
create procedure UpdateAccount(v_account_id bigint, v_account_name_id varchar(30), v_account_name varchar(30), v_account_mail varchar(255))
as $$
  begin
    update AccountList as alist set alist.account_name_id = v_account_name_id, alist.account_name = v_account_name, alist.account_mail = v_account_mail where alist.account_id = v_account_id;
  end;
$$ language plpgsql;


drop procedure if exists DeleteAccount(bigint);
create procedure DeleteAccount(v_account_id bigint)
as $$
  begin
    delete from AccountList as alist where alist.account_id = v_account_id;
    delete from AccountPassword as apass where apass.account_id = v_account_id;
  end;
$$ language plpgsql;


drop procedure if exists GetAccount(bigint, varchar, varchar, varchar);
create procedure GetAccount(account_id bigint, inout name varchar(30) default null, inout name_id varchar(30) default null, inout mail varchar(255) default null)
as $$
  begin
    select into $2, $3, $4 
      alist.name, alist.name_id, alist.mail
      from AccountList as alist;
  end;
$$ language plpgsql;


drop procedure if exists ChangePassword(bigint, text);
create procedure change_password(v_account_id bigint, v_raw_password text)
as $$
  begin
    perform update_password(v_raw_password));
  end;
$$ language plpgsql;


drop procedure ResetPassword(bigint, text);
create procedure reset_password(v_account_id bigint, inout new_password text default '')
as $$
  begin
    new_password := randomize_password();
  end;
$$ language plpgsql;


drop procedure CreateOrganization(bigint, varchar, varchar, bigint)
create procedure CreateOrganization(v_account_id bigint, v_organization_name varchar(30), v_organization_address varchar(30), inout organization_id bigint default null)
as $$
  begin
    organization_id := add_organization(v_account_name, v_organization_address, v_organization_author_account_id);
  end;
$$ language plpgsql;
/*
    return;
    if not exists (select ti.account_id = v_account_id from token_info(v_access_token) as ti) then
      return;
    end if;
    insert into OrganizationList(organization_name, organization_address, organization_author_account_id)
      values(v_organization_name, v_organization_address, v_account_id)
      returning organization_id into _organization_id;
*/
create procedure CreateGroup(v_member_id bigint, v_group_name varchar(30), v_group_phone_number bigint, inout group_id bigint)
as $$
  declare
    group_id alias for $1;
  begin
    insert into GroupList(group_name, organization_id, group_author_member_id, group_phone_number)
      values(v_group_name, '' , v_member_id, v_group_phone_number)
      returning GroupList.group_id into $1;
  end;
$$ language plpgsql;


drop procedure CreatePlan(bigint, bigint, varchar(30), bigint);
create procedure CreatePlan(v_member_id bigint, v_group_id bigint, v_title varchar(30), inout plan_id bigint default 0)
as $$
  declare
    v_organization_id bigint := (select mlist.organization_id from member_info(v_member_id) as mlist);
  begin
    raise notice 'orgid: %', v_organization_id;
    plan_id := add_plan(v_member_id, v_title, v_organization_id, v_group_id);
    raise notice '$1: %', plan_id;
  end;
$$ language plpgsql;

