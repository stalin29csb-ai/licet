# DBMS live demo guide

How to demonstrate every DBMS concept of the College Academic Management System, live, in your Codespace.
Everything below runs on the real project tables. Each step has: what to **say**, what to **run**, what to **expect**.

## 0. Read this first (honest status)

* The project README says the SQL and PL/SQL scripts were **never run on a real Oracle** when the project was built. The new `workout/` scripts were also written without Oracle access. Treat tonight as a rehearsal: run everything once, and fix or skip anything that errors.
* Rehearsal command: `./workout.sh all`. It saves every output to `workout/out/*.txt`. Search those files for `ORA-`. Errors announced by a `PROMPT` line above them are **expected** (they are the constraint and trigger demos). Any other `ORA-` or `PLS-` line is a real problem.
* Keep `workout/out/*.txt` as a backup. If the live run fails, show the saved output and say "this is the recorded run".
* Do **not** run `./reset-demo.sh` during the demo. It rebuilds the whole database and takes minutes. Run it before you start.

## 1. Setup in the Codespace (once)

```bash
cd college
./run.sh --skip-tests        # starts Oracle (first time ~2 GB image), loads database, starts backend 8080 and frontend 5173
./test.sh                    # PASS / FAIL list
# unzip dbms-demo-kit.zip over the college folder: it adds workout/, workout.sh and docs/DBMS_DEMO_GUIDE.md
chmod +x workout.sh
./workout.sh                 # lists the scripts
```

Open **three** things before the audience arrives:

| Window | What | How |
|---|---|---|
| Browser tab 1 | The app, port 5173 (login `admin / admin123`) | Ports tab in Codespaces |
| Terminal A | SQL*Plus as COLLEGE | `./workout.sh shell` |
| Terminal B | A second SQL*Plus (needed for the locking demo) | `./workout.sh shell` |

Useful SQL*Plus settings to type once in a shell:
```sql
SET LINESIZE 180 PAGESIZE 40 SERVEROUTPUT ON
```

Three ways to show a concept, from safest to most impressive:

1. **DBMS Lab page** in the app: click topic N, press *Run demo*. Prebuilt, every run rolls back. Safest.
2. **`./workout.sh NN`**: runs one script, echoing each statement and Oracle's answer. Good when you want no typos.
3. **Typing in `./workout.sh shell`**: copy the lines from the cards below and paste. Most convincing for the examiner.

Recommended: use method 2 for a whole section, then type two or three lines yourself.

## 2. Concept map (where each concept lives)

| # | Concept | Script | DBMS Lab topic | Project use |
|---|---|---|---|---|
| 1 | DDL | 01 | 1 | 17 core tables created with CREATE TABLE, ALTER TABLE adds constraints |
| 2 | DML | 01 | 2 | every add / edit / delete screen |
| 3 | Primary key | 02 | 3 | one per table |
| 4 | Foreign key | 02 | 4 | student to department and class |
| 5 | Unique | 02 | 5 | e-mail, department code, payroll (employee, month) |
| 6 | NOT NULL | 02 | 6 | mandatory fields |
| 7 | CHECK | 02 | 7 | e-mail format, credits 1 to 6, status lists, net = gross minus PF |
| 8 | Referential integrity | 02 | 8 | department with students cannot be deleted (HTTP 409) |
| 9 | WHERE | 03 | 9 | search box, filters |
| 10 | Aggregates | 03 | 10 | dashboard numbers |
| 11 | GROUP BY | 03 | 11 | average per subject |
| 12 | HAVING | 03 | 12 | low attendance report |
| 13 | Set operations | 03 | 13 | UNION, INTERSECT, MINUS |
| 14 | Joins | 03 | 14 | results with student and subject names |
| 15 | Subqueries | 03 | 15 | above average students |
| 16 | Functions | 04 | 16 | marks, grade, SGPA, CGPA, attendance |
| 17 | Stored procedures | 04 | 17 | results, attendance, payroll |
| 18 | Transactions | 05 | 18 | `@Transactional` in Spring |
| 19 | COMMIT | 05 | 19 | end of a unit of work |
| 20 | ROLLBACK | 05 | 20 | undo on error |
| 21 | SAVEPOINT | 05 | 21 | partial undo |
| 22 | GRANT | 09 | 22 | faculty and student roles |
| 23 | REVOKE | 09 | 23 | remove a privilege |
| 24 | INSERT trigger | 06 | 24 | audit of new students |
| 25 | UPDATE trigger | 06 | 25 | marks validation and audit |
| 26 | DELETE trigger | 06 | 26 | audit keeps old values |
| 27 | Implicit cursor | 07 | 27 | `SQL%ROWCOUNT` |
| 28 | Explicit cursor | 07 | 28 | department report |
| 29 | Predefined exceptions | 07 | 29 | NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX |
| 30 | Non-predefined exceptions | 07 | 30 | PRAGMA EXCEPTION_INIT, RAISE_APPLICATION_ERROR |
| 31 | Views | 08 | 31 | result, attendance, CGPA views |
| 32 | Indexes | 08 | 32 | name search, attendance lookup |
| extra | ER model, normalization, sequences | 01 | - | ER diagram, 3NF design |
| extra | Compound trigger chain | 06 | - | absence to SMS to parent |
| extra | Locking, read consistency, deadlock | terminals A and B | - | section 12 |

---

## 3. Script 01: schema tour (DDL, DML, sequences, ER, normalization)

Run: `./workout.sh 01`

| Step | Say | Expect |
|---|---|---|
| `SELECT table_name FROM user_tables` | "These are the tables I created with DDL." | 17 core tables plus the portal tables (parent, timetable, period_slot, notification) and three small marker tables |
| `DESC student` | "Column names, types and NOT NULL." | student_id NUMBER(10) NOT NULL and the rest |
| constraint count by type | "The data dictionary stores every rule. P primary, U unique, R foreign, C check, plus NOT NULL checks." | one row per type |
| child to parent query | "This query prints my ER diagram: each foreign key joined to the table it points to." | e.g. STUDENT to DEPARTMENT, MARKS to ASSESSMENT |
| `demo_tmp` block | "CREATE, ALTER, TRUNCATE, DROP on a throw-away table." | rows before 1, after 0 |
| INSERT / UPDATE / DELETE on dept 99 | "DML changes rows. ROLLBACK keeps the data clean." | 1 row each |
| `seq_payroll.NEXTVAL` then `CURRVAL` | "A sequence hands out primary key numbers. Java uses NEXTVAL for the new student id." | two different numbers, then the same number |
| `salary_rule` and `employee` | "Normalization: the HRA, DA, PF percentages are stored once per designation, not copied into every employee row. That removes a transitive dependency, so the table is in 3NF." | 4 rule rows |
| `assessment`, `result` | "Marks are stored as RAW marks only; converted marks are calculated. RESULT stores calculated values on purpose, as controlled redundancy for fast reports." | |

How to explain normalization if asked: 1NF every column holds one value (no lists). 2NF no column depends on part of a composite key (marks is keyed by student, subject, assessment and holds only raw_marks). 3NF no non-key column depends on another non-key column (salary percentages moved out of employee into salary_rule).

---

## 4. Script 02: constraints (each one is broken on purpose)

Run: `./workout.sh 02`  (or DBMS Lab topics 3 to 8)

| Concept | Statement | Expect |
|---|---|---|
| Primary key | insert department 1 again | `ORA-00001 ... PK_DEPARTMENT` |
| Unique | department code `CSE` twice; student e-mail `rahul@college.edu` twice; payroll twice for employee 1001 month 2026-09 | `ORA-00001` with `UQ_DEPT_CODE`, `UQ_STUDENT_EMAIL`, `UQ_PAYROLL_MONTH` |
| NOT NULL | department without name | `ORA-01400` |
| Foreign key | student with department 999 | `ORA-02291 ... FK_STUDENT_DEPT ... parent key not found` |
| CHECK | e-mail `not-an-email`; payroll net not equal gross minus PF; mark of -1 | `ORA-02290` naming `CHK_STUDENT_EMAIL`, `CHK_PAYROLL_NET`, `CHK_MARKS_NONNEG` |
| Referential integrity | delete department 1 | `ORA-02292 ... child record found` |
| ON DELETE CASCADE | delete attendance session 1, count its records before and after, then ROLLBACK | records go to 0 after delete, return after rollback |

Say: "Java validates first for a friendly message, but Oracle is the last line of defence. In the app the error JSON has a `layer` field that shows who caught it."

Typed example (paste in the shell):
```sql
INSERT INTO department (dept_id, dept_code, dept_name) VALUES (1, 'XXX', 'Duplicate key');
INSERT INTO student (student_id, student_name, email, dept_id, class_id) VALUES (900, 'No Dept', 'nodept@college.edu', 999, 1);
DELETE FROM department WHERE dept_id = 1;
```

---

## 5. Script 03: queries

Run: `./workout.sh 03`  (or DBMS Lab topics 9 to 15)

Say one line per block:

* **WHERE**: "LIKE, BETWEEN, IN with AND."
* **Functions**: "UPPER, SUBSTR, INSTR, CASE, NVL are single-row functions."
* **Aggregates**: "COUNT, AVG, MIN, MAX, SUM turn many rows into one."
* **GROUP BY**: "One output row per department / per subject."
* **HAVING**: "WHERE filters rows before grouping, HAVING filters groups after. Divya (104) shows up under 75 percent."
* **Set operations**: "UNION is failed or low attendance, INTERSECT is both, MINUS is not failed."
* **Joins**: inner, left (a department even with no HOD), right (a subject even with no results), cross (7 assessments x 6 grades = 42), and the six-table join for Rahul in CS302.
* **Subqueries**: single-row (above average), multi-row `IN`, correlated `EXISTS`, correlated average per department, inline view, and `RANK() OVER` as an analytic function.

Expected anchor values: Rahul's CS302 raw marks list 35, 27, 48, 32, 24, 51, 82. Student 109 (Ravi) is the failing student, student 104 (Divya) has low attendance.

Viva trap: "WHERE vs HAVING". Answer: WHERE before GROUP BY on rows, HAVING after GROUP BY on groups and may use aggregates.

---

## 6. Script 04: functions and procedures

Run: `./workout.sh 04`  (or DBMS Lab topics 16 and 17)

| Step | Say | Expect |
|---|---|---|
| `calculate_internal_mark(101,2)` and `calculate_semester_mark(101,2)` | "Raw marks go in, the syllabus formula lives in the function." | **33.4** and **49.2** |
| by-hand arithmetic row | "Part 1 = 35 + (27+48) x 2/3 = 85. Part 2 = 32 + (24+51) x 2/3 = 82. Internal = (85+82)/5 = 33.4." | 85, 82, 33.4 |
| `calculate_grade(82.6)` | "82.6 rounds to 83, which sits in the A+ range 81 to 90." | A+ and grade point 9 |
| `calculate_attendance(101)` / `(104)` | "Present divided by total. OD and medical do not count as present." | Divya low |
| source from `user_source` | "The code is stored inside Oracle, not in Java." | the function text |
| result recalculation | "I break the stored result to 0 / RA / FAIL, call the procedure, and MERGE repairs it." | back to 33.4, 49.2, 82.6, A+, PASS |
| `generate_payroll_all('2026-12', :created)` + `PRINT created` | "OUT parameter hands the count back to the caller." | 5 |
| Professor row | "80000 + HRA 16000 + DA 8000 = 104000 gross; PF 9600; net 94400." | gross 104000, net 94400 |
| five error EXECs | "RAISE_APPLICATION_ERROR gives my own error numbers." | ORA-20020, 20021, 20011, 20010, 20030 |
| `mark_attendance` | "MERGE: insert if missing, update if present." | status changes then ROLLBACK restores |

Function vs procedure: a function RETURNs one value and can sit inside a SELECT; a procedure performs an action and can return values through OUT parameters.

---

## 7. Script 05: transactions

Run: `./workout.sh 05`  (or DBMS Lab topics 18 to 21)

Say: "A transaction is all or nothing. ACID: Atomicity, Consistency, Isolation, Durability."

| Concept | What happens | Expect |
|---|---|---|
| ROLLBACK | set all of Rahul's CS302 marks to 0, count zeros, ROLLBACK, count again | 7 zeros then 0 |
| SAVEPOINT | CT1 27 to 28, `SAVEPOINT after_ct1`, CT2 24 to 29, `ROLLBACK TO SAVEPOINT after_ct1` | CT1 = 28 kept, CT2 = 24 undone, then full ROLLBACK returns 27 and 24 |
| COMMIT | insert department 98, COMMIT, then ROLLBACK | row is still there (durable) |
| Implicit commit of DDL | insert department 97, run CREATE TABLE, ROLLBACK | row survived, because DDL commits first |
| Atomicity in PL/SQL | two inserts, second fails, block rolls back both | `atomic_rows_left` = 0 |

In the app: `MarksService`, `AttendanceService` and `PayrollService` use `@Transactional`: commit on success, rollback on a RuntimeException.

---

## 8. Script 06: triggers

Run: `./workout.sh 06`  (or DBMS Lab topics 24 to 26)

| Concept | Statement | Expect |
|---|---|---|
| List | `user_triggers` | TRG_MARKS_VALIDATE, TRG_MARKS_AUDIT_UPDATE, TRG_STUDENT_AUDIT_INS, TRG_STUDENT_AUDIT_DEL, TRG_ATTENDANCE_NOTIFY |
| INSERT trigger | insert student 902 | audit row `INSERT` with new value, written by the trigger, not by you |
| DELETE trigger | delete student 902 | audit row `DELETE` with the OLD name and e-mail |
| BEFORE UPDATE | CT1 = 99 | `ORA-20001: Marks 99 exceed the maximum 30 for this assessment` |
| AFTER UPDATE | CT1 = 26 | audit row with old 27 and new 26 |
| WHEN clause | update to the same value 26 | no extra audit row |
| Compound trigger | `EXEC mark_attendance(1, 101, 'ABSENT')` | a PARENT SMS row and one ADVISOR EMAIL digest row appear in `notification`; marking student 103 absent too updates the digest; ROLLBACK removes them |

Say: "BEFORE triggers can stop a row, AFTER triggers react. A compound trigger collects the periods touched by a statement and builds one advisor digest after the statement, which avoids the mutating table error."

App version: Students page, add a student, then open the **Audit** page. Marks page, tick "skip Java validation", enter CT1 = 31: the Oracle trigger rejects (layer = Trigger).

---

## 9. Script 07: cursors and exceptions

Run: `./workout.sh 07`  (or DBMS Lab topics 27 to 30)

* **Implicit cursor**: the first block prints `dept 99 : FOUND=FALSE ROWCOUNT=0` and `class 1 : FOUND=TRUE ROWCOUNT=<n>`. Say: "Oracle opened and closed it for me."
* **Explicit cursor**: five steps on screen: DECLARE, OPEN, FETCH in a loop, `EXIT WHEN c%NOTFOUND`, CLOSE. Prints the ten sample students with CGPA.
* **Parameterised cursor**: `department_report_text(4, ...)` prints the Mechanical department report.
* **Cursor FOR loop**: "shortcut, Oracle does open, fetch, close."
* **Six exception cases** from `demo_exception`:
  * NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX are **predefined** (Oracle gave them names).
  * CHILD_RECORD_FOUND (-2292) and PARENT_NOT_FOUND (-2291) are **non-predefined**: the code binds a name with `PRAGMA EXCEPTION_INIT`.
  * USER_DEFINED shows `ORA-20001` raised by `RAISE_APPLICATION_ERROR` inside the trigger.
* **Your own exception typed live**: `e_low_attendance` raised for student 104.

---

## 10. Script 08: views and indexes

Run: `./workout.sh 08`  (or DBMS Lab topics 31 and 32)

* **Views**: list, show the hidden four-table join from `user_views`, query `student_result_view`, `student_cgpa_view` (calls functions), `student_attendance_view` (GROUP BY). Say: "A view hides joins, gives one place to fix a query, and is a security tool because I can grant the view without the table."
* **Indexes**: list the indexes (PK and UNIQUE create theirs automatically, I added four more, see `13_indexes.sql`).
* **Plans**: `EXPLAIN PLAN` with `/*+ FULL */` shows `TABLE ACCESS FULL`; with `/*+ INDEX(ar idx_attrec_student) */` shows `INDEX RANGE SCAN` and a lower cost. Say: "Same query, same answer, different access path."
* **When an index is not used**: `UPPER(student_name) = 'RAHUL'` wraps the column in a function, so the plain index on `student_name` cannot be used.

Honest caveat: the tables are small, so Oracle may pick a full scan on its own. That is why the demo forces both paths with hints.

---

## 11. Script 09: GRANT and REVOKE (DCL)

Run: `./workout.sh 09`  (or DBMS Lab topics 22 and 23)

The script logs in as different users itself:

1. As `college_student`: `SELECT * FROM college.marks` fails with `ORA-00942`; `student_result_view` works.
2. As `system`: `GRANT SELECT ON college.marks TO college_student_role`.
3. As `college_student`: the same SELECT now works.
4. As `system`: `REVOKE SELECT ON college.marks FROM college_student_role`.
5. As `college_student`: blocked again.
6. As `college_faculty`: UPDATE on marks works, `DELETE FROM college.student` fails with `ORA-01031`, UPDATE on `attendance_record` fails because it was revoked in `14_users_roles.sql`.

Say: "A role is a named bundle of privileges. Users get roles, not individual grants."

If the script stops halfway, clean up by hand: `./workout.sh system` then `REVOKE SELECT ON college.marks FROM college_student_role;`

---

## 12. Locking, read consistency and deadlock (two terminals)

Use Terminal A and Terminal B (both `./workout.sh shell`). This shows the **I** (Isolation) of ACID.

**Part 1: readers do not wait for writers**

| Terminal | Type | Expect |
|---|---|---|
| A | `UPDATE marks SET raw_marks = 29 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 5;` | 1 row updated, not committed |
| B | `SELECT raw_marks FROM marks WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 5;` | **24**, the old committed value, and it returns at once |

Say: "Oracle gives B a consistent snapshot, so reads never block."

**Part 2: writers wait for writers (row lock)**

| Terminal | Type | Expect |
|---|---|---|
| B | `UPDATE marks SET raw_marks = 30 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 5;` | **hangs** (waiting for A's lock) |
| A | `ROLLBACK;` | B immediately prints `1 row updated` |
| B | `ROLLBACK;` | everything is back to 24 |

**Part 3: deadlock (optional, impressive)**

| Terminal | Type | Expect |
|---|---|---|
| A | `UPDATE marks SET raw_marks = raw_marks WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 2;` | 1 row |
| B | `UPDATE marks SET raw_marks = raw_marks WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 5;` | 1 row |
| A | the update on assessment_id = 5 | waits |
| B | the update on assessment_id = 2 | after a few seconds one session gets `ORA-00060: deadlock detected while waiting for resource` |
| both | `ROLLBACK;` | clean |

Say: "Oracle detects the cycle and aborts one statement. The application should roll back and retry."

---

## 13. End-to-end app demo (5 minutes, browser)

Login `admin / admin123` at port 5173.

1. **Dashboard**: live counts, all from aggregate queries.
2. **Students**: add a student with a bad e-mail. Java rejects (layer: Java validation). Tick **let Oracle reject duplicates**, add an existing e-mail: layer = Oracle constraint, `UQ_STUDENT_EMAIL`.
3. **Audit**: the INSERT you just did was written by a trigger. Delete the student, refresh: DELETE row with old values.
4. **Marks**: student 101, CS302: step-by-step calculation, 82.6, Java result equals Oracle result. Enter CT1 = 31: Java rejects. Tick **skip Java validation** and save again: the Oracle trigger rejects (layer: Trigger).
5. **Attendance**: low-attendance view lists Divya.
6. **Results**: **Calculate all results** runs the PL/SQL procedure; SGPA and CGPA shown. **Grades** shows the grade scale is table data.
7. **Payroll**: generate a new month, then the same month again: UNIQUE blocks it. Open a payslip.
8. **DBMS Lab**: run topics 3, 21, 25 and 28.

Remember to run `./reset-demo.sh` **before** the real demo if you changed data while practising.

---

## 14. DBMS viva questions with short answers

1. **DDL vs DML vs DCL vs TCL?** DDL defines structure (CREATE, ALTER, DROP, TRUNCATE). DML changes rows (INSERT, UPDATE, DELETE). DCL controls access (GRANT, REVOKE). TCL controls transactions (COMMIT, ROLLBACK, SAVEPOINT).
2. **DELETE vs TRUNCATE vs DROP?** DELETE removes chosen rows and can be rolled back. TRUNCATE removes all rows, is DDL, cannot be rolled back. DROP removes the table itself.
3. **Primary key vs unique?** PK is unique and not null, one per table. UNIQUE allows NULL and a table can have many.
4. **What is a foreign key?** A column that must match a parent key or be NULL. It enforces referential integrity.
5. **What does ON DELETE CASCADE do?** Deleting the parent deletes the children. Used only for attendance records of a session.
6. **WHERE vs HAVING?** Rows before grouping vs groups after grouping.
7. **UNION vs UNION ALL?** UNION removes duplicates.
8. **INNER vs LEFT vs RIGHT join?** Inner keeps matches only. Left keeps all left rows. Right keeps all right rows.
9. **What is a correlated subquery?** The inner query uses a column of the outer query and runs per outer row.
10. **Function vs procedure?** Function returns a value and works inside SQL. Procedure performs an action, returns through OUT.
11. **What is ACID?** Atomicity all or nothing, Consistency rules always hold, Isolation concurrent transactions do not see uncommitted data, Durability committed data survives.
12. **Why does DDL auto-commit?** Oracle issues an implicit COMMIT before and after DDL.
13. **ROLLBACK vs ROLLBACK TO SAVEPOINT?** Undo everything vs undo back to the bookmark.
14. **Trigger types here?** BEFORE (validate), AFTER (audit), row level (`FOR EACH ROW`), compound (statement plus row timing).
15. **What are `:OLD` and `:NEW`?** Row values before and after the change.
16. **Implicit vs explicit cursor?** Oracle manages implicit ones for DML; you DECLARE, OPEN, FETCH, CLOSE explicit ones.
17. **Predefined vs non-predefined exception?** Named by Oracle vs only a number that you name with `PRAGMA EXCEPTION_INIT`.
18. **What does `RAISE_APPLICATION_ERROR` do?** Raises a user-defined error between -20000 and -20999.
19. **What is a view and why use it?** A stored query. Hides joins, centralises logic, restricts access.
20. **When is an index not used?** Tiny tables, or when the column is wrapped in a function.
21. **What is a sequence?** A generator of unique numbers for keys; `NEXTVAL`, `CURRVAL`.
22. **What is normalization?** Removing redundancy by splitting tables (1NF, 2NF, 3NF). Here: raw marks separate from calculated results, salary percentages in `salary_rule`.
23. **Why store RESULT if it can be calculated?** Controlled denormalization for fast reports and history; the procedure can always rebuild it from raw marks.
24. **What is a role?** A named set of privileges you grant to users.
25. **How do you prevent SQL injection?** Always `?` placeholders in JdbcTemplate; the DBMS Lab sends only a topic number.
26. **What is MERGE?** Insert-or-update in one statement; used by result and attendance procedures.
27. **What isolation level does Oracle use by default?** READ COMMITTED with statement-level read consistency. Readers never block writers.
28. **What causes a deadlock?** Two sessions each hold a lock the other needs. Oracle aborts one statement with ORA-00060.

---

## 15. If something goes wrong

| Symptom | Fix |
|---|---|
| `workout.sh` says container not running | `./run.sh`, or `docker start college-oracle` |
| `ORA-00942` where a table should exist | the database is not loaded: `./setup-db.sh` |
| Counts differ from this guide | data was changed while practising: `./reset-demo.sh` (minutes, do it before the demo) |
| A trigger or procedure is missing | `./setup-db.sh` prints the failing script; compile errors: `SELECT * FROM user_errors;` |
| Stuck waiting in the locking demo | in the other terminal type `ROLLBACK;` |
| Script 09 stopped halfway | `./workout.sh system`, then `REVOKE SELECT ON college.marks FROM college_student_role;` |
| Live run fails in front of examiner | show `workout/out/NN_*.txt` from the rehearsal, or run the same topic from the DBMS Lab page |
