BUILD_DIR=./build
TARGET_DIR=./out

RM=rm -f
RM_RF=rm -rf

SD_CARD_PATH=/Volumes/F256K_MAIN3
SD_CARD_UNMOUNT_COMMAND=diskutil unmountDisk /dev/disk4

all: livingworlds.bin livingworlds.pgz

$(BUILD_DIR):
	mkdir -p $@

$(TARGET_DIR):
	mkdir -p $@

ensure_dirs: $(BUILD_DIR) $(TARGET_DIR)

livingworlds.bin: ensure_dirs fnx/api.asm fnx/livingworlds.s
	64tass --long-address --flat -b --m65816 -o $(TARGET_DIR)/livingworlds.bin --list=$(BUILD_DIR)/livingworlds.lst --labels=$(BUILD_DIR)/livingworlds.lbl fnx/livingworlds.s

livingworlds.pgz: ensure_dirs fnx/api.asm fnx/livingworlds.pgz.s
	64tass --long-address --flat -b --m65816 -o $(TARGET_DIR)/livingworlds.pgz --list=$(BUILD_DIR)/livingworlds.lst --labels=$(BUILD_DIR)/livingworlds.lbl fnx/livingworlds.pgz.s

copy2sd: livingworlds.pgz
	cp $(TARGET_DIR)/livingworlds.pgz $(SD_CARD_PATH)/
	$(SD_CARD_UNMOUNT_COMMAND)

clean:
	$(RM_RF) $(BUILD_DIR)
	$(RM_RF) $(TARGET_DIR)
