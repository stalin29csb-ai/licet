#!/usr/bin/env bash
# Live DBMS workout runner for the demo.   Put this file in the college/ folder (next to run.sh).
#   ./workout.sh              list the workout scripts
#   ./workout.sh 04           run workout/04_*.sql with every statement echoed and Oracle's answer under it
#   ./workout.sh shell        open an interactive SQL*Plus as COLLEGE (type or paste the commands from the guide)
#   ./workout.sh system       open an interactive SQL*Plus as SYSTEM (for GRANT / REVOKE by hand)
#   ./workout.sh all          run all scripts and save the output to workout/out/ (rehearsal and backup screenshots)
source "$(cd "$(dirname "$0")" && pwd)/.env.sh"
cd "$ROOT" || exit 1
CONN="//localhost:1521/$ORACLE_SERVICE"

docker ps --format '{{.Names}}' | grep -qx "$ORACLE_CONTAINER" || die "Oracle container '$ORACLE_CONTAINER' is not running. Start it with ./run.sh"

run_one() {   # run_one <file>
  local f="$1"
  docker cp workout/. "$ORACLE_CONTAINER":/tmp/workout >/dev/null || die "docker cp failed"
  docker exec -i "$ORACLE_CONTAINER" sqlplus -L "$ORACLE_APP_USER/$ORACLE_APP_PASSWORD@$CONN" @"/tmp/workout/$(basename "$f")" < /dev/null
}

case "${1:-}" in
  "")      echo "Workout scripts:"; ls -1 workout/*.sql | sed 's#workout/#  #'; echo; echo "usage: ./workout.sh <number> | shell | system | all" ;;
  shell)   exec docker exec -it "$ORACLE_CONTAINER" sqlplus -L "$ORACLE_APP_USER/$ORACLE_APP_PASSWORD@$CONN" ;;
  system)  exec docker exec -it "$ORACLE_CONTAINER" sqlplus -L "system/$ORACLE_SYS_PASSWORD@$CONN" ;;
  all)
    mkdir -p workout/out
    for f in workout/[0-9]*.sql; do
      n="$(basename "$f" .sql)"; printf '  running %-28s' "$n"
      run_one "$f" > "workout/out/$n.txt" 2>&1 && echo "saved workout/out/$n.txt" || echo "FAILED (see workout/out/$n.txt)"
    done
    echo; echo "Check each file for unexpected ORA- errors. Expected errors are announced by the PROMPT line above them." ;;
  *)
    f="$(ls workout/"$1"*.sql 2>/dev/null | head -1)"
    [ -n "$f" ] || die "No script starting with '$1' in workout/"
    run_one "$f" ;;
esac
