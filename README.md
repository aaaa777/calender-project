## 起動手順

### 1. Dockerのインストール

### 2. Docker networkの作成

`docker network create --internal backend`
`docker network create frontend`

### 3. コンテナ起動

`docker-compose up`

## コミット時の定形（コミッター向け）

コミットメッセージの雛形を以下に定める
```
1: \[変更ステータス] 変更点の要約
2:  # 空行
3: 全体の変更点の要約
---ここから繰り返し---
4:  # 空行
5: (modified | updated | deleted | created):  FILENAME
6: 変更点の説明
---変更ファイル数分繰り返す---
```
- ファイルごとの変更点説明や4行目以降自体を省略しても良い

## nallowflake
snowflakeのパクリ規格
```
+-+---------------------+---------------------+----------+---------+
| |    timestamp starts |datacenter info(8bit)| sequence | content |
|0| 2021/01/01 00:00:00 +--------+------------+   number |   type  |
| |             (41bit) |id(3bit)|worker(5bit)|  (10bit) |  (4bit) |
+-+---------------------+--------+------------+----------+---------+
(total 64bit)
```
timestampは2021年1月1日00:00:00起算
dc_idはdatacenter_id、つまり物理的な実行地点やワーカー毎に割り振りをする
とりあえず予定では一個しか動かさないので適当に`127(01111111)`を振る
シーケンスセクションはSQLでsequenceという特殊なテーブルと`nextval()`を利用して実装できる
別に毎時刻０始まりにする必要はないので都度nextval()を呼べば良い
ちなみにsequenceは内部的にbigintになっているらしいので64bitを超える数値範囲は返せないようだ

```
create sequence nallowflake_seq(
  maxvalue 1023
  minvalue 0
  cycle
);
```

これを利用したnallowflake(integer)関数を作る
```
drop function if exists nallowflake_with_type(bit);
create or replace function nallowflake_with_type(content_type bit)
returns bigint as $$
  begin
    --     timestamp                                                                                      || datacenter  || sequence                            || content_type
    return ((extract(epoch from date_trunc('second', current_timestamp)) - 1609426800.0)::bigint::bit(41) || b'01111111' || nextval('nallowflake_seq')::bit(10) || content_type)::bit(63)::bigint;
  end;
$$ language plpgsql;
```

実際には発行時の計算を減らすためにdatacenterとtypeを予め計算した形で放り込んでおく別関数を作る
もしかしたらplpgsql側で畳み込みしてくれているのかも知れないけど一応
この実装だと0バイト目にtimestamp入る可能性があるけどそれは69年後に考えればいい
note: postgres8.0より前は::bit(n)は最上位ビットからnビット分コピーされることに注意

