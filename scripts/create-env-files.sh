#!/bin/sh
function create_env_file () {
  local EV=();
  if [ $# -gt 0 ]; then
    EV+=($@);
  else
    EV+=("dev" "fix" "perf" "prod" "qa" "release" "sbx");
  fi;
  for ei in "${EV[@]}"; do
    if [ -f "manifest-${ei}.yml" ]; then
      echo "Creating .${ei}.env from manifest-${ei}.yml...";
      yq r manifest-${ENV:-dev}.yml env -j | \
        python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' | \
        sed -e '/^\([^:]\+\):\s*\(.*\)$/ s//\1=\2/g' > ".${ei}.env";
    else
      echo "File not found: manifest-${ei}.yml";
    fi;
  done;
}

if [ $# -eq 0 ]; then
  create_env_file
else
  "$@"
fi;