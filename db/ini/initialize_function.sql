
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
create function narrowflake_with_type(sql_table text, content_type bit)
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
  begin
    return b'00111111';
  end;
$$ language plpgsql;


drop function if exists account_info(varchar(30));
create function account_info(name_id varchar(30))
returns table(account_id bigint, account_name_id varchar(30), account_name varchar(30), account_mail varchar(30)) as $$
  begin
    return query
      select account_id, account_name_id, account_name, account_mail
      from AccountList
      /* account_idがunique必須*/
      where account_id = name_id;
  end;
$$ language plpgsql;

drop function if exists is_valid_token(varchar(30));
create function is_valid_token(v_valid_token varchar(30))
returns boolean as $$
  select  from AccessToken where access_token = v_access_token

$$ language plpgsql;


