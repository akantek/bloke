OUT_DIR = ../out

all: $(OUT_DIR)/bloke.rom

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/bloke.rom: main.asm rom.asm | $(OUT_DIR)
	pasmo ${INCLUDES} rom.asm $(OUT_DIR)/bloke.rom

.PHONY: clean
clean:
	rm -f $(OUT_DIR)/*.rom $(OUT_DIR)/*.bin

