
drop table if exists AccountList;
create table AccountList(
  -- content_id: 0001はuser
  account_id bigint primary key default narrowflake('narrowflake_user', b'0001'),
  account_name_id varchar(30) not null,
  account_name varchar(30) not null,
  account_mail varchar(255) not null,
  /*勝手にタイムスタンプ付けてます*/
  -- creation_timestamp timestamp without time zone default CURRENT_TIMESTAMP
);

drop table if exists AccessToken;
create table AccessToken(
  account_id bigint primary key,
  access_token char(64) not null,
  /*勝手仕様 セッション有効期限*/
  expires_for timestamp
);

drop table if exists AccountPassword;
create table AccountPassword(
  account_id bigint primary key,
  salt varchar(64) not null,
  password_hash varchar(64) not null
);

drop table if exists OrganizationList;
create table OrganizationList(
  organization_id bigint primary key,
  organization_name varchar(30) not null,
  organization_address varchar(150),
  organization_author_account_id bigint not null,
  organization_token char(30)
);

drop table if exists OrganizationInvitation;
create table OrganizationInvitation(
  invite_token char(20) primary key,
  organization_id bigint not null,
  /*下のテーブルとの型指定揺れあり*/
  group_id bigint,
  account_id bigint not null
)

drop table if exists MemberList;
create table MemberList(
  member_id bigint primary key,
  account_id bigint not null,
  organization_id bigint not null,
  -- group_id char(32) not null,
  member_name varchar(30) not null,
  phone_number varchar(15),
  mail varchar(255),
  accepting_flag boolean not null
);

drop table if exists GroupList;
create table GroupList(
  group_id bigint unique,
  group_name varchar(30),
  organization_id varchar(30),
  group_author_member_id bigint not null,
  group_phone_number bigint,
  group_flag boolean-- ,
  -- group_token char(30)
);

drop table if exists PlanList;
create table PlanList(
  plan_id bigint primary key,
  plan_organization bigint not null,
  plan_title varchar(30) not null,
  plan_description varchar(200),
  plan_group_id bigint,
  plan_author_member_id bigint,
  plan_host_member_id bigint,
  plan_creation_date timestamp,
  plan_delete_permission boolean,
  plan_category_id char(20),
  plan_location_url varchar(150),
  plan_location_name varchar(20),
  plan_event_id char(32),
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
)
