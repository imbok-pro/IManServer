-- SP MAIL
-- by SGemba
-- 
-- create 05.11.2014
--*****************************************************************************

create table SP.MAIL_CONFIG
(
  id           NUMBER(4) not null,
  host_name    VARCHAR2(255),
  port         NUMBER(6),
  username     VARCHAR2(80),
  password     VARCHAR2(32),
  from_address VARCHAR2(80),
  reply_to     VARCHAR2(80)
)
;
comment on table SP.MAIL_CONFIG
  is '������������ ��������� �������';
comment on column SP.MAIL_CONFIG.id
  is '������������� ������������';
comment on column SP.MAIL_CONFIG.host_name
  is '����� �������';
comment on column SP.MAIL_CONFIG.port
  is '����';
comment on column SP.MAIL_CONFIG.username
  is '��� ������������';
comment on column SP.MAIL_CONFIG.password
  is '������';
comment on column SP.MAIL_CONFIG.from_address
  is '����� �����������';
comment on column SP.MAIL_CONFIG.reply_to
  is '����� �� �������';
alter table SP.MAIL_CONFIG
  add constraint PK_MAIL_CFG primary key (ID);

CREATE OR REPLACE PUBLIC SYNONYM MAIL_CONFIG FOR sp.MAIL_CONFIG;
GRANT UPDATE ON MAIL_CONFIG TO PUBLIC;
GRANT INSERT ON MAIL_CONFIG TO PUBLIC;
GRANT DELETE ON MAIL_CONFIG TO PUBLIC;
GRANT SELECT ON MAIL_CONFIG TO PUBLIC;

create table SP.MAIL_CFG_ATTRS
(
  mail_cfg_id NUMBER(4) not null,
  attr_name   VARCHAR2(80) not null,
  attr_value  VARCHAR2(80)
)
;
comment on table SP.MAIL_CFG_ATTRS
  is '�������������� �������� ��� ������������ ��������� �������';
comment on column SP.MAIL_CFG_ATTRS.mail_cfg_id
  is '������������� ������������';
comment on column SP.MAIL_CFG_ATTRS.attr_name
  is '�������� ��������';
comment on column SP.MAIL_CFG_ATTRS.attr_value
  is '�������� ��������';
alter table SP.MAIL_CFG_ATTRS
  add constraint PK_MAIL_CFG_ATTR primary key (MAIL_CFG_ID, ATTR_NAME);
alter table SP.MAIL_CFG_ATTRS
  add constraint FK_MAIL_ATTRCFG_CFG foreign key (MAIL_CFG_ID)
  references SP.MAIL_CONFIG (ID);

CREATE OR REPLACE PUBLIC SYNONYM MAIL_CFG_ATTRS FOR sp.MAIL_CFG_ATTRS;
GRANT UPDATE ON MAIL_CFG_ATTRS TO PUBLIC;
GRANT INSERT ON MAIL_CFG_ATTRS TO PUBLIC;
GRANT DELETE ON MAIL_CFG_ATTRS TO PUBLIC;
GRANT SELECT ON MAIL_CFG_ATTRS TO PUBLIC;

create table SP.MAIL_MESSAGES
(
  subject   VARCHAR2(80),
  recepient VARCHAR2(1024),
  cc        VARCHAR2(1024),
  text      CLOB
)
;
comment on table SP.MAIL_MESSAGES
  is '��������� ��� ��������';
comment on column SP.MAIL_MESSAGES.subject
  is '����';
comment on column SP.MAIL_MESSAGES.recepient
  is '������ ����������� (����� ;)';
comment on column SP.MAIL_MESSAGES.cc
  is '������ ��� ���� ������������ �����';
comment on column SP.MAIL_MESSAGES.text
  is '����� ���������';

CREATE OR REPLACE PUBLIC SYNONYM MAIL_MESSAGES FOR sp.MAIL_MESSAGES;
GRANT UPDATE ON MAIL_MESSAGES TO PUBLIC;
GRANT INSERT ON MAIL_MESSAGES TO PUBLIC;
GRANT DELETE ON MAIL_MESSAGES TO PUBLIC;
GRANT SELECT ON MAIL_MESSAGES TO PUBLIC;
