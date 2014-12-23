################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/e_hello_world.c 

OBJS += \
./src/e_hello_world.o 

C_DEPS += \
./src/e_hello_world.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Epiphany Compiler'
	e-gcc -O0 -g3 -Wall -c -fmessage-length=0 -ffp-contract=fast -mlong-calls -mfp-mode=round-nearest -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


