################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/fsbl_hooks.c \
../src/image_mover.c \
../src/main.c \
../src/md5.c \
../src/nand.c \
../src/nor.c \
../src/pcap.c \
/tmp/v/parviv/parallella_7020_headless_gpiose_elink2.sdk/elink2_top_wrapper_hw_platform_0/ps7_init.c \
../src/qspi.c \
../src/rsa.c \
../src/sd.c 

S_UPPER_SRCS += \
../src/fsbl_handoff.S 

OBJS += \
./src/fsbl_handoff.o \
./src/fsbl_hooks.o \
./src/image_mover.o \
./src/main.o \
./src/md5.o \
./src/nand.o \
./src/nor.o \
./src/pcap.o \
./src/ps7_init.o \
./src/qspi.o \
./src/rsa.o \
./src/sd.o 

S_UPPER_DEPS += \
./src/fsbl_handoff.d 

C_DEPS += \
./src/fsbl_hooks.d \
./src/image_mover.d \
./src/main.d \
./src/md5.d \
./src/nand.d \
./src/nor.d \
./src/pcap.d \
./src/ps7_init.d \
./src/qspi.d \
./src/rsa.d \
./src/sd.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -I"/tmp/v/parviv/parallella_7020_headless_gpiose_elink2.sdk/elink2_top_wrapper_hw_platform_0" -c -fmessage-length=0 -MT"$@" -I../../fsbl_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -I"/tmp/v/parviv/parallella_7020_headless_gpiose_elink2.sdk/elink2_top_wrapper_hw_platform_0" -c -fmessage-length=0 -MT"$@" -I../../fsbl_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/ps7_init.o: /tmp/v/parviv/parallella_7020_headless_gpiose_elink2.sdk/elink2_top_wrapper_hw_platform_0/ps7_init.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM gcc compiler'
	arm-xilinx-eabi-gcc -Wall -O0 -g3 -I"/tmp/v/parviv/parallella_7020_headless_gpiose_elink2.sdk/elink2_top_wrapper_hw_platform_0" -c -fmessage-length=0 -MT"$@" -I../../fsbl_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


