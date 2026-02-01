#!/bin/bash
# masreceipt-extid-finder.sh
#
# No-dependency (stock macOS) MASReceipt parser using openssl.
#
# Extracts:
#   - bundle_id (type 2, UTF8STRING)
#   - application_version (type 3, UTF8STRING)
#   - app_item_id (type 1, INTEGER)
#   - app_external_id (type 16 preferred, fallback type 1000 / 0x03E8)
#
# Usage:
#   sudo bash masreceipt-extid-finder.sh "/Applications/SomeApp.app"
#   sudo bash masreceipt-extid-finder.sh "/path/to/SomeApp.app/Contents/_MASReceipt/receipt"
#
# Compatibility note:
#   This script is written to work with macOS's default BSD awk (e.g., "awk version 20200816")
#   and avoids bracketed whitespace classes like /[ \t]/ which can break if a literal tab is
#   introduced during copy/download.

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  sudo bash masreceipt-extid-finder.sh "/Applications/SomeApp.app"
  sudo bash masreceipt-extid-finder.sh "/path/to/SomeApp.app/Contents/_MASReceipt/receipt"

Output:
  bundle_id: <string>
  application_version: <string>
  app_item_id: <decimal integer | (not found)>
  app_external_id: <decimal integer | (not found)>

Notes:
  - Uses only built-in macOS tools (bash/openssl/awk).
  - app_external_id is commonly receipt field type 16 (0x10). Some receipts may omit it.
EOF
}

INPUT="${1:-}"
if [[ -z "$INPUT" ]] || [[ "$INPUT" == "-h" ]] || [[ "$INPUT" == "--help" ]]; then
  usage
  exit 1
fi

if [[ "$INPUT" == *.app ]]; then
  REC="$INPUT/Contents/_MASReceipt/receipt"
else
  REC="$INPUT"
fi

if [[ ! -f "$REC" ]]; then
  echo "Receipt not found: $REC" >&2
  exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

PAYLOAD="$TMPDIR/payload.der"

if ! openssl smime -inform der -verify -noverify -in "$REC" -out "$PAYLOAD" >/dev/null 2>&1; then
  echo "Failed to unwrap CMS container with openssl." >&2
  exit 3
fi

DUMP="$(openssl asn1parse -inform der -in "$PAYLOAD" 2>/dev/null || true)"
if [[ -z "$DUMP" ]]; then
  echo "Failed to parse ASN.1 payload." >&2
  exit 4
fi

# Walk each attribute SEQUENCE:
#   cons: SEQUENCE
#     prim: INTEGER :<type>
#     prim: INTEGER :01          (attribute version)
#     prim: OCTET STRING ...
# Return OCTET STRING's numeric offset for the requested type.
find_attr_octet_offset() {
  local want_hex="$1"
  local want=":$want_hex"
  printf "%s
" "$DUMP" | awk -v want="$want" '
    BEGIN {inseq=0; t=""; v=""; }
    /cons: SEQUENCE/ {inseq=1; t=""; v=""; next}
    inseq && /prim: INTEGER/ && t=="" {
      if ($0 ~ want"$") {t="hit"} else {t="miss"}
      next
    }
    inseq && /prim: INTEGER/ && v=="" {
      if ($0 ~ /:01$/) {v="ok"} else {v="bad"}
      next
    }
    inseq && /OCTET STRING/ {
      if (t=="hit" && v=="ok") {
        split($1, a, ":")
        print a[1]
        exit
      }
      inseq=0
    }
  '
}

# Extract UTF8STRING value from the attribute's OCTET STRING wrapper.
# Trimming is done with plain-space regexes only (no tabs/char-classes).
extract_attr_string() {
  local oct_off="$1"
  local inner="$TMPDIR/inner_str.der"
  openssl asn1parse -inform der -in "$PAYLOAD" -strparse "$oct_off" -out "$inner" >/dev/null 2>&1 || return 1
  openssl asn1parse -inform der -in "$inner" 2>/dev/null | awk -F':' '
    /UTF8STRING/ {
      v=$NF
      sub(/^ +/, "", v)
      sub(/ +$/, "", v)
      print v
      exit
    }
  '
}

# Extract INTEGER value from the attribute's OCTET STRING wrapper and convert hex -> decimal.
# Trimming uses plain-space regexes only.
extract_attr_int_decimal() {
  local oct_off="$1"
  local inner="$TMPDIR/inner_int.der"
  openssl asn1parse -inform der -in "$PAYLOAD" -strparse "$oct_off" -out "$inner" >/dev/null 2>&1 || return 1
  local hex
  hex="$(openssl asn1parse -inform der -in "$inner" 2>/dev/null | awk -F':' '
    /INTEGER/ {h=$NF}
    END {
      sub(/^ +/, "", h)
      sub(/ +$/, "", h)
      print h
    }
  ')"
  [[ -n "${hex:-}" ]] || return 1
  printf "%d
" "0x$hex"
}

# bundle_id (type 2), application_version (type 3), app_item_id (type 1)
OCT_BUNDLE="$(find_attr_octet_offset "02" || true)"
OCT_APPVER="$(find_attr_octet_offset "03" || true)"
OCT_ITEMID="$(find_attr_octet_offset "01" || true)"

BUNDLE_ID=""; APP_VERSION=""; APP_ITEM_ID="(not found)"

if [[ -n "${OCT_BUNDLE:-}" ]]; then BUNDLE_ID="$(extract_attr_string "$OCT_BUNDLE" || true)"; fi
if [[ -n "${OCT_APPVER:-}" ]]; then APP_VERSION="$(extract_attr_string "$OCT_APPVER" || true)"; fi
if [[ -n "${OCT_ITEMID:-}" ]]; then APP_ITEM_ID="$(extract_attr_int_decimal "$OCT_ITEMID" || echo "(not found)")"; fi

if [[ -z "$BUNDLE_ID" ]] || [[ -z "$APP_VERSION" ]]; then
  echo "Failed to decode bundle_id and/or application_version values." >&2
  exit 5
fi

# app_external_id: type 16 (0x10) preferred, fallback 1000 (0x03E8)
APP_EXT_ID="(not found)"

OCT_EXT16="$(find_attr_octet_offset "10" || true)"
if [[ -n "${OCT_EXT16:-}" ]]; then
  APP_EXT_ID="$(extract_attr_int_decimal "$OCT_EXT16" || echo "(not found)")"
fi

if [[ "$APP_EXT_ID" == "(not found)" ]]; then
  OCT_EXT1000="$(find_attr_octet_offset "03E8" || true)"
  if [[ -n "${OCT_EXT1000:-}" ]]; then
    APP_EXT_ID="$(extract_attr_int_decimal "$OCT_EXT1000" || echo "(not found)")"
  fi
fi

echo "bundle_id: $BUNDLE_ID"
echo "application_version: $APP_VERSION"
echo "app_item_id: $APP_ITEM_ID"
echo "app_external_id: $APP_EXT_ID"
exit 0
