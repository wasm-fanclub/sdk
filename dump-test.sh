set -euo pipefail

: ${DUMP_ROOT:=$HOME}
IN_DIRECTORY="src"

IN_WAT_FILENAME="IN_test.wat"
IN_C_FILENAME="IN_test.c"

MD_WASM_FILENAME="MD_test.wasm"
MD_C_FILENAME="MD_test.c"

OUT_DIRECTORY="build_test"

OUT_JS_FILENAME="OUT_test.js"
OUT_WASM_FILENAME="OUT_test.wasm"

rm -rf "$DUMP_ROOT/$IN_DIRECTORY"
mkdir -p "$DUMP_ROOT/$IN_DIRECTORY/$OUT_DIRECTORY"

cd "$DUMP_ROOT/$IN_DIRECTORY"

# Create input files
cat > "$IN_WAT_FILENAME" << 'EOF'
(module
  (func (export "add") (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add)
  (func (export "main") (result i32)
    i32.const 40
    i32.const 2
    call 0))
EOF
cat > "$IN_C_FILENAME" << 'EOF'
int add(int a, int b) {
  return a + b;
}

int main(void) {
  return add(40, 2);
}
EOF

# Generate intermediate WASM from WAT
wat2wasm "$IN_WAT_FILENAME" -o "$MD_WASM_FILENAME"
# Generate intermediate C from WASM
wasm2c "$MD_WASM_FILENAME" -o "$MD_C_FILENAME"

# Compile intermediate C to JS and WASM
mkdir -p "$OUT_DIRECTORY/emcc"

MD_BASENAME="${MD_C_FILENAME%.*}"
EXPORT_PREFIX="${MD_BASENAME//_/__}"
emcc "$MD_C_FILENAME" "$WABT_HOME/wasm2c/wasm-rt-impl.c" \
  -I$WABT_HOME/wasm2c \
  -o "$OUT_DIRECTORY/emcc/$OUT_JS_FILENAME" \
  -s WASM=1 \
  -s EXPORTED_FUNCTIONS="[\"_w2c_${EXPORT_PREFIX}_main\",\"_w2c_${EXPORT_PREFIX}_add\"]" \
  -s EXPORTED_RUNTIME_METHODS='["cwrap"]' \
  -O2 -g2

# Compile intermediate C to WASI WASM
mkdir -p "$OUT_DIRECTORY/wasi"
clang --target=wasm32-wasi --sysroot=$WASI_SYSROOT \
  "$MD_C_FILENAME" "$WABT_HOME/wasm2c/wasm-rt-impl.c" \
  -D_WASI_EMULATED_MMAN \
  -I$WABT_HOME/wasm2c \
  -o "$OUT_DIRECTORY/wasi/$OUT_WASM_FILENAME" \
  -mllvm -wasm-enable-sjlj -lwasi-emulated-mman \
  -O2

# Compile basic C to core WASM
mkdir -p "$OUT_DIRECTORY/wasm"
clang --target=wasm32-unknown-unknown \
  "$IN_C_FILENAME" \
  -nostdlib -Wl,--no-entry -Wl,--export-all \
  -o "$OUT_DIRECTORY/wasm/$OUT_WASM_FILENAME" \
  -O2

# Dump the outputs
echo ""
echo -e "\033[1;31m===== EMCC JS Output =====\033[0m"
cat $OUT_DIRECTORY/emcc/$OUT_JS_FILENAME

echo ""
echo -e "\033[1;31m===== EMCC WASM Output =====\033[0m"
wasm-objdump -x $OUT_DIRECTORY/emcc/$OUT_WASM_FILENAME
echo ""
echo -e "\033[1;31m===== WASI WASM Output =====\033[0m"
wasm-objdump -x $OUT_DIRECTORY/wasi/$OUT_WASM_FILENAME
echo ""
echo -e "\033[1;31m===== CORE WASM Output =====\033[0m"
wasm-objdump -x $OUT_DIRECTORY/wasm/$OUT_WASM_FILENAME