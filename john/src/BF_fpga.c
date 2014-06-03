/*
 * This file is part of John the Ripper password cracker,
 * Copyright (c) 2014 by Katja Malvoni <kmalvoni at gmail dot com>
 * It is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, 
 * with or without modification, are permitted.
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>

#include "arch.h"
#include "common.h"
#include "BF_std.h"
#include "FPGA.h"

void FPGA_reset()
{
	int memfd_2;
	void *mapped_base_2, *mapped_dev_base_2;
	off_t dev_base_2 = BCRYPT;
	unsigned int RegValue;

	memfd_2 = open("/dev/mem", O_RDWR | O_SYNC);
	if (memfd_2 == -1) {
		printf("Can't open /dev/mem.\n");
		exit(0);
	}
	mapped_base_2 = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd_2, dev_base_2 & ~MAP_MASK);
	if (mapped_base_2 == (void *) -1) {
		printf("Can't map the memory to user space.\n");
		exit(0);
	}
	mapped_dev_base_2 = mapped_base_2 + (dev_base_2 & MAP_MASK);

	/*Software reset*/
	RegValue = 0;
	*((volatile unsigned short *)mapped_dev_base_2 + 0x0) = RegValue;
	
	if (munmap(mapped_base_2, MAP_SIZE) == -1) {
		printf("Can't unmap memory from user space.\n");
		exit(0);
	}
	close(memfd_2);
}

void FPGA_start()
{
	int memfd_2;
	void *mapped_base_2, *mapped_dev_base_2;
	off_t dev_base_2 = BCRYPT;
	unsigned int RegValue;
	
	memfd_2 = open("/dev/mem", O_RDWR | O_SYNC);
	if (memfd_2 == -1) {
		printf("Can't open /dev/mem.\n");
		exit(0);
	}
	mapped_base_2 = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd_2, dev_base_2 & ~MAP_MASK);
	if (mapped_base_2 == (void *) -1) {
		printf("Can't map the memory to user space.\n");
		exit(0);
	}
	mapped_dev_base_2 = mapped_base_2 + (dev_base_2 & MAP_MASK);
	
	/*Start computation*/
	RegValue = (unsigned int)1;
	*((volatile unsigned long *)mapped_dev_base_2 + 0x0) = RegValue;
	
	if (munmap(mapped_base_2, MAP_SIZE) == -1) {
		printf("Can't unmap memory from user space.\n");
		exit(0);
	}
	close(memfd_2);
}

void FPGA_done()
{
	int memfd_2;
	void *mapped_base_2, *mapped_dev_base_2;
	off_t dev_base_2 = BCRYPT;
	unsigned int RegValue;
	
	memfd_2 = open("/dev/mem", O_RDWR | O_SYNC);
	if (memfd_2 == -1) {
		printf("Can't open /dev/mem.\n");
		exit(0);
	}
	mapped_base_2 = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd_2, dev_base_2 & ~MAP_MASK);
	if (mapped_base_2 == (void *) -1) {
		printf("Can't map the memory to user space.\n");
		exit(0);
	}
	mapped_dev_base_2 = mapped_base_2 + (dev_base_2 & MAP_MASK);
	
	/*Wait for done*/
	do {
		RegValue = *((volatile unsigned int*)(mapped_dev_base_2 + 4));
	} while(RegValue != 0xFF);
	
	if (munmap(mapped_base_2, MAP_SIZE) == -1) {
		printf("Can't unmap memory from user space.\n");
		exit(0);
	}
	close(memfd_2);
}

void FPGA_transfer_data(FPGA_data *src, direction dir, unsigned int offset)
{
	int memfd;
	void *mapped_base, *mapped_dev_base;
	off_t dev_base = BCRYPT_S;

	int memfd_1;
	void *mapped_base_1, *mapped_dev_base_1;
	off_t dev_base_1 = BCRYPT_OTHERS;
	
	memfd = open("/dev/mem", O_RDWR | O_SYNC);
	if (memfd == -1) {
		printf("Can't open /dev/mem.\n");
		exit(0);
	}
	mapped_base = mmap(0, MAP_SIZE_S, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, dev_base & ~MAP_MASK_S);
	if (mapped_base == (void *) -1) {
		printf("Can't map the memory to user space.\n");
		exit(0);
	}
	mapped_dev_base = mapped_base + (dev_base & MAP_MASK_S);
	
	memfd_1 = open("/dev/mem", O_RDWR | O_SYNC);
	if (memfd_1 == -1) {
		printf("Can't open /dev/mem.\n");
		exit(0);
	}
	mapped_base_1 = mmap(0, MAP_SIZE_OTHERS, PROT_READ | PROT_WRITE, MAP_SHARED, memfd_1, dev_base_1 & ~MAP_MASK_OTHERS);
	if (mapped_base_1 == (void *) -1) {
		printf("Can't map the memory to user space.\n");
		exit(0);
	}
	mapped_dev_base_1 = mapped_base_1 + (dev_base_1 & MAP_MASK_OTHERS);
	
	if(dir == HOST_TO_FPGA) {
		memcpy(mapped_dev_base_1, &src->data[offset], sizeof(BF_word) * 64 * BF_N);
		memcpy(mapped_dev_base, src->S[offset], sizeof(BF_word) * 1024 * BF_N);
	} else {
		memcpy(&src->data[offset], mapped_dev_base_1, sizeof(BF_word) * 64 * BF_N);
		memcpy(src->S[offset], mapped_dev_base, sizeof(BF_word) * 1024 * BF_N);
	}

	if (munmap(mapped_base, MAP_SIZE_S) == -1) {
		printf("Can't unmap memory from user space.\n");
		exit(0);
	}
	close(memfd);
	
	if (munmap(mapped_base_1, MAP_SIZE_OTHERS) == -1) {
		printf("Can't unmap memory from user space.\n");
		exit(0);
	}
	close(memfd_1);
}
