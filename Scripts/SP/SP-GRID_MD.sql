-- Create table
create table SP.GRID_MD
(
  grid_name   VARCHAR2(80) not null,
  column_name VARCHAR2(80) not null,
  editable    CHAR(1) not null,
  visible     CHAR(1) not null,
  options     VARCHAR2(4000),
  width       NUMBER(4),
  display_col VARCHAR2(32),
  value_col   VARCHAR2(32),
  widget_type VARCHAR2(32),
  seq_num     NUMBER(2) not null
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table SP.GRID_MD
  is 'Metadata for grid columns';
-- Add comments to the columns 
comment on column SP.GRID_MD.grid_name
  is 'Grid  name';
comment on column SP.GRID_MD.column_name
  is 'Column name';
comment on column SP.GRID_MD.editable
  is 'Editable Y or N';
comment on column SP.GRID_MD.visible
  is 'Visible Y or N';
comment on column SP.GRID_MD.options
  is 'SQL Query to find option data';
comment on column SP.GRID_MD.width
  is 'Column width';
comment on column SP.GRID_MD.display_col
  is 'Display column name (for combobox)';
comment on column SP.GRID_MD.value_col
  is 'Value column name (for lovs and combos)';
comment on column SP.GRID_MD.widget_type
  is 'Widget type (e.g. Lov, Combo, etc)';
comment on column SP.GRID_MD.seq_num
  is 'Sequence number';
-- Create/Recreate primary, unique and foreign key constraints 
alter table SP.GRID_MD
  add constraint PK_GRID_MD primary key (GRID_NAME, COLUMN_NAME)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate check constraints 
alter table SP.GRID_MD
  add constraint CK_GRID_MD_EDITABLE
  check (EDITABLE in ('Y', 'N'));
alter table SP.GRID_MD
  add constraint CK_GRID_MD_VISIBLE
  check (VISIBLE in ('Y', 'N'));

CREATE OR REPLACE PUBLIC SYNONYM GRID_MD FOR SP.GRID_MD;
GRANT UPDATE ON GRID_MD TO PUBLIC;
GRANT INSERT ON GRID_MD TO PUBLIC;
GRANT DELETE ON GRID_MD TO PUBLIC;
GRANT SELECT ON GRID_MD TO PUBLIC;

-- data loading
insert into SP.GRID_MD (grid_name, column_name, editable, visible, options, width, display_col, value_col, widget_type, seq_num)
values ('ALL_TASKS', 'NAME', 'Y', 'Y', null, 250, null, null, 'textfield', 0);
insert into SP.GRID_MD (grid_name, column_name, editable, visible, options, width, display_col, value_col, widget_type, seq_num)
values ('ALL_TASKS', 'PID', 'Y', 'Y', null, 80, null, null, 'textfield', 1);
insert into SP.GRID_MD (grid_name, column_name, editable, visible, options, width, display_col, value_col, widget_type, seq_num)
values ('ALL_TASKS', 'ID', 'N', 'N', null, 40, null, null, null, 4);
insert into SP.GRID_MD (grid_name, column_name, editable, visible, options, width, display_col, value_col, widget_type, seq_num)
values ('ALL_TASKS', 'MODEL_NAME', 'Y', 'Y', 'select m.ID code, m.MODEL_NAME name  from sp.v_models m where rownum <=5', 200, null, null, 'combobox', 2);
insert into SP.GRID_MD (grid_name, column_name, editable, visible, options, width, display_col, value_col, widget_type, seq_num)
values ('ALL_TASKS', 'MODEL_NAME_LOV', 'Y', 'Y', 'select m.ID code, m.MODEL_NAME name  from sp.v_models m', 200, null, null, 'lov', 3);

commit;
