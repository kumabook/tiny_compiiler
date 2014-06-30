DEBUG  = true

STM_FW = ./STM32F4-Discovery_FW_V1.1.0

CC     = arm-none-eabi-gcc
OBJCOPY= arm-none-eabi-objcopy
SIZE   = arm-none-eabi-size

# Project name
PROJECT=$(STM_FW)/Project/Audio_playback_and_record
BIN_NAME=tiny_synth
OUTPATH=bin

MEDIA_SOURCE=FLASH
#MEDIA_SOURCE=USB

# Sources
SRC_DIR = $(PROJECT)/src
SRCS = $(SRC_DIR)/main.c \
	$(SRC_DIR)/stm32f4xx_it.c \
	$(SRC_DIR)/system_stm32f4xx.c \
	$(SRC_DIR)/waveplayer.c

# Library code
SRCS += stm32f4xx_exti.c \
	stm32f4xx_rcc.c \
	stm32f4_discovery.c \
	stm32f4xx_tim.c \
	stm32f4_discovery_lis302dl.c \
	stm32f4_discovery_audio_codec.c \
	misc.c stm32f4xx_adc.c \
	stm32f4xx_dac.c \
	stm32f4xx_dma.c \
	stm32f4xx_flash.c \
	stm32f4xx_gpio.c \
	stm32f4xx_i2c.c \
	stm32f4xx_spi.c \
	stm32f4xx_syscfg.c

ifeq ($(MEDIA_SOURCE), USB)
# USB client
SRCS += $(SRC_DIR)/waverecorder.c \
	$(SRC_DIR)/usb_bsp.c \
	$(SRC_DIR)/usbh_usr.c
# USB library
SRCS += usb_core.c \
	usb_hcd.c \
	usb_hcd_int.c \
	usbh_core.c \
	usbh_hcs.c usbh_ioreq.c \
	usbh_stdreq.c \
	usbh_msc_bot.c \
	usbh_msc_core.c \
	usbh_msc_fatfs.c \
	usbh_msc_scsi.c
# File system library
SRCS += fattime.c ff.c
else # Flash
SRCS += $(SRC_DIR)/audio_sample.c
endif

# add startup file to build
SRCS += $(STM_FW)/Libraries/CMSIS/ST/STM32F4xx/Source/Templates/TrueSTUDIO/startup_stm32f4xx.s 

###################################################

# Choose debug or release
#CFLAGS = -O2           # Normal
CFLAGS = -ggdb -O0       # RSW - for GDB debugging, disable optimizer

CFLAGS += -Wall
#CFLAGS += -T$(PROJECT)/TrueSTUDIO/MEDIA_InFLASH/stm32_flash.ld
CFLAGS += -Tldscripts/stm32_flash.ld

CFLAGS += -DUSE_STDPERIPH_DRIVER
CFLAGS += -DSTM32F4XX
#CFLAGS += -DUSE_ULPI_PHY

ifeq ($(MEDIA_SOURCE), USB)
CFLAGS += -DUSE_USB_OTG_FS
CFLAGS += -DMEDIA_USB_KEY
#CFLAGS += -DUSE_USB_OTG_HS
#CFLAGS += -DUSE_ACCURATE_TIME
else
CFLAGS += -DMEDIA_IntFLASH
endif

ifeq ($(DEBUG), true)
CFLAGS += -DUSE_PRINTF
endif

CFLAGS += -mlittle-endian -mthumb -mthumb-interwork -mcpu=cortex-m4
#CFLAGS += -mfpu=fpv4-sp-d16
#-mfloat-abi=hard
CFLAGS += -lc -lrdimon
CFLAGS += --specs=rdimon.specs


###################################################
vpath %.c src
vpath %.c $(STM_FW)/Libraries/STM32F4xx_StdPeriph_Driver/src \
$(STM_FW)/Libraries/STM32_USB_OTG_Driver/src \
$(STM_FW)/Libraries/STM32_USB_HOST_Library/Core/src \
$(STM_FW)/Libraries/STM32_USB_HOST_Library/Class/MSC/src \
$(STM_FW)/Utilities/STM32F4-Discovery \
$(STM_FW)/Utilities/Third_Party/fat_fs/src

# Includes
CFLAGS += -I$(PROJECT)/inc/

CFLAGS += -I$(STM_FW)/Libraries/CMSIS/ST/STM32F4xx/Include
CFLAGS += -I$(STM_FW)/Libraries/CMSIS/Include
CFLAGS += -I$(STM_FW)/Libraries/STM32F4xx_StdPeriph_Driver/inc
CFLAGS += -I$(STM_FW)/Utilities/STM32F4-Discovery

ifeq ($(MEDIA_SOURCE), USB)
CFLAGS += -I$(STM_FW)/Libraries/STM32_USB_OTG_Driver/inc
CFLAGS += -I$(STM_FW)/Libraries/STM32_USB_HOST_Library/Core/inc
CFLAGS += -I$(STM_FW)/Libraries/STM32_USB_HOST_Library/Class/MSC/inc
CFLAGS += -I$(STM_FW)/Utilities/Third_Party/fat_fs/inc
endif

OBJS = $(SRCS:.c=.o)

LIBPATHS = -L$(STM_FW)/Utilities/STM32F4-Discovery
LIBS = -lPDMFilter_GCC

###################################################
.SUFFIXES: .c .o .h

.PHONY: lib proj

all: proj
	$(SIZE) $(OUTPATH)/$(BIN_NAME).elf

proj: $(OUTPATH)/$(BIN_NAME).elf

$(OUTPATH)/$(BIN_NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ $(LIBPATHS) $(LIBS)
	$(OBJCOPY) -O ihex $(OUTPATH)/$(BIN_NAME).elf $(OUTPATH)/$(BIN_NAME).hex
	$(OBJCOPY) -O binary $(OUTPATH)/$(BIN_NAME).elf $(OUTPATH)/$(BIN_NAME).bin

run_debug: proj
	arm-none-eabi-gdb -x .gdbinit_stm32f4

clean:
	find . -name \*.o -type f -delete
	find . -name \*.d -type f -delete
	find . -name \*.lst -type f -delete
	rm -f $(OUTPATH)/$(BIN_NAME).elf
	rm -f $(OUTPATH)/$(BIN_NAME).hex
	rm -f $(OUTPATH)/$(BIN_NAME).bin
