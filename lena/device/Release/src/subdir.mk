################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/dmalib.c \
../src/fft2d_main.c \
../src/fft2dlib.c \
../src/static_buffers.c 

OBJS += \
./src/dmalib.o \
./src/fft2d_main.o \
./src/fft2dlib.o \
./src/static_buffers.o 

C_DEPS += \
./src/dmalib.d \
./src/fft2d_main.d \
./src/fft2dlib.d \
./src/static_buffers.d 


# Each subdirectory must supply rules for building sources it contributes
src/fft2d_main.o: ../src/fft2d_main.c
	@echo 'Building file: $<'
	@echo 'Invoking: Epiphany Compiler'
	e-gcc -D_USE_DMA_E_ -D_USE_DMA_I_ -I"../src" -O1 -Wall -c -fmessage-length=0 -std=c99 -ffp-contract=fast -mlong-calls -mfp-mode=round-nearest -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/static_buffers.o: ../src/static_buffers.c
	@echo 'Building file: $<'
	@echo 'Invoking: Epiphany Compiler'
	e-gcc -D_USE_DMA_E_ -D_USE_DMA_I_ -I"../src" -O1 -Wall -c -fmessage-length=0 -std=c99 -ffp-contract=fast -mlong-calls -mfp-mode=round-nearest -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/dmalib.o: ../src/dmalib.c
	@echo 'Building file: $<'
	@echo 'Invoking: Epiphany Compiler'
	e-gcc -D_USE_DMA_E_ -D_USE_DMA_I_ -I"../src" -O1 -Wall -c -fmessage-length=0 -std=c99 -ffp-contract=fast -mlong-calls -mfp-mode=round-nearest -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/fft2dlib.o: ../src/fft2dlib.c
	@echo 'Building file: $<'
	@echo 'Invoking: Epiphany Compiler'
	e-gcc -D_USE_DMA_E_ -D_USE_DMA_I_ -I"../src" -O1 -Ofast -falign-loops=8 -falign-functions=8 -ffinite-math-only -ffast-math -Wall -c -fmessage-length=0 -std=c99 -ffp-contract=fast -mlong-calls -mfp-mode=round-nearest -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"src/fft2dlib.d" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


