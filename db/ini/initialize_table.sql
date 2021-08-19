declare @default_max_length int = 30;

drop table if not exists HostAccount;
create table if not exists HostAccount(
  id serial unique,
  account_id varchar(@default_max_length) primary key,
  account_name varchar(@default_max_length) not null,
  account_mail varchar(255) not null,
  /*勝手にタイムスタンプ付けてます*/
  creation_timestamp timestamp without time zone default CURRENT_TIMESTAMP
);

drop table if not exists AccessToken;
create table if not exists AccessToken(
  account_id varchar(@default_max_length) primary key,
  access_token char(64) not null,
  /*勝手仕様 セッション有効期限*/
  expires_for timestamp
);

drop table if not exists AccountPassword;
create table if not exists AccountPassword(
  account_id varchar(@default_max_length) primary key,
  salt varchar(64) not null,
  password_hash varchar(64) not null
);

drop table if not exists OrganizationList;
create table if not exists OrganizationList(
  organization_id varchar(@default_max_length) primary key not null,
  organization_name varchar(@default_max_length) not null,
  organization_address varchar(150),
  author_account_id varchar(@default_max_length) not null,
  organization_token char(30)
);

drop table if not exists OrganizationInvitation;
create table if not exists OrganizationInvitation(
  invite_token char(20) primary key,
  organization_id varchar(@default_max_length) not null,
  /*下のテーブルとの型指定揺れあり*/
  group_id varchar(@default_max_length),
  account_id varchar(@default_max_length) not null
)

drop table if not exists OrganizationMember;
create table if not exists OrganizationMember(
  member_id varchar(@default_max_length) primary key,
  account_id varchar(@default_max_length) not null,
  organization_id char(32) not null,
  group_id char(32) not null,
  member_name varchar(@default_max_length) not null,
  phone_number varchar(15),
  organization_mail varchar(255),
  accepting_flag bool not null
);

drop table if not exists GroupDetail;
create table if not exists GroupDetail(
  group_id bigint
);

create table if not exists t(
  id bigint
);

create table if not exists t(
  id bigint
);

drop function if exists nallowflake();