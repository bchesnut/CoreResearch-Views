create or replace view v_duke_restrict_pi as
select pi.sysuserid pi_sysuserid,
       u.sysuserid sysuserid
  from sysuser pi
         inner join sysuserjobtype sjt on sjt.sysuserid = pi.sysuserid
         inner join jobtype pjt on pjt.jobtypeid = sjt.jobtypeid,
       sysuser u
         inner join jobtype ujt on ujt.jobtypeid = u.lastjobtype
 where pjt.u_jobtypeclass = 'PI'
   and (
         (ujt.u_jobtypeclass = 'PI' AND u.sysuserid = pi.sysuserid)
      or (ujt.u_jobtypeclass IN ('SYSTEM_ADMIN','FINANCIAL_ADMIN','CORE_DIRECTOR','CORE_MANAGER','CORE_STAFF'))
      or (ujt.u_jobtypeclass = 'PI_DELEGATE' and pi.sysuserid in (select pi from u_pisubmitter ps where ps.submitter = u.sysuserid and nvl(ps.proxytopiflag, 'N') = 'Y'))
      or (ujt.u_jobtypeclass in ('FACILITY_USER', 'EXTERNAL_FACILITY_USER') and pi.sysuserid in (select p.u_pi from s_project p, s_projectmember pm where p.s_projectid = pm.s_projectid and pm.sysuserid = u.sysuserid))
      or (ujt.u_jobtypeclass = 'FINANCIAL_MANAGER' AND exists (select 1 from u_fundsource fs where u.sysuserid in (fs.fm1, fs.fm2) and pi.sysuserid in (fs.respperson1, fs.respperson2)))
  )
union
select pr.u_pi pi_sysuserid,
       u.sysuserid sysuserid
  from s_project pr
         inner join u_projectcores pc on pc.s_projectid = pr.s_projectid
         inner join departmentsysuser ds on ds.departmentid = pc.coreid
         inner join sysuser u on u.sysuserid = ds.sysuserid
         inner join jobtype ujt on ujt.jobtypeid = u.lastjobtype
 where not exists (
    select *
      from sysuserjobtype sjt
        join jobtype pjt on pjt.jobtypeid = sjt.jobtypeid
     where sjt.sysuserid = pr.u_pi
       and pjt.u_jobtypeclass = 'PI'
    )
   and (
         (ujt.u_jobtypeclass = 'EXTERNAL_FACILITY_USER' AND u.sysuserid = pr.u_pi)
      or (ujt.u_jobtypeclass IN ('SYSTEM_ADMIN','FINANCIAL_ADMIN','CORE_DIRECTOR','CORE_MANAGER','CORE_STAFF'))
      or (ujt.u_jobtypeclass = 'PI_DELEGATE' and pr.u_pi in (select pi from u_pisubmitter ps where ps.submitter = u.sysuserid and nvl(ps.proxytopiflag, 'N') = 'Y'))
      or (ujt.u_jobtypeclass in ('FACILITY_USER', 'EXTERNAL_FACILITY_USER') and pr.u_pi in (select p.u_pi from s_project p, s_projectmember pm where p.s_projectid = pm.s_projectid and pm.sysuserid = u.sysuserid))
      or (ujt.u_jobtypeclass = 'FINANCIAL_MANAGER' AND exists (select 1 from u_fundsource fs where u.sysuserid in (fs.fm1, fs.fm2) and pr.u_pi in (fs.respperson1, fs.respperson2)))
  );
