import { useEffect, useMemo, useState } from "react";
import { Activity, ArrowUpRight, BookOpen, CalendarCheck, GraduationCap, LayoutDashboard, LogOut, Search, ShieldCheck, Users, XENIcon, ChevronDown, CircleHelp, Bell, Menu, School as SchoolIcon, LockKeyhole, AlertCircle, Loader2, RefreshCw } from "lucide-react";
import { supabase, supabaseConfigured, loadSchoolWorkspace, type School, type Student, type SchoolClass, type Attendance } from "./lib/supabase";

type Tab = "overview" | "students" | "classes" | "attendance" | "settings";
const nav = [
  { id: "overview" as Tab, label: "Overview", icon: LayoutDashboard },
  { id: "students" as Tab, label: "Students", icon: Users },
  { id: "classes" as Tab, label: "Classes", icon: BookOpen },
  { id: "attendance" as Tab, label: "Attendance", icon: CalendarCheck },
  { id: "settings" as Tab, label: "School setup", icon: SchoolIcon }
];
const initials = (name: string) => name.split(" ").map(part => part[0]).join("").slice(0, 2).toUpperCase();
const dateLabel = (value?: string | null) => value ? new Date(value).toLocaleDateString(undefined, { day: "numeric", month: "short", year: "numeric" }) : "—";

export default function App() {
  const [session, setSession] = useState<any>(null);
  const [authLoading, setAuthLoading] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [authError, setAuthError] = useState("");
  const [authMessage, setAuthMessage] = useState("");
  const [tab, setTab] = useState<Tab>("overview");
  const [schools, setSchools] = useState<School[]>([]);
  const [schoolId, setSchoolId] = useState("");
  const [schoolData, setSchoolData] = useState<{students:Student[];classes:SchoolClass[];attendance:Attendance[]}|null>(null);
  const [loadingData, setLoadingData] = useState(false);
  const [dataError, setDataError] = useState("");
  const [search, setSearch] = useState("");
  const [mobileMenu, setMobileMenu] = useState(false);

  useEffect(() => {
    if (!supabase) { setAuthLoading(false); return; }
    supabase.auth.getSession().then(({ data }) => { setSession(data.session); setAuthLoading(false); });
    const { data: listener } = supabase.auth.onAuthStateChange((_event, next) => setSession(next));
    return () => listener.subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (!session || !supabase) { setSchools([]); setSchoolId(""); return; }
    let active = true;
    supabase.from("schools").select("id,slug,legal_name,display_name,country_code,default_currency,timezone,status").order("display_name")
      .then(({ data, error }) => {
        if (!active) return;
        if (error) { setDataError(error.message); return; }
        const list = (data || []) as School[];
        setSchools(list);
        setSchoolId(current => current || list[0]?.id || "");
      });
    return () => { active = false; };
  }, [session]);

  useEffect(() => {
    if (!schoolId) { setSchoolData(null); return; }
    let active = true;
    setLoadingData(true); setDataError("");
    loadSchoolWorkspace(schoolId).then(data => { if (active) setSchoolData(data); })
      .catch(error => { if (active) setDataError(error.message || "Unable to load school workspace."); })
      .finally(() => { if (active) setLoadingData(false); });
    return () => { active = false; };
  }, [schoolId]);

  const school = schools.find(item => item.id === schoolId);
  const students = schoolData?.students ?? [];
  const classes = schoolData?.classes ?? [];
  const attendance = schoolData?.attendance ?? [];
  const present = attendance.filter(item => item.status === "present" || item.status === "late").length;
  const attendanceRate = attendance.length ? Math.round(present / attendance.length * 100) : null;
  const filteredStudents = useMemo(() => students.filter(s => `${s.student_number} ${s.legal_first_name} ${s.legal_last_name} ${s.preferred_name || ""}`.toLowerCase().includes(search.toLowerCase())), [students, search]);
  const filteredClasses = useMemo(() => classes.filter(c => `${c.code} ${c.name}`.toLowerCase().includes(search.toLowerCase())), [classes, search]);

  async function signIn(event: React.FormEvent) {
    event.preventDefault(); setAuthError(""); setAuthMessage("");
    if (!supabase) return;
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) setAuthError(error.message);
  }
  async function signUp(event: React.FormEvent) {
    event.preventDefault(); setAuthError(""); setAuthMessage("");
    if (!supabase) return;
    const { error } = await supabase.auth.signUp({ email, password });
    if (error) setAuthError(error.message); else setAuthMessage("Account created. Check your email to confirm, then sign in.");
  }
  async function signOut() { await supabase?.auth.signOut(); setSession(null); setSchoolData(null); }
  async function refresh() { if (schoolId) { setLoadingData(true); try { setSchoolData(await loadSchoolWorkspace(schoolId)); setDataError(""); } catch(e:any) { setDataError(e.message); } finally { setLoadingData(false); } } }

  if (!supabaseConfigured) return <SetupScreen />;
  if (authLoading) return <div className="loading-screen"><Loader2 className="spin" size={24}/> Loading secure session…</div>;
  if (!session) return <LoginScreen email={email} password={password} setEmail={setEmail} setPassword={setPassword} signIn={signIn} signUp={signUp} authError={authError} authMessage={authMessage}/>;

  return <div className="shell">
    <aside className={mobileMenu ? "sidebar open" : "sidebar"}>
      <div className="brand"><div className="brand-mark"><GraduationCap size={22}/></div><div><strong>XEN</strong><span>SCHOOL MANAGEMENT</span></div></div>
      <div className="workspace-label">WORKSPACE</div>
      <button className="school-picker" onClick={() => setTab("settings")}><div className="school-avatar">{school ? initials(school.display_name) : "XS"}</div><div className="school-name"><strong>{school?.display_name || "Select a school"}</strong><small>{school?.status || "No school assigned"}</small></div><ChevronDown size={15}/></button>
      <div className="nav-label">SCHOOL</div>
      <nav>{nav.map(item => { const Icon=item.icon; return <button key={item.id} className={tab===item.id?"nav-item active":"nav-item"} onClick={()=>{setTab(item.id);setMobileMenu(false);}}><Icon size={18}/><span>{item.label}</span>{item.id==="students"&&<span className="nav-count">{students.length}</span>}</button>; })}</nav>
      <div className="sidebar-bottom"><div className="secure-note"><ShieldCheck size={17}/><span>Protected by tenant access controls</span></div><button className="nav-item"><CircleHelp size={18}/><span>Help & support</span></button><div className="profile"><div className="avatar">{initials(session.user.email||"X")}</div><div className="profile-info"><strong>{session.user.email}</strong><small>Signed in</small></div><button className="icon-button" title="Sign out" onClick={signOut}><LogOut size={17}/></button></div></div>
    </aside>
    <main className="main">
      <header className="topbar"><button className="icon-button menu-button" onClick={()=>setMobileMenu(!mobileMenu)}><Menu size={20}/></button><div className="crumb"><span>Workspace</span><span className="slash">/</span><strong>{nav.find(n=>n.id===tab)?.label}</strong></div><div className="top-actions"><div className="env-pill"><span/>Live connection</div><button className="icon-button" title="Notifications"><Bell size={18}/></button></div></header>
      <div className="page">
        <div className="page-heading"><div><div className="eyebrow">SCHOOL ADMINISTRATION</div><h1>{tab==="overview"?"Good day.":nav.find(n=>n.id===tab)?.label}</h1><p>{tab==="overview"?"Here’s what’s happening in your school today.":tab==="students"?"Manage learner records and enrolment information.":tab==="classes"?"View your classes and capacity.":tab==="attendance"?"Monitor attendance records and trends.":"Manage school profile and workspace settings."}</p></div><div className="heading-actions"><button className="btn-secondary" onClick={refresh}><RefreshCw size={15}/> Refresh</button><span className="date-chip">{new Date().toLocaleDateString(undefined,{weekday:"short",day:"numeric",month:"short"})}</span></div></div>
        {!school && <div className="notice"><AlertCircle size={18}/><div><strong>No school workspace found</strong><p>Your account is authenticated, but it is not yet linked to a school. School creation and membership setup will be enabled after secure onboarding policies are deployed.</p></div></div>}
        {dataError && <div className="notice error"><AlertCircle size={18}/><div><strong>Workspace data could not load</strong><p>{dataError}</p></div></div>}
        {loadingData && <div className="loading-inline"><Loader2 size={18} className="spin"/> Syncing school records…</div>}
        {tab==="overview"&&<Overview school={school} students={students} classes={classes} attendance={attendance} rate={attendanceRate} loading={loadingData}/>}
        {tab==="students"&&<Students students={filteredStudents} search={search} setSearch={setSearch}/>}
        {tab==="classes"&&<Classes classes={filteredClasses} search={search} setSearch={setSearch}/>}
        {tab==="attendance"&&<AttendanceView records={attendance}/>}
        {tab==="settings"&&<SchoolSettings school={school}/>}
      </div>
    </main>
    {mobileMenu&&<button className="mobile-scrim" aria-label="Close navigation" onClick={()=>setMobileMenu(false)}/>}
  </div>;
}

function SetupScreen(){return <div className="setup-screen"><div className="login-card"><Brand/><div className="login-heading"><h1>Configure your workspace</h1><p>Set the Supabase project connection to begin.</p></div><div className="notice"><AlertCircle size={18}/><div><strong>Environment variables are missing</strong><p>Create <code>apps/web/.env</code> from <code>.env.example</code> and set your Supabase URL and publishable key. Never add a service-role key to this app.</p></div></div><div className="setup-steps"><p><b>1.</b> Copy the example env file.</p><p><b>2.</b> Add the Supabase project URL.</p><p><b>3.</b> Add the publishable key.</p><p><b>4.</b> Restart the dev server.</p></div></div></div>}
function Brand(){return <div className="brand login-brand"><div className="brand-mark"><GraduationCap size={22}/></div><div><strong>XEN</strong><span>SCHOOL MANAGEMENT</span></div></div>}
function LoginScreen({email,password,setEmail,setPassword,signIn,signUp,authError,authMessage}:any){return <div className="login-screen"><div className="login-card"><Brand/><div className="login-heading"><div className="eyebrow">YOUR SCHOOL, CONNECTED</div><h1>Welcome back</h1><p>Sign in to your school workspace.</p></div><form onSubmit={signIn} className="login-form"><label>Email address<input type="email" autoComplete="email" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="name@school.org"/></label><label>Password<input type="password" autoComplete="current-password" minLength={6} required value={password} onChange={e=>setPassword(e.target.value)} placeholder="Enter your password"/></label><button className="btn-primary full" type="submit">Sign in <ArrowUpRight size={16}/></button><button className="btn-secondary full" type="button" onClick={signUp}>Create account</button></form>{authError&&<div className="auth-error">{authError}</div>}{authMessage&&<div className="auth-success">{authMessage}</div>}<div className="login-foot"><LockKeyhole size={14}/> Secure authentication by Supabase</div></div><div className="login-aside"><div className="aside-glow"/><div className="aside-content"><div className="aside-tag">XEN TECHNOLOGIES · EDUCATION</div><h2>One connected<br/><span>school ecosystem.</span></h2><p>From attendance to academic progress, bring your school operations together in one secure workspace.</p><div className="aside-feature"><span><Users size={18}/></span> Learner information & records</div><div className="aside-feature"><span><CalendarCheck size={18}/></span> Attendance & daily operations</div><div className="aside-feature"><span><BookOpen size={18}/></span> Classes & academic structure</div></div><div className="aside-footer">Built for schools in Zimbabwe and beyond.</div></div></div>}
function Overview({school,students,classes,attendance,rate,loading}:any){return <><div className="welcome-card"><div className="welcome-copy"><div className="welcome-tag"><span/> SCHOOL WORKSPACE</div><h2>{school?.display_name||"Welcome to XEN School"}</h2><p>{school? "Your school workspace overview. Use the sidebar to navigate administration modules.":"Your school workspace is ready to be provisioned."}</p></div><div className="welcome-art"><div className="art-circle"><GraduationCap size={54}/></div><div className="art-orbit orbit-one"/><div className="art-orbit orbit-two"/></div></div><div className="metrics-grid"><Metric icon={Users} label="Learners" value={students.length} detail="Visible in your school" color="blue"/><Metric icon={BookOpen} label="Classes" value={classes.length} detail="Active class records" color="violet"/><Metric icon={CalendarCheck} label="Attendance records" value={attendance.length} detail="Recent records loaded" color="green"/><Metric icon={Activity} label="Attendance trend" value={rate===null?"—":rate+"%"} detail="Based on loaded records" color="amber"/></div><div className="content-grid"><div className="panel"><div className="panel-head"><div><h3>Recent learners</h3><p>Latest learner records in your workspace</p></div><button className="text-link" onClick={()=>window.dispatchEvent(new CustomEvent("xen-tab",{detail:"students"}))}>View all <ArrowUpRight size={14}/></button></div>{loading?<EmptyState message="Loading records…"/>:students.length?<StudentTable students={students.slice(0,5)}/>:<EmptyState message="Learner records will appear here once registered."/>}</div><div className="panel"><div className="panel-head"><div><h3>Quick overview</h3><p>Workspace status</p></div></div><div className="overview-list"><OverviewRow label="School status" value={school?.status||"Not assigned"} status={school?.status==="active"}/><OverviewRow label="Country" value={school?.country_code||"—"}/><OverviewRow label="Currency" value={school?.default_currency||"—"}/><OverviewRow label="Timezone" value={school?.timezone||"—"}/></div><div className="panel-note"><ShieldCheck size={16}/> School data is filtered by your authenticated access.</div></div></div><div className="bottom-note"><span className="status-dot"/> Connected to the XEN school platform <span>·</span> Data is protected by row-level security</div></>}
function Metric({icon:Icon,label,value,detail,color}:any){return <div className="metric-card"><div className={"metric-icon "+color}><Icon size={18}/></div><div className="metric-label">{label}</div><div className="metric-value">{value}</div><div className="metric-detail">{detail}</div></div>}
function OverviewRow({label,value,status}:any){return <div className="overview-row"><span>{label}</span><strong>{status&&<i className="status-dot"/>}{value}</strong></div>}
function Students({students,search,setSearch}:any){return <div className="panel full-panel"><div className="panel-head"><div><h3>Learner directory</h3><p>{students.length} matching learners</p></div><div className="searchbox"><Search size={16}/><input placeholder="Search name or student number" value={search} onChange={e=>setSearch(e.target.value)}/>{search&&<button onClick={()=>setSearch("")}><X size={14}/></button>}</div></div>{students.length?<StudentTable students={students}/>:<EmptyState message="No learners found. Additions will be enabled after database write permissions and admission workflow are secured."/>}</div>}
function StudentTable({students}:any){return <div className="table-wrap"><table><thead><tr><th>LEARNER</th><th>STUDENT NUMBER</th><th>STATUS</th><th>ADMISSION</th></tr></thead><tbody>{students.map((s:Student)=><tr key={s.id}><td><div className="person-cell"><div className="avatar soft">{initials(s.legal_first_name+" "+s.legal_last_name)}</div><div><strong>{s.preferred_name||s.legal_first_name} {s.legal_last_name}</strong><small>{s.legal_first_name} {s.legal_last_name}</small></div></div></td><td><span className="mono">{s.student_number}</span></td><td><span className={"badge "+s.status}>{s.status}</span></td><td>{dateLabel(s.admission_date)}</td></tr>)}</tbody></table></div>}
function Classes({classes,search,setSearch}:any){return <div className="panel full-panel"><div className="panel-head"><div><h3>Classes</h3><p>{classes.length} matching class records</p></div><div className="searchbox"><Search size={16}/><input placeholder="Search class or code" value={search} onChange={e=>setSearch(e.target.value}/></div></div>{classes.length?<div className="class-grid">{classes.map((c:SchoolClass)=><div className="class-card" key={c.id}><div className="class-top"><div className="class-icon"><BookOpen size={18}/></div><span className={"badge "+c.status}>{c.status}</span></div><h4>{c.name}</h4><span className="mono">{c.code}</span><div className="class-bottom"><span>Capacity</span><strong>{c.capacity??"Not set"}</strong></div></div>)}</div>:<EmptyState message="Class records will appear here after the school structure is configured."/>}</div>}
function AttendanceView({records}:any){return <div className="panel full-panel"><div className="panel-head"><div><h3>Recent attendance</h3><p>Most recent attendance records visible to your account</p></div></div>{records.length?<div className="table-wrap"><table><thead><tr><th>STATUS</th><th>MINUTES LATE</th><th>RECORDED</th></tr></thead><tbody>{records.map((r:Attendance)=><tr key={r.id}><td><span className={"badge "+r.status}>{r.status}</span></td><td>{r.minutes_late||0}</td><td>{dateLabel(r.recorded_at)}</td></tr>)}</tbody></table></div>:<EmptyState message="Attendance data will show once daily attendance sessions and records are created."/>}</div>}
function SchoolSettings({school}:any){return <div className="panel full-panel"><div className="panel-head"><div><h3>School profile</h3><p>Basic workspace configuration</p></div></div>{school?<div className="settings-grid">{[[ "Display name",school.display_name],["Legal name",school.legal_name],["School slug",school.slug],["Country",school.country_code],["Currency",school.default_currency],["Timezone",school.timezone],["Status",school.status]].map(([label,value]:any)=><div className="setting-row" key={label}><span>{label}</span><strong>{value||"—"}</strong></div>)}</div>:<EmptyState message="School profile setup becomes available once a school is linked to your account."/>}</div>}
function EmptyState({message}:any){return <div className="empty-state"><div className="empty-icon"><BookOpen size={20}/></div><p>{message}</p></div>}
