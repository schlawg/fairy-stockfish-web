CXX = em++
EXE = fairyStockfishWeb

OPT ?= -O3 -DNDEBUG --closure=1
# override OPT as a command line argument as in:
#   make node OPT="-O0 -g3 -sASSERTIONS=2 -sSAFE_HEAP --source-map-base=http://localhost:9090/src/"

CXX_FLAGS = $(OPT) -Isrc -Isrc/wasm -pthread -msse -msse2 -mssse3 -msse4.1 -msimd128 -flto \
	-fno-exceptions -DUSE_SSE2 -DUSE_SSSE3 -DUSE_SSE41 -DUSE_POPCNT -DNNUE_EMBEDDING_OFF
	
LD_FLAGS = $(CXX_FLAGS)  --pre-js=src/wasm/initModule.js -sEXPORT_ES6 -sEXPORT_NAME=FairyStockfishWeb \
	-sEXPORTED_FUNCTIONS='[_malloc]' -sEXPORTED_RUNTIME_METHODS='[stringToUTF8,UTF8ToString]' \
	-sINCOMING_MODULE_JS_API='[locateFile,print,printErr,wasmMemory,buffer,instantiateWasm]' \
	-sINITIAL_MEMORY=64MB -sALLOW_MEMORY_GROWTH -sSTACK_SIZE=2MB -sFILESYSTEM=0 -sSTRICT \
	-sALLOW_BLOCKING_ON_MAIN_THREAD=0 -sPROXY_TO_PTHREAD

SOURCES = benchmark.cpp bitbase.cpp bitboard.cpp endgame.cpp evaluate.cpp main.cpp material.cpp \
	misc.cpp movegen.cpp movepick.cpp nnue/evaluate_nnue.cpp nnue/features/half_ka_v2.cpp \
	nnue/features/half_ka_v2_variants.cpp parser.cpp partner.cpp pawns.cpp piece.cpp position.cpp \
	psqt.cpp search.cpp thread.cpp timeman.cpp tt.cpp tune.cpp uci.cpp ucioption.cpp variant.cpp \
	xboard.cpp wasm/glue.cpp

OBJS = $(addprefix src/, $(SOURCES:.cpp=.o))

.PHONY: build node clean

build: TARGET_FLAGS = -sENVIRONMENT=web,worker -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency
build: $(EXE)

node: TARGET_FLAGS = -sENVIRONMENT=node
node: $(EXE)
	@cat src/wasm/createRequire.js $(EXE).worker.js > $(EXE).worker.js.tmp
	@mv $(EXE).worker.js.tmp $(EXE).worker.js

$(EXE): $(OBJS)
	$(CXX) -o $@.js $(OBJS) $(LD_FLAGS) $(TARGET_FLAGS)

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) -c $< -o $@

clean:
	@rm -f $(OBJS) $(EXE).js $(EXE).wasm* $(EXE).worker.js
