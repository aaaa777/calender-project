
drop table if exists AccountList;
create table AccountList(
  -- content_id: 0001はuser
  -- テスト環境なのでnarrowflake_seqシーケンスを使用
  account_id bigint primary key default narrowflake('narrowflake_seq', b'00111111', b'0001'),
  name_id varchar(30) not null,
  name varchar(30) not null,
  mail varchar(255) not null
);

drop table if exists AccessToken;
create table AccessToken(
  access_token text not null default new_token() primary key,
  account_id bigint not null,
  expires_for timestamp default current_timestamp
);

drop table if exists AccountPassword;
create table AccountPassword(
  account_id bigint primary key,
  salt text not null,
  password_hash text not null
);

drop table if exists OrganizationList;
create table OrganizationList(
  organization_id bigint primary key default narrowflake('narrowflake_seq', dc_id(), b'0010'),
  name varchar(30) not null,
  address varchar(150),
  author_account_id bigint not null,
  organization_token char(30)
);

drop table if exists OrganizationInvitation;
create table OrganizationInvitation(
  invite_token char(20) primary key,
  organization_id bigint not null,
  /*下のテーブルとの型指定揺れあり*/
  group_id bigint,
  account_id bigint not null
);

drop table if exists MemberList;
create table MemberList(
  member_id bigint primary key default narrowflake('narrowflake_seq', dc_id(), b'0011'),
  account_id bigint not null,
  organization_id bigint not null,
  -- group_id char(32) not null,
  name varchar(30) not null,
  phone_number varchar(15),
  mail varchar(255),
  accepting_flag boolean
);

drop table if exists GroupList;
create table GroupList(
  group_id bigint primary key default narrowflake('narrowflake_seq', dc_id(), b'0100'),
  group_name varchar(30) not null,
  organization_id bigint not null,
  author_member_id bigint not null,
  phone_number bigint,
  group_flag boolean-- ,
  -- group_token char(30)
);

drop table if exists GroupMember;
create table GroupMember(
  id bigserial primary key,
  member_id bigint not null,
  group_id bigint not null
);

drop table if exists PlanList;
create table PlanList(
  plan_id bigint primary key default narrowflake('narrowflake_seq', dc_id(), b'0101'),
  organization_id bigint not null,
  title varchar(30) not null,
  description varchar(200),
  group_id bigint,
  author_member_id bigint,
  host_member_id bigint,
  creation_date timestamp,
  plan_delete_permission boolean,
  category_id char(20),
  location_url varchar(150),
  location_name varchar(20),
  event_id char(32),
  plan_event_token char(32)
);

drop table if exists PlanKeywordList;
create table PlanKeywordList(
  plan_id bigint primary key,
  keyword varhar(30) not null
);

drop table if exists PlanMemberList;
create table PlanMemberList(
  plan_id bigint primary key,
  member_id bigint not null
);
