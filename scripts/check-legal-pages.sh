#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 화면에 읽히는 문구가 있는지를 본다. 조판용 붙임 공백은 보이는 글자가 아니므로
# 비교 전에 보통 공백으로 맞춘다 — 문자로 쓰든 &nbsp; 로 쓰든 같게 본다.
# 이렇게 안 하면 "월 100건"이 갈리지 않게 묶은 것만으로 문구가 사라진 것처럼 잡힌다.
require_text() {
  local file="$1"
  local text="$2"

  if ! python3 -c '
import sys
path, needle = sys.argv[1], sys.argv[2]
def norm(s):
    for a in ("&nbsp;", "&#160;", "\u00a0"):
        s = s.replace(a, " ")
    return s.replace("\u2011", "-")
sys.exit(0 if norm(needle) in norm(open(path, encoding="utf-8").read()) else 1)
' "$repo_root/$file" "$text"; then
    printf 'Missing required legal copy in %s: %s\n' "$file" "$text" >&2
    exit 1
  fi
}

for file in privacy/index.html en/privacy/index.html ja/privacy/index.html; do
  require_text "$file" "OpenAI OpCo, LLC"
  require_text "$file" "Supabase, Inc."
  require_text "$file" "Apple Inc."
  require_text "$file" "RevenueCat, Inc."
  require_text "$file" "privacy@lululabs.ai"
done

require_text privacy/index.html "중복 요청 기록 35일"
require_text privacy/index.html "현재 월과 직전 2개 월"
require_text privacy/index.html "2026년 8월 9일"
require_text terms/index.html "민감하거나 고위험한 개인정보"
require_text terms/index.html "월 100건까지"
require_text index.html "AI 정리를 월 100건까지"

require_text en/privacy/index.html "duplicate-request records for 35 days"
require_text en/privacy/index.html "current and previous two months"
require_text en/privacy/index.html "August 9, 2026"
require_text en/terms/index.html "sensitive or high-risk personal information"
require_text en/terms/index.html "up to 100 AI"
require_text en/index.html "Up to 100 saves organized by AI each month"

require_text ja/privacy/index.html "重複リクエスト記録は35日"
require_text ja/privacy/index.html "当月と直前2か月"
require_text ja/privacy/index.html "2026年8月9日"
require_text ja/terms/index.html "機微または高リスクな個人情報"
require_text ja/terms/index.html "月100件まで"
require_text ja/index.html "AI整理を月100件まで"

if grep -Fq -- "AI 정리를 제한 없이" "$repo_root/index.html" \
  || grep -Fiq -- "unlimited AI organization" "$repo_root/en/index.html" \
  || grep -Fq -- "AI整理を無制限に" "$repo_root/ja/index.html"; then
  echo "[legal-check] stale unlimited Premium copy remains on a landing page" >&2
  exit 1
fi

if grep -R -Fq -- "2026년 8월 4일" "$repo_root/privacy" "$repo_root/terms" \
  || grep -R -Fq -- "August 4, 2026" "$repo_root/en/privacy" "$repo_root/en/terms" \
  || grep -R -Fq -- "2026年8月4日" "$repo_root/ja/privacy" "$repo_root/ja/terms"; then
  printf 'Outdated publication date remains in a legal page.\n' >&2
  exit 1
fi

printf 'Legal page checks passed for Korean, English, and Japanese.\n'
