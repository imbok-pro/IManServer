

Select 
 al.tablespace_name,
 bytes_all,
 bytes_free, 
 ROUND(100*(1-bytes_free/bytes_all),1) per
From
(Select 
a.tablespace_name,
sum(ROUND(nvl(a.bytes,0)/1024/1024)) bytes_all
From dba_data_files a
Group by tablespace_name) al,
(Select 
d.tablespace_name,
sum(ROUND(nvl(d.bytes,0)/1024/1024)) bytes_free
From dba_free_space d
Group by tablespace_name) fr
Where al.tablespace_name=fr.tablespace_name
Order by 1

-- v$datafile