-- 02 CONSTRAINTS: every kind, each one shown being VIOLATED so Oracle's error is on screen
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
COLUMN constraint_name FORMAT A24
COLUMN table_name FORMAT A22
COLUMN search_condition_vc FORMAT A70

PROMPT ===== PRIMARY KEY: where they are =====
SELECT constraint_name, table_name FROM user_constraints WHERE constraint_type = 'P' AND table_name IN ('STUDENT','DEPARTMENT','MARKS','RESULT') ORDER BY table_name;
PROMPT ===== PRIMARY KEY violated: department 1 already exists  (expect ORA-00001 PK_DEPARTMENT) =====
INSERT INTO department (dept_id, dept_code, dept_name) VALUES (1, 'XXX', 'Duplicate key');

PROMPT ===== UNIQUE violated: department code CSE used twice  (expect ORA-00001 UQ_DEPT_CODE) =====
INSERT INTO department (dept_id, dept_code, dept_name) VALUES (50, 'CSE', 'Another CSE');
PROMPT ===== UNIQUE violated: student e-mail reused  (expect ORA-00001 UQ_STUDENT_EMAIL) =====
INSERT INTO student (student_id, student_name, email, dept_id, class_id) VALUES (900, 'Dup Mail', 'rahul@college.edu', 1, 1);
PROMPT ===== UNIQUE (composite) violated: payroll twice for one employee and month  (expect ORA-00001 UQ_PAYROLL_MONTH) =====
INSERT INTO payroll (payroll_id, emp_id, pay_month, basic, hra, da, pf, gross, net) VALUES (9998, 1001, '2026-09', 80000, 16000, 8000, 9600, 104000, 94400);

PROMPT ===== NOT NULL violated: department without a name  (expect ORA-01400) =====
INSERT INTO department (dept_id, dept_code) VALUES (51, 'ZZ');

PROMPT ===== FOREIGN KEY violated: student in department 999  (expect ORA-02291 FK_STUDENT_DEPT) =====
INSERT INTO student (student_id, student_name, email, dept_id, class_id) VALUES (900, 'No Dept', 'nodept@college.edu', 999, 1);

PROMPT ===== CHECK: the rules stored in the database =====
SELECT constraint_name, search_condition_vc FROM user_constraints WHERE constraint_type = 'C' AND constraint_name LIKE 'CHK%' ORDER BY 1;
PROMPT ===== CHECK violated: e-mail without @  (expect ORA-02290 CHK_STUDENT_EMAIL) =====
INSERT INTO student (student_id, student_name, email, dept_id, class_id) VALUES (901, 'Bad Mail', 'not-an-email', 1, 1);
PROMPT ===== CHECK violated: net salary is not gross minus PF  (expect ORA-02290 CHK_PAYROLL_NET) =====
INSERT INTO payroll (payroll_id, emp_id, pay_month, basic, hra, da, pf, gross, net) VALUES (9999, 1001, '2027-01', 100, 10, 5, 12, 115, 100);
PROMPT ===== CHECK violated: negative mark  (expect ORA-02290 CHK_MARKS_NONNEG) =====
UPDATE marks SET raw_marks = -1 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;

PROMPT ===== REFERENTIAL INTEGRITY: cannot delete a department that has students  (expect ORA-02292) =====
DELETE FROM department WHERE dept_id = 1;

PROMPT ===== ON DELETE CASCADE: deleting a session deletes its attendance records =====
SELECT COUNT(*) AS records_of_session_1 FROM attendance_record WHERE session_id = 1;
DELETE FROM attendance_session WHERE session_id = 1;
SELECT COUNT(*) AS records_after_delete FROM attendance_record WHERE session_id = 1;
ROLLBACK;
SELECT COUNT(*) AS records_after_rollback FROM attendance_record WHERE session_id = 1;
EXIT
