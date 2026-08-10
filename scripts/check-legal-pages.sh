#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_text() {
  local file="$1"
  local text="$2"

  if ! grep -Fq -- "$text" "$repo_root/$file"; then
    printf 'Missing required legal copy in %s: %s\n' "$file" "$text" >&2
    exit 1
  fi
}

for file in privacy/index.html en/privacy/index.html ja/privacy/index.html; do
  require_text "$file" "OpenAI OpCo, LLC"
  require_text "$file" "Supabase, Inc."
  require_text "$file" "Apple Inc."
  require_text "$file" "Google LLC"
  require_text "$file" "RevenueCat, Inc."
  require_text "$file" "privacy@lululabs.ai"
done

require_text privacy/index.html "중복 요청 기록 35일"
require_text privacy/index.html "현재 월과 직전 2개 월"
require_text privacy/index.html "2026년 8월 9일"
require_text terms/index.html "민감하거나 고위험한 개인정보"
require_text terms/index.html "월 200건까지"
require_text index.html "AI 정리를 월 200건까지"

require_text en/privacy/index.html "duplicate-request records for 35 days"
require_text en/privacy/index.html "current and previous two months"
require_text en/privacy/index.html "August 9, 2026"
require_text en/terms/index.html "sensitive or high-risk personal information"
require_text en/terms/index.html "up to 200 AI"
require_text en/index.html "Up to 200 AI organizations each month"

require_text ja/privacy/index.html "重複リクエスト記録は35日"
require_text ja/privacy/index.html "当月と直前2か月"
require_text ja/privacy/index.html "2026年8月9日"
require_text ja/terms/index.html "機微または高リスクな個人情報"
require_text ja/terms/index.html "月200件まで"
require_text ja/index.html "AI整理を月200件まで"

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
