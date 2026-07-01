#!/usr/bin/env bash
# Unit and integration test runner for this mod
# Usage: bash tools/run-tests.sh [--unit|--integration|--all]
#
# Requires: testing/ directory at workspace root (parent of this script's parent)
#
# Flags:
#   --unit        Run only unit tests
#   --integration Run only integration tests
#   --all         Run both (default)

set -euo pipefail

MOD_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTING_ROOT="$MOD_ROOT/../testing"

# Parse arguments
MODE="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --unit)
      MODE="unit"
      shift
      ;;
    --integration)
      MODE="integration"
      shift
      ;;
    --all)
      MODE="all"
      shift
      ;;
    --help)
      echo "Usage: $0 [--unit|--integration|--all]"
      echo ""
      echo "Options:"
      echo "  --unit        Run only unit tests"
      echo "  --integration Run only integration tests"
      echo "  --all         Run both (default)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Run unit tests
if [ "$MODE" = "unit" ] || [ "$MODE" = "all" ]; then
  if [ -d "$MOD_ROOT/scripts/test/unit" ]; then
    echo "Running unit tests..."
    bash "$TESTING_ROOT/shell/unit-runner.sh" "$MOD_ROOT"
  else
    echo "No unit test directory found at $MOD_ROOT/scripts/test/unit/"
  fi
fi

# Run integration tests
if [ "$MODE" = "integration" ] || [ "$MODE" = "all" ]; then
  if [ -d "$MOD_ROOT/scripts/test/integration" ]; then
    source "$TESTING_ROOT/config.env" 2>/dev/null || true
    if [ -n "${FACTORIO_EXE:-}" ] && [ -n "${FACTORIO_PLAYER_DATA:-}" ]; then
      echo "Running integration tests..."
      bash "$TESTING_ROOT/shell/integration-runner.sh" "$MOD_ROOT" "$FACTORIO_EXE" "$FACTORIO_PLAYER_DATA"
    else
      echo "Skipping integration tests: Factorio not configured in config.env"
    fi
  else
    echo "No integration test directory found at $MOD_ROOT/scripts/test/integration/"
  fi
fi
