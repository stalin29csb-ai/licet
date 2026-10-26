-- 08 VIEWS and INDEXES
SET ECHO ON LINESIZE 180 PAGESIZE 60 FEEDBACK ON DEFINE OFF
SET LONG 4000
COLUMN view_name FORMAT A28
COLUMN index_name FORMAT A26
COLUMN table_name FORMAT A22
COLUMN student_name FORMAT A18
COLUMN subject_name FORMAT A32
COLUMN plan_table_output FORMAT A110

PROMPT ===== VIEWS: saved queries that behave like tables =====
SELECT view_name FROM user_views ORDER BY view_name;
PROMPT ===== the join is hidden inside the view =====
SELECT text FROM user_views WHERE view_name = 'STUDENT_RESULT_VIEW';
PROMPT ===== what the Results page reads =====
SELECT student_name, subject_code, final_mark, grade_code, pass_fail FROM student_result_view WHERE student_id = 101 ORDER BY subject_code;
PROMPT ===== a view that calls stored functions =====
SELECT student_id, student_name, dept_code, cgpa, overall_attendance_pct FROM student_cgpa_view WHERE student_id BETWEEN 101 AND 110 ORDER BY student_id;
PROMPT ===== a view with GROUP BY: attendance per subject for Divya =====
SELECT subject_code, total_sessions, present_sessions, attendance_pct FROM student_attendance_view WHERE student_id = 104 ORDER BY subject_code;

PROMPT ===== INDEXES: PK and UNIQUE create one automatically, plus the extra ones we made =====
SELECT index_name, table_name, uniqueness FROM user_indexes WHERE table_name IN ('STUDENT','ATTENDANCE_RECORD','AUDIT_LOG') ORDER BY table_name, index_name;

PROMPT ===== WITHOUT index: force a full table scan =====
EXPLAIN PLAN FOR SELECT /*+ FULL(ar) */ COUNT(*) FROM attendance_record ar WHERE ar.student_id = 104;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST'));

PROMPT ===== WITH index: IDX_ATTREC_STUDENT =====
EXPLAIN PLAN FOR SELECT /*+ INDEX(ar idx_attrec_student) */ COUNT(*) FROM attendance_record ar WHERE ar.student_id = 104;
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST'));

PROMPT ===== the optimizer choosing for itself on the name search =====
EXPLAIN PLAN FOR SELECT * FROM student WHERE student_name = 'Rahul';
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST'));

PROMPT ===== a function on the column stops the index (UPPER(student_name)) =====
EXPLAIN PLAN FOR SELECT * FROM student WHERE UPPER(student_name) = 'RAHUL';
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +COST'));
EXIT
