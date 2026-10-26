-- 07 CURSORS and EXCEPTIONS
SET ECHO ON LINESIZE 180 PAGESIZE 40 FEEDBACK ON DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT ===== IMPLICIT cursor: SQL%FOUND, SQL%NOTFOUND, SQL%ROWCOUNT after each DML =====
BEGIN
  UPDATE student SET phone = phone WHERE dept_id = 99;
  DBMS_OUTPUT.PUT_LINE('dept 99 : FOUND=' || CASE WHEN SQL%FOUND THEN 'TRUE' ELSE 'FALSE' END || ' ROWCOUNT=' || SQL%ROWCOUNT);
  UPDATE student SET phone = phone WHERE class_id = 1;
  DBMS_OUTPUT.PUT_LINE('class 1  : FOUND=' || CASE WHEN SQL%FOUND THEN 'TRUE' ELSE 'FALSE' END || ' ROWCOUNT=' || SQL%ROWCOUNT);
  ROLLBACK;
END;
/

PROMPT ===== EXPLICIT cursor: DECLARE, OPEN, FETCH in a loop, EXIT WHEN %NOTFOUND, CLOSE =====
DECLARE
  CURSOR c_students IS
    SELECT student_id, student_name, calculate_cgpa(student_id) AS cgpa
      FROM student WHERE student_id BETWEEN 101 AND 110 ORDER BY student_id;
  v_row c_students%ROWTYPE;
BEGIN
  OPEN c_students;
  LOOP
    FETCH c_students INTO v_row;
    EXIT WHEN c_students%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(c_students%ROWCOUNT || '. ' || RPAD(v_row.student_name, 10) || ' CGPA ' || NVL(TO_CHAR(v_row.cgpa), '-'));
  END LOOP;
  CLOSE c_students;
END;
/

PROMPT ===== EXPLICIT cursor with a parameter: the project's department report (procedure department_report_text) =====
DECLARE
  v_report VARCHAR2(4000);
BEGIN
  department_report_text(4, v_report);
  DBMS_OUTPUT.PUT_LINE(SUBSTR(v_report, 1, 600) || ' ...');
END;
/

PROMPT ===== CURSOR FOR loop: Oracle opens, fetches and closes for you =====
BEGIN
  FOR r IN (SELECT dept_code, dept_name FROM department ORDER BY dept_id) LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(r.dept_code, 6) || r.dept_name);
  END LOOP;
END;
/

PROMPT ===== PREDEFINED exceptions, NON-PREDEFINED (PRAGMA EXCEPTION_INIT) and USER-DEFINED via the project's demo_exception =====
DECLARE
  v_msg VARCHAR2(1000);
BEGIN
  FOR c IN (SELECT column_value AS case_name FROM TABLE(SYS.ODCIVARCHAR2LIST('NO_DATA_FOUND','TOO_MANY_ROWS','DUP_VAL_ON_INDEX','CHILD_RECORD_FOUND','PARENT_NOT_FOUND','USER_DEFINED'))) LOOP
    demo_exception(c.case_name, v_msg);
    DBMS_OUTPUT.PUT_LINE(RPAD(c.case_name, 20) || ' -> ' || v_msg);
  END LOOP;
  ROLLBACK;
END;
/

PROMPT ===== YOUR OWN exception, typed live: raise a named exception when attendance is below 75 =====
DECLARE
  e_low_attendance EXCEPTION;
  v_pct NUMBER;
BEGIN
  v_pct := calculate_attendance(104);
  IF v_pct < 75 THEN
    RAISE e_low_attendance;
  END IF;
  DBMS_OUTPUT.PUT_LINE('attendance fine: ' || v_pct);
EXCEPTION
  WHEN e_low_attendance THEN
    DBMS_OUTPUT.PUT_LINE('Student 104 is below 75 percent: ' || v_pct);
END;
/

PROMPT ===== NO_DATA_FOUND typed live =====
DECLARE
  v_name student.student_name%TYPE;
BEGIN
  SELECT student_name INTO v_name FROM student WHERE student_id = 999999;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Handled: no student with id 999999');
END;
/
EXIT
