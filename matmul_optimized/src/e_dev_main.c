/*
   e_dev_main.c
   Copyright (C) 2012 Adapteva, Inc.
   Contributed by Yaniv Sapir <yaniv@adapteva.com>, Aug 2013
   Modified by: Anish Varghese <anish.varghese@anu.edu.au>, May 2014

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program, see the file COPYING.  If not, see
   <http://www.gnu.org/licenses/>.

Description:
    This is part of the device side code for single core matmul.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "e_lib.h"
#include "defs.h"

int matmul_main (Mailbox* mailbox);

Mailbox mailbox SECTION("shared_dram");

int main(void) {
	//e_coreid_t coreid;

	//// Who am I? Query the CoreID from hardware.
	//coreid = e_get_coreid();

    mailbox.result = matmul_main(&mailbox);
    
    mailbox.flag = 1;
    mailbox.coreid = 0x808;
    //mailbox.coreid = coreid;
	return EXIT_SUCCESS;
}
