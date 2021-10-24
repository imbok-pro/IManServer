select * from dba_profiles where RESOURCE_NAME LIKE 'PASSWORD_LIFE_TIME'
/

ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED
; 

select 'ALTER USER ' || username || ' IDENTIFIED BY VALUES ''' || password || ''';' 
from dba_users
/
select * from dba_users
