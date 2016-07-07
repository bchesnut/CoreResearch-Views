create or replace view v_duke_restrict_project as
select p.s_projectid,
       u.sysuserid
  from s_project p,
       sysuser u
         inner join jobtype jt on jt.jobtypeid = u.lastjobtype
 where (
         (jt.u_jobtypeclass = 'PI' AND u.sysuserid = p.u_pi)
      or (jt.u_jobtypeclass = 'PI_DELEGATE' and p.u_pi in (select pi from u_pisubmitter ps where ps.submitter = u.sysuserid and nvl(ps.proxytopiflag, 'N') = 'Y'))
      or (jt.u_jobtypeclass in ('FACILITY_USER', 'EXTERNAL_FACILITY_USER') and p.s_projectid in (select distinct s_projectid from s_projectmember pm where pm.sysuserid = u.sysuserid))
      or (jt.u_jobtypeclass = 'FINANCIAL_MANAGER' AND exists (select 1 from u_fundsource fs where fs.u_fundsourceid = p.u_fundsourceid and (fs.fm1 = u.sysuserid or fs.fm2 = u.sysuserid)))
      or (jt.u_jobtypeclass IN ('SYSTEM_ADMIN', 'FINANCIAL_ADMIN', 'CORE_DIRECTOR', 'CORE_MANAGER', 'CORE_STAFF'))
    )
    and exists (
      select *
        from u_projectcores pc,
             departmentsysuser dsu
       where pc.s_projectid = p.s_projectid
         and dsu.departmentid = pc.coreid
         and dsu.sysuserid = u.sysuserid
    );
