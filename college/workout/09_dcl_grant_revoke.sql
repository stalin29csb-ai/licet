-- 09 DCL: GRANT and REVOKE proven by logging in as the restricted users.
-- Runs as COLLEGE, then CONNECTs as college_student, SYSTEM and college_faculty by itself.
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
COLUMN grantee FORMAT A24
COLUMN table_name FORMAT A26
COLUMN privilege FORMAT A10
COLUMN granted_role FORMAT A24

PROMPT ===== STEP 1: login as the STUDENT user and try the TABLE and the VIEW =====
CONNECT college_student/student123@//localhost:1521/FREEPDB1
SHOW USER
PROMPT expect ORA-00942 (the student role has no right on the table):
SELECT * FROM college.marks FETCH FIRST 3 ROWS ONLY;
PROMPT allowed (the student role may read the view):
SELECT student_name, subject_code, final_mark FROM college.student_result_view WHERE student_id = 101;

PROMPT ===== STEP 2: SYSTEM grants SELECT on MARKS to the student role =====
CONNECT system/oracle123@//localhost:1521/FREEPDB1
SHOW USER
GRANT SELECT ON college.marks TO college_student_role;
SELECT grantee, table_name, privilege FROM dba_tab_privs WHERE owner = 'COLLEGE' AND grantee = 'COLLEGE_STUDENT_ROLE' ORDER BY table_name;

PROMPT ===== STEP 3: the student now CAN read the table =====
CONNECT college_student/student123@//localhost:1521/FREEPDB1
SELECT raw_marks FROM college.marks WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;

PROMPT ===== STEP 4: SYSTEM revokes it again =====
CONNECT system/oracle123@//localhost:1521/FREEPDB1
REVOKE SELECT ON college.marks FROM college_student_role;
SELECT grantee, table_name, privilege FROM dba_tab_privs WHERE owner = 'COLLEGE' AND grantee = 'COLLEGE_STUDENT_ROLE' ORDER BY table_name;

PROMPT ===== STEP 5: the student is locked out of the table again (expect ORA-00942) =====
CONNECT college_student/student123@//localhost:1521/FREEPDB1
SELECT raw_marks FROM college.marks WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;

PROMPT ===== STEP 6: the FACULTY role: can update marks, cannot delete students, UPDATE on attendance was revoked =====
CONNECT college_faculty/faculty123@//localhost:1521/FREEPDB1
SHOW USER
UPDATE college.marks SET raw_marks = raw_marks WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;
ROLLBACK;
PROMPT expect ORA-01031 insufficient privileges:
DELETE FROM college.student WHERE student_id = 101;
PROMPT expect ORA-01031 (UPDATE on attendance_record was REVOKED):
UPDATE college.attendance_record SET status = 'PRESENT' WHERE record_id = 1;

PROMPT ===== STEP 7: roles and their members, seen by SYSTEM =====
CONNECT system/oracle123@//localhost:1521/FREEPDB1
SELECT grantee, granted_role FROM dba_role_privs WHERE grantee IN ('COLLEGE_FACULTY','COLLEGE_STUDENT') ORDER BY grantee;
SELECT grantee, table_name, privilege FROM dba_tab_privs WHERE owner = 'COLLEGE' AND grantee IN ('COLLEGE_FACULTY_ROLE','COLLEGE_STUDENT_ROLE') ORDER BY grantee, table_name, privilege;
EXIT
