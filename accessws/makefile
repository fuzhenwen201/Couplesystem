TARGET  := accessws.exe
INCS = -I ../network -I ../utils
LIBS = -L ../utils -lutils -L ../network -lnetwork -Wl,-Bstatic -lev -ljansson -lmpdec -lrdkafka -lz -lcurl -lssl -lcrypto -lhiredis -Wl,-Bdynamic -lm -lpthread -ldl
include ../makefile.inc
