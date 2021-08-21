
-- id: 1111
create sequence narrowflake_seq(
  maxvalue 1023,
  minvalue 0,
  cycle
);

-- id: 0001
create sequence narrowflake_user(
  maxvalue 1023,
  minvalue 0,
  cycle
);

-- id: 0002
create sequence narrowflake_organization(
  maxvalue 1023,
  minvalue 0,
  cycle
);

-- id: 0003
create sequence narrowflake_group(
  maxvalue 1023,
  minvalue 0,
  cycle
);

-- id: 0004
create sequence narrowflake_plan(
  maxvalue 1023,
  minvalue 0,
  cycle
);
