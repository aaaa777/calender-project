
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
        b'00111111' ||
        -- シーケンス取得
        nextval(seq_table)::bit(10) ||
        -- IDの種別
        content_type::bit(4)
      )::bit(63)::bigint;
  end;
$$ language plpgsql;



