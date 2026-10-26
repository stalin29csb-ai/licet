-- 01 SCHEMA TOUR: DDL, DML, sequences, data dictionary, ER (foreign keys), normalization
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
COLUMN table_name FORMAT A24
COLUMN column_name FORMAT A20
COLUMN child FORMAT A20
COLUMN parent FORMAT A20
COLUMN constraint_name FORMAT A24
COLUMN sequence_name FORMAT A22

PROMPT ===== DDL 1: the project's tables (CREATE TABLE in 01_tables.sql) =====
SELECT table_name FROM user_tables ORDER BY table_name;

PROMPT ===== DDL 2: structure of one table =====
DESC student

PROMPT ===== DATA DICTIONARY: how many constraints of each type (P primary, U unique, R foreign, C check) =====
SELECT constraint_type, COUNT(*) AS total FROM user_constraints GROUP BY constraint_type ORDER BY 1;

PROMPT ===== ER DIAGRAM AS A QUERY: every child table and the parent it points to =====
SELECT c.table_name AS child, p.table_name AS parent, c.constraint_name
  FROM user_constraints c JOIN user_constraints p ON p.constraint_name = c.r_constraint_name
 WHERE c.constraint_type = 'R'
 ORDER BY c.table_name, p.table_name;

PROMPT ===== DDL 3: CREATE, ALTER, TRUNCATE, DROP on a throw-away table =====
BEGIN EXECUTE IMMEDIATE 'DROP TABLE demo_tmp PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
CREATE TABLE demo_tmp (id NUMBER PRIMARY KEY, note VARCHAR2(30));
ALTER TABLE demo_tmp ADD (created DATE DEFAULT SYSDATE);
DESC demo_tmp
INSERT INTO demo_tmp (id, note) VALUES (1, 'row one');
SELECT COUNT(*) AS rows_before_truncate FROM demo_tmp;
TRUNCATE TABLE demo_tmp;
SELECT COUNT(*) AS rows_after_truncate FROM demo_tmp;
DROP TABLE demo_tmp PURGE;

PROMPT ===== DML: INSERT, UPDATE, DELETE, then ROLLBACK (nothing is kept) =====
INSERT INTO department (dept_id, dept_code, dept_name) VALUES (99, 'DEMO', 'Demo Department');
UPDATE department SET dept_name = 'Demo Department (edited)' WHERE dept_id = 99;
SELECT dept_id, dept_code, dept_name FROM department WHERE dept_id = 99;
DELETE FROM department WHERE dept_id = 99;
ROLLBACK;

PROMPT ===== SEQUENCE: Java asks the database for the next student id =====
SELECT sequence_name, last_number FROM user_sequences WHERE sequence_name IN ('SEQ_STUDENT','SEQ_PAYROLL') ORDER BY 1;
SELECT seq_payroll.NEXTVAL AS next_payroll_id FROM dual;
SELECT seq_payroll.CURRVAL AS same_number_again FROM dual;

PROMPT ===== NORMALIZATION (3NF): percentages live once in SALARY_RULE, not in every employee row =====
SELECT * FROM salary_rule;
SELECT emp_id, emp_name, designation, basic_salary FROM employee;
PROMPT ===== NORMALIZATION: MARKS keeps only RAW marks, the converted marks are calculated =====
SELECT assessment_code, max_marks FROM assessment ORDER BY assessment_id;
PROMPT ===== CONTROLLED REDUNDANCY: RESULT stores calculated values on purpose (fast reports, history) =====
SELECT student_id, subject_id, internal_mark, semester_mark, final_mark, grade_code FROM result WHERE student_id = 101 AND subject_id = 2;
EXIT
