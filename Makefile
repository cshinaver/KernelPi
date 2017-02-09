CC = arm-none-eabi-gcc
KERNEL_NAME = kernel
MCPU = cortex-a53
OBJ_FILES = $(KERNEL_NAME).bin $(KERNEL_NAME).elf boot.o kernel.o

# Copy elf into binary
$(KERNEL_NAME).bin: $(KERNEL_NAME).elf
	arm-none-eabi-objcopy $< -O binary $@


# Link kernel
$(KERNEL_NAME).elf: linker.ld boot.o kernel.o
	 $(CC) -T linker.ld -o $@ -ffreestanding -O2 -nostdlib boot.o kernel.o

# Bootloader in front of kernel
boot.o: boot.S
	$(CC) -mcpu=$(MCPU) -fpic -ffreestanding -c $< -o $@

# Kernel compiling
kernel.o: kernel.c
	$(CC) -mcpu=$(MCPU) -fpic -ffreestanding -std=gnu99 -c $< -o $@ -O2 -Wall -Wextra

clean:
	rm $(OBJ_FILES)

simulate: $(KERNEL_NAME).elf
	qemu-system-arm -kernel $< -m 256 -M raspi2 -serial stdio
