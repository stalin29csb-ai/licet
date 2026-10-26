-- 05 TRANSACTIONS: COMMIT, ROLLBACK, SAVEPOINT, implicit commit of DDL (ACID in action)
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
COLUMN assessment_code FORMAT A10

PROMPT ===== BEFORE: Rahul CS302 class tests CT1 = 27 and CT2 = 24 =====
SELECT a.assessment_code, m.raw_marks FROM marks m JOIN assessment a ON a.assessment_id = m.assessment_id WHERE m.student_id = 101 AND m.subject_id = 2 AND a.assessment_code IN ('CT1','CT2') ORDER BY a.assessment_id;

PROMPT ===== ROLLBACK: a mistake is undone =====
UPDATE marks SET raw_marks = 0 WHERE student_id = 101 AND subject_id = 2;
SELECT COUNT(*) AS rows_with_zero FROM marks WHERE student_id = 101 AND subject_id = 2 AND raw_marks = 0;
ROLLBACK;
SELECT COUNT(*) AS rows_with_zero_after_rollback FROM marks WHERE student_id = 101 AND subject_id = 2 AND raw_marks = 0;

PROMPT ===== SAVEPOINT: keep the first change, undo the second =====
UPDATE marks SET raw_marks = 28 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;
SAVEPOINT after_ct1;
UPDATE marks SET raw_marks = 29 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 5;
SELECT a.assessment_code, m.raw_marks FROM marks m JOIN assessment a ON a.assessment_id = m.assessment_id WHERE m.student_id = 101 AND m.subject_id = 2 AND a.assessment_code IN ('CT1','CT2') ORDER BY a.assessment_id;
PROMPT (expected CT1 = 28, CT2 = 29)
ROLLBACK TO SAVEPOINT after_ct1;
SELECT a.assessment_code, m.raw_marks FROM marks m JOIN assessment a ON a.assessment_id = m.assessment_id WHERE m.student_id = 101 AND m.subject_id = 2 AND a.assessment_code IN ('CT1','CT2') ORDER BY a.assessment_id;
PROMPT (expected CT1 = 28 kept, CT2 = 24 undone)
ROLLBACK;
SELECT a.assessment_code, m.raw_marks FROM marks m JOIN assessment a ON a.assessment_id = m.assessment_id WHERE m.student_id = 101 AND m.subject_id = 2 AND a.assessment_code IN ('CT1','CT2') ORDER BY a.assessment_id;
PROMPT (expected both back to the original 27 and 24)

PROMPT ===== COMMIT: permanent, ROLLBACK can no longer undo it =====
INSERT INTO department (dept_id, dept_code, dept_name) VALUES (98, 'TXN', 'Transaction Demo');
COMMIT;
ROLLBACK;
SELECT COUNT(*) AS still_there_after_rollback FROM department WHERE dept_id = 98;

PROMPT ===== DDL COMMITS BY ITSELF: a pending INSERT is saved by CREATE TABLE =====
INSERT INTO department (dept_id, dept_code, dept_name) VALUES (97, 'DDL', 'Implicit commit demo');
CREATE TABLE demo_tmp2 (x NUMBER);
ROLLBACK;
SELECT COUNT(*) AS survived_the_rollback FROM department WHERE dept_id = 97;

PROMPT ===== CLEAN UP =====
DELETE FROM department WHERE dept_id IN (97, 98);
COMMIT;
DROP TABLE demo_tmp2 PURGE;
SELECT COUNT(*) AS demo_departments_left FROM department WHERE dept_id IN (97, 98);

PROMPT ===== ATOMICITY inside PL/SQL: the second statement fails, so the first is undone too =====
BEGIN
  INSERT INTO department (dept_id, dept_code, dept_name) VALUES (96, 'ATM', 'Atomic demo');
  INSERT INTO department (dept_id, dept_code, dept_name) VALUES (96, 'ATM2', 'Duplicate key');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Second insert failed (' || SQLERRM || '), whole unit rolled back');
END;
/
SELECT COUNT(*) AS atomic_rows_left FROM department WHERE dept_id = 96;
EXIT
