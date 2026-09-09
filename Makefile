# M1 Meshtastic — .m1app build
#
#   make            # builds m1-meshtastic.m1app
#   make clean
#
# Requires arm-none-eabi-gcc (10+). Output: m1-meshtastic.m1app -> copy to
# 0:/apps/ on the M1 SD card. Needs the matching firmware patch (see firmware/).

PREFIX  ?= arm-none-eabi-
CC       = $(PREFIX)gcc
SIZE     = $(PREFIX)size
LIBGCC  := $(shell $(CC) -mcpu=cortex-m33 -mthumb -mfloat-abi=soft -print-libgcc-file-name)

APP_NAME = m1-meshtastic
OUTPUT   = $(APP_NAME).m1app

SRCS  = $(wildcard src/*.c)
SRCS += $(wildcard lib/nanopb/*.c)
SRCS += $(wildcard lib/meshtastic_api/meshtastic/*.c)
OBJS  = $(SRCS:.c=.o)

INCLUDES = -Isrc -Iinclude -I. -Ilib/nanopb -Ilib/meshtastic_api

CFLAGS   = -mcpu=cortex-m33 -mthumb -mfloat-abi=soft
CFLAGS  += -mword-relocations -mlong-calls
CFLAGS  += -fno-common -fdata-sections -ffunction-sections
CFLAGS  += -Os -g -Wall -Wextra
CFLAGS  += $(INCLUDES)
CFLAGS  += -nostdlib -nostartfiles

LDFLAGS  = -mcpu=cortex-m33 -mthumb -mfloat-abi=soft
LDFLAGS += -nostdlib -nostartfiles
LDFLAGS += -Wl,-Ur
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-e,app_main
LDFLAGS += -Tlinker/m1app.ld

all: $(OUTPUT)
	@echo ""
	@echo "Built: $(OUTPUT)"
	@$(SIZE) $(OUTPUT)

$(OUTPUT): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBGCC)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(OUTPUT)

.PHONY: all clean
