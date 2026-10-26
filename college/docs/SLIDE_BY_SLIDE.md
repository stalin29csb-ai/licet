# Slide by slide: what to run while each slide is on screen

Setup before you start: Oracle running (`./run.sh --skip-tests`), app open in a browser tab (login `admin / admin123`), Terminal A and Terminal B open in `college/` (both `./workout.sh shell` at the time of slide 11), `./reset-demo.sh` already done.
Rule: say the slide in one or two sentences, switch to the terminal or browser, run the step, switch back, click next.

| Slide | Say (one line) | Run | Time |
|---|---|---|---|
| 1 Title | "A college system where Oracle owns the rules." | nothing | 0:20 |
| 2 Problem | Read the four cards. | nothing | 1:00 |
| 3 Solution | "17 tables, 7 functions, 10 procedures, 5 triggers." | Terminal A: `./workout.sh shell` then `SELECT object_type, COUNT(*) FROM user_objects GROUP BY object_type ORDER BY 1;` | 1:00 |
| 4 Architecture | "React calls Spring Boot, which sends raw SQL to Oracle." | Second terminal: `tail -f logs/backend.log`. In the browser open **Students** and search. The SQL statements scroll by. Then `curl localhost:8080/api/health` | 1:30 |
| 5 Workflow: mark to grade | "33.4 plus 49.2 is 82.6, grade A+." | Browser **Marks**, student 101, CS302: show Java and Oracle values. Enter CT1 = 31: Java rejects. Tick "skip Java validation", save again: Oracle trigger rejects | 2:00 |
| 6 Workflow: absence to alert | "Marking absent fires a trigger that queues alerts." | Terminal A, type: `EXEC mark_attendance(1, 101, 'ABSENT')` then `SELECT recipient_type, channel, status, title FROM notification WHERE session_id = 1;` then `ROLLBACK;` | 1:30 |
| 7 Database design | "Foreign keys are my ER diagram. Normalized to 3NF." | `./workout.sh 01` (watch the child to parent query and the salary_rule step) | 2:00 |
| 8 Constraints | "Each rule is broken on purpose, Oracle answers." | `./workout.sh 02` | 2:00 |
| 9 Queries | "One block per concept." | `./workout.sh 03` (scroll fast, stop at HAVING, set operations, correlated subquery) | 2:30 |
| 10 PL/SQL | "The formula lives in the function." | `./workout.sh 04` (stop at 33.4, 49.2, the payroll 94400, the ORA-200xx errors) | 2:30 |
| 11 Transactions and ACID | "Savepoint, commit, rollback, then isolation." | `./workout.sh 05`. Then Terminal A and B: A `UPDATE marks SET raw_marks = 29 WHERE student_id = 101 AND subject_id = 2 AND assessment_id = 5;` B `SELECT raw_marks ...` shows 24, B update hangs, A `ROLLBACK;` (full steps in guide section 12) | 3:00 |
| 12 Triggers, cursors, exceptions | "BEFORE validates, AFTER audits, cursors loop, exceptions handle." | `./workout.sh 06` then `./workout.sh 07` | 3:00 |
| 13 Views, indexes, access | "Views hide joins, indexes change the plan, roles limit access." | `./workout.sh 08` then `./workout.sh 09` | 3:00 |
| 14 Demo plan | Use it as the recap and fallback: open **DBMS Lab** in the browser and run topics 3, 21, 25, 28 with one click each. | Browser DBMS Lab | 1:00 |
| 15 Outcome | "32 of 32 topics, rules in the database, every change audited." | Browser **Audit** page to show the rows the triggers wrote during the demo | 1:00 |

Total about 27 minutes. If you only have 15, skip the second half of slides 9, 12 and 13 (run only the first script of each pair), skip slide 4's log tail, and skip the locking demo on slide 11.

Between slides: nothing to reset. Every script rolls back its own changes. If a script stops halfway, type `ROLLBACK;` in the shell; for script 09 see the troubleshooting table in `DBMS_DEMO_GUIDE.md`.
