# 
# Copyright 2015 Patrick D. M. Siegl
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

TARGET	:= main.elf e_main.srec
default: $(TARGET)

DEPS := $(shell ls .dep_*)
-include $(DEPS)

## ACC  #################
C_PERF := -O3
C_SIZE := -ffunction-sections -fdata-sections
e_%.o: e_%.c
	e-gcc ${C_PERF} ${C_SIZE} -Wall -Wunused-variable -MMD -MF".dep_$@.d" -c -o $@ $<

L_SIZE := -Wl,-static -Wl,-s -Wl,--gc-sections
e_%.elf: e_%.o
	e-gcc -T $(EPIPHANY_HOME)/bsps/current/internal.ldf ${L_SIZE} -o $@ $< -le-lib
	@e-size $@

e_%.srec: e_%.elf
	e-objcopy --srec-forceS3 --output-target srec $^ $@

## HOST #################
%.elf: %.o
	gcc -L ${EPIPHANY_HOME}/tools/host.armv7l/lib -o $@ $< -lm -le-hal -le-loader
	@size $@

%.o: %.c
	gcc -O3 -mfpu=neon -I $(EPIPHANY_HOME)/tools/host.armv7l/include -MMD -MF".dep_$@.d" -c -o $@ $<

## RUN  #################
ELIBS=${ESDK}/tools/host.armv7l/lib:${LD_LIBRARY_PATH}
EHDF=${EPIPHANY_HDF}
run: $(TARGET)
	sudo -E LD_LIBRARY_PATH=${ELIBS} EPIPHANY_HDF=${EHDF} ./main.elf


clean:
	rm -rf $(TARGET) .dep* *.o *.elf *.log
