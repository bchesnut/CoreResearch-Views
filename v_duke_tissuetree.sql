create or replace view v_duke_tissuetree as
select s_tissueid,
       replace(ltrim(sys_connect_by_path(tissuedesc, '||'), '|'), '||', ':') tissue_desc
  from S_TISSUE
 start with parenttissueid is null
 connect by prior s_tissueid = parenttissueid;
