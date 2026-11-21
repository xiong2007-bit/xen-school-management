import { createClient } from "@supabase/supabase-js";

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY as string | undefined;

export const supabaseConfigured = Boolean(url && key);
export const supabase = supabaseConfigured ? createClient(url!, key!, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
}) : null;

export type School = {
  id: string; slug: string; legal_name: string; display_name: string;
  country_code: string; default_currency: string; timezone: string; status: string;
};
export type Student = {
  id: string; student_number: string; legal_first_name: string; legal_last_name: string;
  preferred_name: string | null; status: string; admission_date: string | null;
};
export type SchoolClass = { id: string; code: string; name: string; capacity: number | null; status: string };
export type Attendance = { id: string; status: string; minutes_late: number; recorded_at: string };

export async function loadSchoolWorkspace(schoolId: string) {
  if (!supabase) throw new Error("Supabase is not configured.");
  const [students, classes, attendance] = await Promise.all([
    supabase.from("students").select("id,student_number,legal_first_name,legal_last_name,preferred_name,status,admission_date").eq("school_id", schoolId).order("legal_last_name").limit(100),
    supabase.from("classes").select("id,code,name,capacity,status").eq("school_id", schoolId).order("name").limit(100),
    supabase.from("attendance_records").select("id,status,minutes_late,recorded_at").eq("school_id", schoolId).order("recorded_at", { ascending: false }).limit(100)
  ]);
  const firstError = students.error || classes.error || attendance.error;
  if (firstError) throw firstError;
  return { students: students.data as Student[], classes: classes.data as SchoolClass[], attendance: attendance.data as Attendance[] };
}
