make clean
make

echo "Removing the old srec files"
rm *.srec

echo "Creating the srec files"

e-objcopy --srec-forceS3  --output-target srec rowSort.elf rowSort.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec scale.elf scale.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec combineRow.elf combineRow.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec shuffleFlyRow.elf shuffleFlyRow.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec shuffleRow.elf shuffleRow.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec finalRow.elf finalRow.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec transpose.elf transpose.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec scaleCol.elf scaleCol.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec combineCol.elf combineCol.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec shuffleFlyCol.elf shuffleFlyCol.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec shuffleCol.elf shuffleCol.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec finalCol.elf finalCol.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec shift.elf shift.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec reTrans.elf reTrans.srec
e-objcopy --srec-forceS3 -R .shared_dram --output-target srec clip.elf clip.srec

echo "srec files are created"
