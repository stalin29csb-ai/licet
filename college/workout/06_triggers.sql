-- 06 TRIGGERS: BEFORE validation, AFTER audit (INSERT, UPDATE, DELETE), compound trigger chain
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
SET LONG 3000
SET SERVEROUTPUT ON SIZE UNLIMITED
COLUMN trigger_name FORMAT A26
COLUMN table_name FORMAT A18
COLUMN trigger_type FORMAT A22
COLUMN triggering_event FORMAT A28
COLUMN record_key FORMAT A28
COLUMN old_value FORMAT A28
COLUMN new_value FORMAT A34
COLUMN title FORMAT A50
COLUMN recipient_type FORMAT A10
COLUMN channel FORMAT A8
COLUMN status FORMAT A8

PROMPT ===== All triggers of the project =====
SELECT trigger_name, trigger_type, triggering_event, table_name, status FROM user_triggers ORDER BY trigger_name;

PROMPT ===== The BEFORE trigger source =====
SELECT trigger_body FROM user_triggers WHERE trigger_name = 'TRG_MARKS_VALIDATE';

PROMPT ===== Audit rows so far (the reset leaves the table empty) =====
SELECT COUNT(*) AS audit_rows FROM audit_log;

PROMPT ===== INSERT trigger: add a student, the audit row appears by itself =====
INSERT INTO student (student_id, student_name, email, dept_id, class_id, joined_year) VALUES (902, 'Demo Student', 'demo902@college.edu', 1, 1, 2026);
SELECT operation, record_key, new_value FROM audit_log WHERE student_id = 902;

PROMPT ===== DELETE trigger: delete him, the OLD values are kept =====
DELETE FROM student WHERE student_id = 902;
SELECT operation, record_key, old_value FROM audit_log WHERE student_id = 902 ORDER BY audit_id;
ROLLBACK;

PROMPT ===== BEFORE UPDATE trigger: CT1 = 99 is above the maximum 30 (expect ORA-20001) =====
UPDATE marks SET raw_marks = 99 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;

PROMPT ===== AFTER UPDATE trigger: CT1 = 26 is allowed and audited with OLD and NEW =====
UPDATE marks SET raw_marks = 26 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;
SELECT operation, record_key, old_value, new_value FROM audit_log WHERE table_name = 'MARKS' ORDER BY audit_id DESC FETCH FIRST 2 ROWS ONLY;
PROMPT ===== the WHEN clause: an update that changes nothing writes nothing =====
UPDATE marks SET raw_marks = 26 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;
SELECT COUNT(*) AS audit_rows_for_marks FROM audit_log WHERE table_name = 'MARKS';
ROLLBACK;

PROMPT ===== COMPOUND TRIGGER chain: marking a student ABSENT queues an SMS for the parent and ONE digest for the advisor =====
SELECT status FROM attendance_record WHERE session_id = 1 AND student_id = 101;
SELECT COUNT(*) AS notifications_for_session_1 FROM notification WHERE session_id = 1;
EXEC mark_attendance(1, 101, 'ABSENT')
SELECT recipient_type, channel, status, title FROM notification WHERE session_id = 1 ORDER BY notif_id;
PROMPT ===== a second absentee in the same period updates the same advisor digest, parents each get their own SMS =====
EXEC mark_attendance(1, 103, 'ABSENT')
SELECT recipient_type, channel, status, title FROM notification WHERE session_id = 1 ORDER BY notif_id;
ROLLBACK;
SELECT COUNT(*) AS notifications_after_rollback FROM notification WHERE session_id = 1;
EXIT
