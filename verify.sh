#!/bin/bash
#
# Verify CurioCard.sol against on-chain bytecode for Curio Card 18
# Contract: 0x8ccf904e75bc592df3db236cd171d0caf0b2bbcb
# Compiler: solc 0.4.8+commit.60cc1668 (no optimizer)
#
set -euo pipefail

SOLC_VERSION="0.4.8"
SOLC_COMMIT="60cc1668"
CONTRACT_ADDR="0x8ccf904e75bc592df3db236cd171d0caf0b2bbcb"

# Download solc if not present
if [ ! -f "./solc-${SOLC_VERSION}" ]; then
  echo "Downloading solc ${SOLC_VERSION}..."
  PLATFORM=$(uname -s)
  if [ "$PLATFORM" = "Darwin" ]; then
    curl -sL "https://binaries.soliditylang.org/macosx-amd64/solc-macosx-amd64-v${SOLC_VERSION}+commit.${SOLC_COMMIT}" -o "./solc-${SOLC_VERSION}"
  else
    curl -sL "https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v${SOLC_VERSION}+commit.${SOLC_COMMIT}" -o "./solc-${SOLC_VERSION}"
  fi
  chmod +x "./solc-${SOLC_VERSION}"
fi

echo "Compiling CurioCard.sol with solc ${SOLC_VERSION} (no optimizer)..."
COMPILED=$(./solc-${SOLC_VERSION} --bin-runtime CurioCard.sol 2>/dev/null | \
  awk '/= CardToken =/{found=1; next} found && /^[0-9a-f]+$/{print; exit}')

echo "Fetching on-chain runtime bytecode..."
ONCHAIN=$(curl -s "https://api.etherscan.io/api?module=proxy&action=eth_getCode&address=${CONTRACT_ADDR}&tag=latest" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['result'][2:])")

# Strip Swarm hash (last 43 bytes: a165627a7a72305820...0029)
strip_swarm() {
  echo "$1" | sed 's/a165627a7a72305820.\{64\}0029$//'
}

COMPILED_STRIPPED=$(strip_swarm "$COMPILED")
ONCHAIN_STRIPPED=$(strip_swarm "$ONCHAIN")

echo ""
echo "Compiled:  ${#COMPILED_STRIPPED} hex chars ($(( ${#COMPILED_STRIPPED} / 2 )) bytes)"
echo "On-chain:  ${#ONCHAIN_STRIPPED} hex chars ($(( ${#ONCHAIN_STRIPPED} / 2 )) bytes)"
echo ""

if [ "$COMPILED_STRIPPED" = "$ONCHAIN_STRIPPED" ]; then
  echo "✅ EXACT MATCH (excluding Swarm hash)"
else
  echo "❌ MISMATCH"
  exit 1
fi
