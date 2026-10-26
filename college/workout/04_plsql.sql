-- 04 PL/SQL: functions, stored procedures, OUT parameters, MERGE, procedure errors
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
COLUMN source_line FORMAT A100

PROMPT ===== FUNCTIONS: one value in, one value out, usable inside SELECT =====
SELECT calculate_internal_mark(101, 2) AS internal_40, calculate_semester_mark(101, 2) AS semester_60 FROM dual;
SELECT calculate_grade(82.6) AS grade, get_grade_point('A+') AS grade_point FROM dual;
SELECT calculate_attendance(101) AS attendance_pct, calculate_attendance(104) AS divya_attendance FROM dual;
SELECT calculate_sgpa(101, 3) AS sgpa_sem3, calculate_cgpa(101) AS cgpa FROM dual;

PROMPT ===== the by-hand check of 33.4 + 49.2 = 82.6 : part1 = 35+(27+48)*2/3, part2 = 32+(24+51)*2/3, internal = (part1+part2)/5 =====
SELECT (35 + (27 + 48) * 2 / 3) AS part1, (32 + (24 + 51) * 2 / 3) AS part2, ((35 + (27 + 48) * 2 / 3) + (32 + (24 + 51) * 2 / 3)) / 5 AS internal FROM dual;

PROMPT ===== the function source lives INSIDE the database =====
SELECT text AS source_line FROM user_source WHERE name = 'CALCULATE_GRADE' AND type = 'FUNCTION' ORDER BY line;

PROMPT ===== PROCEDURE: calculate and store one result (MERGE = insert or update) =====
UPDATE result SET final_mark = 0, grade_code = 'RA', grade_point = 0, pass_fail = 'FAIL' WHERE student_id = 101 AND subject_id = 2;
SELECT final_mark, grade_code, pass_fail FROM result WHERE student_id = 101 AND subject_id = 2;
EXEC calculate_student_result(101, 2)
SELECT internal_mark, semester_mark, final_mark, grade_code, pass_fail FROM result WHERE student_id = 101 AND subject_id = 2;
ROLLBACK;

PROMPT ===== PROCEDURE with OUT parameter: payroll for every employee for December =====
VARIABLE created NUMBER
EXEC generate_payroll_all('2026-12', :created)
PRINT created
SELECT emp_id, basic, hra, da, pf, gross, net FROM payroll WHERE pay_month = '2026-12' ORDER BY emp_id;
PROMPT ===== payroll arithmetic for the Professor: gross = 80000+16000+8000 = 104000, net = 104000-9600 = 94400 =====
SELECT gross, net FROM payroll WHERE pay_month = '2026-12' AND emp_id = 1001;
ROLLBACK;

PROMPT ===== PROCEDURE errors raised with RAISE_APPLICATION_ERROR =====
VARIABLE pid NUMBER
PROMPT expect ORA-20020 (already generated):
EXEC generate_payroll(1001, '2026-09', :pid)
PROMPT expect ORA-20021 (employee not found):
EXEC generate_payroll(424242, '2026-12', :pid)
PROMPT expect ORA-20011 (invalid subject):
EXEC calculate_student_result(101, 999)
PROMPT expect ORA-20010 (CS304 has only the six internal marks, no semester exam):
EXEC calculate_student_result(101, 9)
PROMPT expect ORA-20030 (invalid attendance status):
EXEC mark_attendance(1, 101, 'LATE')

PROMPT ===== PROCEDURE mark_attendance: insert-or-update with MERGE =====
SELECT status FROM attendance_record WHERE session_id = 1 AND student_id = 101;
EXEC mark_attendance(1, 101, 'OD')
SELECT status FROM attendance_record WHERE session_id = 1 AND student_id = 101;
ROLLBACK;
SELECT status FROM attendance_record WHERE session_id = 1 AND student_id = 101;

PROMPT ===== list of stored code objects =====
SELECT object_type, object_name, status FROM user_objects WHERE object_type IN ('FUNCTION','PROCEDURE') ORDER BY object_type, object_name;
EXIT
