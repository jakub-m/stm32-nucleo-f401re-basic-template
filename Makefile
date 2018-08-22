CC      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

PROJECT_NAME = nucleo

PROJECT_SRC = src
STM_SRC = Drivers/STM32F4xx_HAL_Driver/Src/
USB_CORE_SRC = Drivers/STM32_USB_Device_Library/Core/Src
USB_HID_SRC = Drivers/STM32_USB_Device_Library/Class/HID/Src/
FREERTOS_SOURCE = FreeRTOS/Source

vpath %.c $(PROJECT_SRC)
vpath %.c $(STM_SRC)
vpath %.c $(USB_CORE_SRC)
vpath %.c $(USB_HID_SRC)
vpath %.c $(FREERTOS_SOURCE)

SRCS  = main.c
SRCS += logger.c

SRCS += Device/startup_stm32f401xe.s

SRCS += stm32f4xx_hal_msp.c
SRCS += stm32f4xx_hal_tim.c
SRCS += stm32f4xx_it.c
SRCS += system_stm32f4xx.c
SRCS += usbd_conf.c
SRCS += usbd_desc.c
SRCS += newlib_stubs.c

# FreeRTOS
SRCS += croutine.c
SRCS += list.c
SRCS += queue.c
SRCS += event_groups.c
SRCS += timers.c
SRCS += tasks.c
SRCS += stream_buffer.c
SRCS += portable/GCC/ARM_CM4F/port.c
SRCS += portable/MemMang/heap_1.c

EXT_SRCS = stm32f4xx_hal.c
EXT_SRCS += stm32f4xx_hal_rcc.c
EXT_SRCS += stm32f4xx_hal_gpio.c
EXT_SRCS += stm32f4xx_hal_cortex.c
EXT_SRCS += stm32f4xx_hal_pcd.c
EXT_SRCS += stm32f4xx_hal_pcd_ex.c
EXT_SRCS += stm32f4xx_ll_usb.c

EXT_SRCS += usbd_core.c
EXT_SRCS += usbd_ctlreq.c
EXT_SRCS += usbd_ioreq.c
EXT_SRCS += usbd_hid.c

EXT_OBJ = $(EXT_SRCS:.c=.o)

INC_DIRS  = inc/
INC_DIRS += Drivers/STM32F4xx_HAL_Driver/Inc/
INC_DIRS += Drivers/STM32_USB_Device_Library/Core/Inc/
INC_DIRS += Drivers/STM32_USB_Device_Library/Class/HID/Inc/
INC_DIRS += Drivers/CMSIS/Device/ST/STM32F4xx/Include/
INC_DIRS += Drivers/CMSIS/Include/
INC_DIRS += FreeRTOS/Source/include
INC_DIRS += FreeRTOS/Source/portable/GCC/ARM_CM4F

INCLUDE = $(addprefix -I,$(INC_DIRS))

DEFS = -DSTM32F401xE

CFLAGS  = -ggdb -O0
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork -Wl,--gc-sections
CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -std=gnu90 -ffunction-sections -fdata-sections

WFLAGS += -Wall -Wextra -Warray-bounds -Wno-unused-parameter

LFLAGS = -TDevice/gcc.ld

.PHONY: all
all: $(PROJECT_NAME)

.PHONY: $(PROJECT_NAME) indent

indent:
	indent -linux \
	src/main.c \
	src/logger.c

$(PROJECT_NAME): $(PROJECT_NAME).elf

$(PROJECT_NAME).elf: $(SRCS) $(EXT_OBJ)
	$(CC) $(INCLUDE) $(DEFS) $(CFLAGS) $(WFLAGS) $(LFLAGS) $^ -o $@
	$(OBJCOPY) -O ihex $(PROJECT_NAME).elf   $(PROJECT_NAME).hex
	$(OBJCOPY) -O binary $(PROJECT_NAME).elf $(PROJECT_NAME).bin

%.o: %.c
	$(CC) -c -o $@ $(INCLUDE) $(DEFS) $(CFLAGS) $^

clean:
	rm -f *.o $(PROJECT_NAME).elf $(PROJECT_NAME).hex $(PROJECT_NAME).bin
