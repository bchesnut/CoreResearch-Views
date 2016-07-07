create or replace view v_duke_pathdiagtree as
select s_clinicaldiagid,
       ltrim(sys_connect_by_path(clinicaldiagdesc, '|'), '|') clinicaldiagdesc
  from s_clinicaldiag s
 start with parentclinicaldiagid is null
 connect by prior s_clinicaldiagid = parentclinicaldiagid;
