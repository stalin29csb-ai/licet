-- 03 QUERIES: WHERE, functions, aggregates, GROUP BY, HAVING, set operations, joins, subqueries
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
COLUMN student_name FORMAT A22
COLUMN subject_name FORMAT A30
COLUMN dept_code FORMAT A6

PROMPT ===== WHERE with LIKE, BETWEEN, IN, AND/OR =====
SELECT student_id, student_name FROM student WHERE dept_id = 1 AND student_name LIKE 'R%' AND student_id < 200;
SELECT subject_code, credits FROM subject WHERE credits IN (3, 4) AND semester BETWEEN 2 AND 3 AND dept_id = 1 ORDER BY subject_code;

PROMPT ===== SINGLE-ROW FUNCTIONS, CASE, NVL =====
SELECT UPPER(student_name) AS up, LENGTH(student_name) AS len, SUBSTR(email, 1, INSTR(email, '@') - 1) AS login_part FROM student WHERE student_id = 101;
SELECT student_id, final_mark, CASE WHEN final_mark >= 50 THEN 'PASS' ELSE 'FAIL' END AS verdict, NVL(grade_code, 'NA') AS grade FROM result WHERE subject_id = 2 ORDER BY final_mark DESC;

PROMPT ===== AGGREGATES: COUNT, AVG, MIN, MAX, SUM =====
SELECT COUNT(*) AS results, ROUND(AVG(final_mark), 2) AS average, MIN(final_mark) AS lowest, MAX(final_mark) AS highest, SUM(credits) AS credits FROM result;
SELECT SUM(net) AS total_net_payroll FROM payroll WHERE pay_month = '2026-09';

PROMPT ===== GROUP BY: students per department, average mark per subject =====
SELECT d.dept_code, COUNT(s.student_id) AS students FROM department d LEFT JOIN student s ON s.dept_id = d.dept_id GROUP BY d.dept_code ORDER BY d.dept_code;
SELECT sb.subject_code, COUNT(*) AS students, ROUND(AVG(r.final_mark), 2) AS average FROM result r JOIN subject sb ON sb.subject_id = r.subject_id GROUP BY sb.subject_code ORDER BY sb.subject_code;

PROMPT ===== HAVING: students with attendance below 75 percent (filters GROUPS, WHERE filters ROWS) =====
SELECT student_id, ROUND(100 * SUM(CASE WHEN status = 'PRESENT' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct
  FROM attendance_record GROUP BY student_id
HAVING 100 * SUM(CASE WHEN status = 'PRESENT' THEN 1 ELSE 0 END) / COUNT(*) < 75
 ORDER BY pct FETCH FIRST 5 ROWS ONLY;

PROMPT ===== SET OPERATIONS (class CSE-III-A): UNION, INTERSECT, MINUS =====
SELECT student_id FROM result WHERE pass_fail = 'FAIL'
UNION
SELECT student_id FROM student WHERE class_id = 1 AND calculate_attendance(student_id) < 75;
SELECT student_id FROM result WHERE pass_fail = 'FAIL'
INTERSECT
SELECT student_id FROM student WHERE class_id = 1 AND calculate_attendance(student_id) < 75;
SELECT student_id FROM student WHERE student_id BETWEEN 101 AND 110
MINUS
SELECT student_id FROM result WHERE pass_fail = 'FAIL';

PROMPT ===== JOINS: INNER =====
SELECT s.student_id, s.student_name, d.dept_code FROM student s INNER JOIN department d ON d.dept_id = s.dept_id WHERE s.student_id BETWEEN 101 AND 105 ORDER BY s.student_id;
PROMPT ===== JOINS: LEFT (departments even without a head of department) =====
SELECT d.dept_code, f.faculty_name AS hod FROM department d LEFT JOIN faculty f ON f.faculty_id = d.hod_faculty_id ORDER BY d.dept_code;
PROMPT ===== JOINS: RIGHT (every subject, even with no results) =====
SELECT sb.subject_code, COUNT(r.result_id) AS results FROM result r RIGHT JOIN subject sb ON sb.subject_id = r.subject_id WHERE sb.dept_id = 1 GROUP BY sb.subject_code ORDER BY sb.subject_code;
PROMPT ===== JOINS: CROSS (every assessment with every grade = 7 x 6) =====
SELECT COUNT(*) AS combinations FROM assessment CROSS JOIN grade;
PROMPT ===== JOINS: multi-table (student, department, class, subject, assessment, marks) =====
SELECT s.student_name, d.dept_code, c.class_name, sb.subject_code, a.assessment_code, m.raw_marks
  FROM marks m JOIN student s ON s.student_id = m.student_id JOIN department d ON d.dept_id = s.dept_id
  JOIN class c ON c.class_id = s.class_id JOIN subject sb ON sb.subject_id = m.subject_id
  JOIN assessment a ON a.assessment_id = m.assessment_id
 WHERE s.student_id = 101 AND sb.subject_code = 'CS302' ORDER BY a.assessment_id;

PROMPT ===== SUBQUERY: single-row (above the average) =====
SELECT s.student_name, r.final_mark FROM result r JOIN student s ON s.student_id = r.student_id
 WHERE r.subject_id = 2 AND r.final_mark > (SELECT AVG(final_mark) FROM result WHERE subject_id = 2);
PROMPT ===== SUBQUERY: multi-row IN =====
SELECT student_name FROM student WHERE student_id IN (SELECT student_id FROM result WHERE pass_fail = 'FAIL');
PROMPT ===== SUBQUERY: correlated EXISTS (students who were ever absent in class 1, first 5) =====
SELECT s.student_name FROM student s WHERE s.class_id = 1 AND EXISTS (SELECT 1 FROM attendance_record a WHERE a.student_id = s.student_id AND a.status = 'ABSENT') FETCH FIRST 5 ROWS ONLY;
PROMPT ===== SUBQUERY: correlated (mark above the student's own department average) =====
SELECT s.student_name, d.dept_code, sb.subject_code, r.final_mark
  FROM result r JOIN student s ON s.student_id = r.student_id JOIN department d ON d.dept_id = s.dept_id JOIN subject sb ON sb.subject_id = r.subject_id
 WHERE r.final_mark > (SELECT AVG(r2.final_mark) FROM result r2 JOIN student s2 ON s2.student_id = r2.student_id WHERE s2.dept_id = s.dept_id)
 ORDER BY d.dept_code, r.final_mark DESC FETCH FIRST 6 ROWS ONLY;
PROMPT ===== SUBQUERY: inline view (FROM clause) =====
SELECT dept_code, ROUND(avg_mark, 2) AS avg_mark FROM (SELECT d.dept_code, AVG(r.final_mark) AS avg_mark FROM result r JOIN student s ON s.student_id = r.student_id JOIN department d ON d.dept_id = s.dept_id GROUP BY d.dept_code) ORDER BY avg_mark DESC;
PROMPT ===== ANALYTIC FUNCTION: rank in CS302 =====
SELECT s.student_name, r.final_mark, RANK() OVER (ORDER BY r.final_mark DESC) AS rank_in_class FROM result r JOIN student s ON s.student_id = r.student_id WHERE r.subject_id = 2;
EXIT
