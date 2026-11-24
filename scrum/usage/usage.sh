#!/usr/bin/env bash
# Usage log and estimate. See README.md in this folder.
#   usage.sh <model> <session_before> <session_after> <week_before> <week_after> <points> [note]
#   usage.sh estimate [model]
#   usage.sh trend [model]
#   usage.sh project <model> <points> <session_now> [week_now]
# Env: USAGE_LOG (log file, default usage.log next to this script), USAGE_TIME (ISO time, default now).
dir=$(cd "$(dirname "$0")" && pwd)
log=${USAGE_LOG:-$dir/usage.log}

# est <file> <model> <mode> [limit]
# mode full: print the estimate and the per-row list; brief: print "session|week" (? if none);
# count: print the number of rows of the model. limit = use only the first N rows of the model.
est() {
  awk -F'|' -v model="$2" -v mode="$3" -v lim="${4:-0}" '
  function calc(label, col,   i, j, n, c, m, sd, d, sum, ss, id, r, flag) {
    n = 0
    for (i = 1; i <= rows; i++) {
      if (model_of[i] != model) continue
      if (lim > 0 && ++seen > lim) break
      if (v[i, col] == "?" || pts[i] + 0 <= 0) continue
      n++; id[n] = i; r[n] = v[i, col] / pts[i]
    }
    seen = 0
    if (n == 0) { res[col] = "?"; if (mode == "full") printf "%s: no usable rows for %s\n", label, model; return }
    for (i = 1; i <= n; i++) {
      flag[i] = 0
      if (n >= 3) {   # compare each row with the mean and sd of all the other known rows
        sum = 0; c = 0
        for (j = 1; j <= n; j++) if (j != i) { sum += r[j]; c++ }
        m = sum / c; ss = 0
        for (j = 1; j <= n; j++) if (j != i) ss += (r[j] - m) ^ 2
        sd = sqrt(ss / (c - 1))
        d = r[i] - m; if (d < 0) d = -d
        if (d > sd) flag[i] = 1
      }
    }
    sum = 0; c = 0
    for (i = 1; i <= n; i++) if (!flag[i]) { sum += r[i]; c++ }
    if (c == 0) { c = n; sum = 0; for (i = 1; i <= n; i++) { flag[i] = 0; sum += r[i] } }
    m = sum / c; ss = 0
    for (i = 1; i <= n; i++) if (!flag[i]) ss += (r[i] - m) ^ 2
    sd = (c > 1) ? sqrt(ss / (c - 1)) : 0
    res[col] = sprintf("%.3f", m)
    if (mode != "full") return
    printf "%s: mean %.3f %s per story point, sd %.3f, used %d, discarded %d", label, m, unit[col], sd, c, n - c
    if (c < 3) printf "  (low confidence: fewer than 3 usable rows)"
    printf "\n"
    for (i = 1; i <= n; i++) printf "  %s  %s  ratio %.3f  %s\n", time_of[id[i]], note_of[id[i]], r[i], (flag[i] ? "discarded" : "used")
  }
  /^#/ || NF < 10 { next }
  { rows++; time_of[rows] = $1; model_of[rows] = $2; v[rows, 5] = $5; v[rows, 8] = $8; pts[rows] = $9; note_of[rows] = substr($10, 1, 40); if ($2 == model) total++ }
  END {
    if (mode == "count") { print total + 0; exit }
    unit[5] = "session %"; unit[8] = "weekly %"
    if (mode == "full") printf "Model %s\n", model
    calc("Session", 5); calc("Weekly ", 8)
    if (mode == "brief") print res[5] "|" res[8]
  }' "$1"
}

isnum() { [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; }
pct() { # percent 0-100, or ? or - (unknown -> ?); prints nothing and fails when invalid
  case "$1" in '?'|'-') echo '?'; return 0;; esac
  isnum "$1" && awk -v x="$1" 'BEGIN{ exit !(x + 0 <= 100) }' && echo "$1"
}
posnum() { isnum "$1" && awk -v x="$1" 'BEGIN{ exit !(x + 0 > 0) }'; }
delta() { # before after -> delta or ?
  if [ "$1" = '?' ] || [ "$2" = '?' ]; then echo '?'; else awk -v b="$1" -v a="$2" 'BEGIN{ if (a < b) print "?"; else printf "%g\n", a - b }'; fi
}

case "$1" in
  estimate)
    [ -f "$log" ] || { echo "No log at $log"; exit 1; }
    est "$log" "${2:-Sonnet 5.5}" full ;;
  trend)
    [ -f "$log" ] || { echo "No log at $log"; exit 1; }
    m=${2:-Sonnet 5.5}; n=$(est "$log" "$m" count); [ "$n" -gt 0 ] || { echo "No rows for $m"; exit 1; }
    echo "Model $m: estimate after each row (session | week, % per story point)"
    for ((k = 1; k <= n; k++)); do
      e=$(est "$log" "$m" brief "$k"); echo "  row $k  ${e%|*} | ${e#*|}"
      sess[k]=${e%|*}; wk[k]=${e#*|}
    done
    verdict() { # three estimates -> rising, falling, flat or unknown
      awk -v a="$1" -v b="$2" -v c="$3" 'BEGIN{
        if (a == "?" || b == "?" || c == "?") { print "unknown"; exit }
        d = c - a; t = 0.05 * a; if (d < 0) d = -d
        if (d <= t) print "flat"; else if (c > a) print "rising"; else print "falling" }'
    }
    f=$((n > 3 ? n - 2 : 1)); [ $n -ge 2 ] || f=1
    echo "Session trend (last up to 3 estimates, flat within 5%): $(verdict "${sess[f]}" "${sess[f]}" "${sess[n]}")"
    echo "Week trend: $(verdict "${wk[f]}" "${wk[f]}" "${wk[n]}")"
    echo "Latest estimate: session ${sess[n]}, week ${wk[n]} per story point" ;;
  project)
    [ $# -eq 4 ] || [ $# -eq 5 ] || { echo "usage: usage.sh project <model> <points> <session_now> [week_now]"; exit 1; }
    [ -n "$2" ] || { echo "model must not be empty"; exit 1; }
    posnum "$3" || { echo "points must be a positive number"; exit 1; }
    sn=$(pct "$4") && [ "$sn" != '?' ] || { echo "session_now must be a number from 0 to 100"; exit 1; }
    wn=
    if [ $# -eq 5 ]; then wn=$(pct "$5") && [ "$wn" != '?' ] || { echo "week_now must be a number from 0 to 100"; exit 1; }; fi
    [ -f "$log" ] || { echo "No log at $log"; exit 1; }
    e=$(est "$log" "$2" brief); mean=${e%|*}; wmean=${e#*|}
    [ "$mean" != '?' ] || { echo "No session estimate for $2"; exit 1; }
    est "$log" "$2" full | grep -q 'low confidence' && echo "Low-confidence estimate."
    awk -v n="$sn" -v p="$3" -v m="$mean" -v wn="$wn" -v wm="$wmean" 'function lvl(a) { return a >= 85 ? 2 : (a >= 70 ? 1 : 0) }
      BEGIN{ a = n + p * m; printf "Projected session after-reading: %.1f%% (now %s + %s points x %.3f)\n", a, n, p, m; L = lvl(a)
      if (wn != "") {
        if (wm == "?") print "No weekly estimate: week not checked."
        else { w = wn + p * wm; printf "Projected week after-reading: %.1f%% (now %s + %s points x %.3f)\n", w, wn, p, wm; if (lvl(w) > L) L = lvl(w) }
      }
      if (L == 2) print "Crosses 85: Warning."; else if (L == 1) print "Crosses 70: Caution."; else print "Below 70: no level crossed." }'
    ;;
  ''|-h|--help) sed -n '2,7p' "$0"; exit 1 ;;
  *)
    [ $# -ge 6 ] || { echo "usage: usage.sh <model> <session_before> <session_after> <week_before> <week_after> <points> [note]"; exit 1; }
    model=$1; note=${7//|/\/}
    [ -n "$model" ] || { echo "model must not be empty"; exit 1; }
    for k in 2 3 4 5; do
      v=$(pct "${!k}") || { echo "argument $k must be a number from 0 to 100, or ? or -"; exit 1; }
      case $k in 2) sb=$v;; 3) sa=$v;; 4) wb=$v;; 5) wa=$v;; esac
    done
    posnum "$6" || { echo "points must be a positive number"; exit 1; }
    pts=$6
    t=${USAGE_TIME:-$(date +%Y-%m-%dT%H:%M:%S)}
    line="$t|$model|$sb|$sa|$(delta "$sb" "$sa")|$wb|$wa|$(delta "$wb" "$wa")|$pts|$note|auto"
    [ -f "$log" ] || echo "# time|model|session_before|session_after|session_delta|week_before|week_after|week_delta|points|note|used|est_session|est_week" > "$log"
    tmp=$(mktemp); { cat "$log"; echo "$line"; } > "$tmp"
    e=$(est "$tmp" "$model" brief); rm -f "$tmp"
    echo "$line|${e%|*}|${e#*|}" >> "$log"
    echo "Row added to $log"
    est "$log" "$model" full
    ;;
esac
