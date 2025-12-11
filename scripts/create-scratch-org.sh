#!/bin/bash
source "$(dirname "$0")/config.sh"

execute() {
  "$@" || exit
}

echo "Setting default devhub"
execute sf config set target-dev-hub="$DEV_HUB_ALIAS"

echo "Deleting old scratch org (if exists)"
sf org delete scratch --no-prompt --target-org "$SCRATCH_ORG_ALIAS" 2>/dev/null

echo "Creating scratch org"
execute sf org create scratch --alias "$SCRATCH_ORG_ALIAS" --set-default --definition-file ./config/project-scratch-def.json --duration-days 30 --wait 10

echo "Deploying source to scratch org"
execute sf project deploy start --source-dir force-app

echo "Assigning permission sets"
execute sf org assign permset -n EinsteinGPTPromptTemplateManager
execute sf org assign permset -n Agent_Script_Recipes_Data
execute sf org assign permset -n Agent_Script_Recipes_App

echo "Importing sample data"
execute sf data import tree --plan data/data-plan.json

echo "Opening org"
sf org open -p "/lightning/n/standard-AgentforceStudio?c__nav=agents"

echo "Done! Scratch org '$SCRATCH_ORG_ALIAS' is ready."
