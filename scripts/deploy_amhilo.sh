#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter_bin="${AMHILO_FLUTTER_BIN:-$HOME/flutter-amhilo/bin/flutter}"
"$flutter_bin" pub get
"$flutter_bin" build web --release --base-href "/"
build_id="$(git rev-parse --short=12 HEAD)-$(date -u +%Y%m%d%H%M%S)"
sed -i "s/AMHILO_BUILD_ID/$build_id/g" build/web/index.html build/web/flutter_bootstrap.js
cp scripts/retire_flutter_service_worker.js build/web/flutter_service_worker.js
firebase deploy --only hosting --project amhilo --config firebase.amhilo.json
