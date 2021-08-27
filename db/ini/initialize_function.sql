
-- narrowflakeのid作成関数
drop function if exists narrowflake(text, bit, bit);
create function narrowflake(seq_table text, datacentar_id bit, content_type bit)
returns bigint as $$
  begin
    return (
        -- 起算時の差分秒数を計算する
        (extract(epoch from date_trunc('second', current_timestamp)) - 1609426800.0)::bigint::bit(41) ||
        -- データセンターID
        datacentar_id::bit(8) ||
        -- シーケンス取得
        nextval(seq_table)::bit(10) ||
        -- IDの種別
        content_type::bit(4)
      )::bit(63)::bigint;
  end;
$$ language plpgsql;


drop function if exists narrowflake(text, bit);
create function narrowflake(seq_table text, content_type bit)
returns bigint as $$
  begin
    return (
        -- 起算時の差分秒数を計算する
        (extract(epoch from date_trunc('second', current_timestamp)) - 1609426800.0)::bigint::bit(41) ||
        -- データセンターID
        dc_id() ||
        -- シーケンス取得
        nextval(seq_table)::bit(10) ||
        -- IDの種別
        content_type::bit(4)
      )::bit(63)::bigint;
  end;
$$ language plpgsql;


drop function if exists dc_id();
create function dc_id()
returns bit as $$
  declare
    datacenter_bit constant bit := b'00111111';
  begin
    return datacentar_bit;
  end;
$$ language plpgsql;


--returns table(account_id bigint, account_name_id varchar(30), account_name varchar(30), account_mail varchar(30)) as $$
drop function if exists account_info(varchar(30));
create function account_info(v_name_id varchar(30))
returns table(account_id bigint, name_id varchar(30), name varchar(30), mail varchar(30)) as $$
  begin
    return query
      select alist.account_id, alist.name_id, alist.name, alist.mail
      from AccountList as alist
      /* account_name_idがunique必須*/
      where name_id = v_name_id;
  end;
$$ language plpgsql;

--returns table(account_id bigint, account_name_id varchar(30), account_name varchar(30), account_mail varchar(30)) as $$
drop function if exists account_info(bigint);
create function account_info(v_account_id bigint)
returns table(account_id bigint, name_id varchar(30), name varchar(30), mail varchar(255)) as $$
  begin
    return query
      select alist.account_id, alist.name_id, alist.name, alist.mail
      from AccountList as alist
      where alist.account_id = v_account_id;
  end;
$$ language plpgsql;


/* このDBに存在するアカウントのみトークンを突き合わせる */

drop function if exists is_valid_token(bigint, text);
create function is_valid_token(v_account_id bigint, v_access_token text)
returns boolean as $$
  return (select exists (select atoken.account_id = account_id from AccessToken as atoken where atoken.access_token = v_access_token and));
$$ language plpgsql;


drop function if exists new_token();
create function new_token()
returns text as $$
  begin
    return right(sha256((narrowflake('narrowflake_seq', dc_id(), b'1111')::text || gen_salt('md5'))::bytea), 64);
  end;
$$ language plpgsql;


/*--- account_idのパスワードを設定- --*/

drop function if exists add_password(bigint, text);
create function add_password(v_account_id bigint, v_raw_password text)
returns void as $$
  declare
    new_salt text := gen_salt('bf');
  begin
    insert into AccountPassword(account_id, salt, password_hash)
      values(v_account_id, new_salt, crypt(v_raw_password, new_salt));
  end;
$$ language plpgsql;


/*--- account_idのパスワードを削除- --*/

drop function if exists del_password(bigint);
create function del_password(v_account_id bigint)
returns void as $$
  begin
    delete from AccountPassword
      where account_id = v_account_id;
  end;
$$ language plpgsql;


/*--- account_idのパスワードを上書き- --*/

drop function if exists update_password(bigint, text);
create function update_password(v_account_id bigint, v_raw_password text)
returns void as $$
  begin
    perform del_password(v_account_id);
    perform add_password(v_account_id, v_raw_password);
  end;
$$ language plpgsql;


/*--- account_idのパスワードをランダムな文字列に置き換え- --*/

drop function if exists randomize_password(bigint);
create function randomize_password(v_account_id bigint)
returns text as $$
  declare
    new_password text := generate_random_password8();
  begin
    perform update_password(v_account_id, new_password);
    return new_password;
  end;
$$ language plpgsql;


/*--- account_idのパスワードを照合- --*/

drop function if exists is_valid_password(bigint, text);
create function is_valid_password(v_account_id bigint, v_raw_password text)
returns boolean as $$
  begin
    return (select crypt(v_raw_password, salt) = password_hash from AccountPassword where account_id = v_account_id);
  end;
$$ language plpgsql;


/*---
 utillity functions 
---*/

drop function if exists generate_random_password8();
create function generate_random_password8()
returns text as $$
  begin
    return right(gen_salt('md5'), 8);
  end;
$$ language plpgsql;


drop function if exists add_organization(text, text, bigint, bigint);
create function add_organization(v_organization_name text, v_organization_address text, v_organization_author_account_id bigint, inout _organization_id bigint default 0)
as $$
  begin
    insert into OrganizationList(organization_name, organization_address, organization_author_account_id)
      values(v_organization_name, v_organization_address, v_organization_author_account_id)
      returning organization_id into _organization_id;
  end;
$$ language plpgsql;

drop function if exists del_organization(bigint);
create function del_organization(v_organization_id bigint)
returns void as $$
  begin
    delete from OrganizationList as olist
      where olist.organization_id = v_organization_id;
  end;
$$ language plpgsql;

drop function if exists update_organization(bigint, text, text, bigint);
create function upd_organization(v_organization_id bigint, v_organization_name text, v_organization_address text, v_organization_author_account_id bigint)
returns void as $$
  begin
    perform del_organization(v_organization_id);
    perform add_organization(v_organization_name, v_organization_address, v_organization_author_account_id);
  end;
$$ language plpgsql;


drop function if exists organization_info(bigint);
create function organization_info(v_organization_id bigint)
returns table(name varchar(30), address varchar(150), author_account_id bigint) as $$
  begin
    return query
      select olist.organization_name, olist.organization_address, olist.organization_author_account_id
      from OrganizationList as olist
      where olist.organization_id = v_organization_id;
  end;
$$ language plpgsql;


drop function if exists is_member_of(bigint, bigint);
create function is_member_of(v_member_id bigint, v_organization_id bigint)
returns boolean as $$
  begin
    return (select exists (select true from MemberList as mlist where mlist.account_id = v_member_id));
  end;
$$ language plpgsql;


drop function if exists member_info(bigint);
create function member_info(v_member_id bigint)
returns table(member_id bigint, name varchar(30), organization_id bigint) as $$
  begin
    return query
      select mlist.member_id, mlist.name, mlist.organization_id
      from MemberList as mlist
      where mlist.member_id = v_member_id;
  end;
$$ language plpgsql;



drop function if exists add_member(bigint, bigint, text, bigint, text);
create function add_member(v_account_id bigint, v_organization_id bigint, v_name text, v_phone_number bigint, v_mail text)
returns bigint as $$
  declare
    -- https://www.postgresql.jp/document/9.4/html/plpgsql-declarations.html
    member_id alias for $1;
  begin
    
    insert into MemberList(account_id, organization_id, name, phone_number, mail)
      values(v_account_id, v_organization_id, v_name, v_phone_number, v_mail)
      returning MemberList.member_id into $1;
    return $1;
  end;
$$ language plpgsql;





drop function if exists add_group(bigint, bigint, text, bigint, bigint);
create function add_group(v_member_id bigint, v_organization_id bigint, v_group_name text, v_phone_number bigint, group_id bigint default 0)
returns bigint as $$
  begin
    insert into GroupList(organization_id, group_name, author_member_id, phone_number) as glist
      values(v_organization_id, v_group_name, v_member_id, v_phone_number)
      returning glist.group_id into group_id;
  end;
$$ language plpgsql;



drop function if exists add_group_member(bigint, bigint);
create function add_group_member(v_group_id bigint, v_member_id bigint)
returns void as $$
  begin
    insert into GroupMember(member_id, group_id) values(v_member_id, v_group_id);
  end;
$$ language plpgsql;



drop function if exists add_plan(bigint, varchar, bigint, bigint);
create function add_plan(v_member_id bigint, v_title varchar(30), v_organization_id bigint, v_group_id bigint)
returns bigint as $$
  declare
    plan_id alias for $1;
  begin
    insert into PlanList(organization_id, group_id, title)
      values(v_organization_id, v_group_id, v_title)
      returning PlanList.plan_id into $1;
    return $1;
  end;
$$ language plpgsql;






