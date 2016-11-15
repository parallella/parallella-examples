/*
 * This file is part of John the Ripper password cracker,
 * Copyright (c) 2013 by Katja Malvoni <kmalvoni at gmail dot com>
 * It is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, 
 * with or without modification, are permitted.
 */

/* ANSI concatenation macros.  */
#define CONCAT1(a, b) CONCAT2(a, b)
#define CONCAT2(a, b) a ## b
/* Use the right prefix for global labels.  */
#define SYM(x) CONCAT1 (__USER_LABEL_PREFIX__, x)


#define ctx0		r0
#define ctx1		r1
#define L0		r23
#define R0		r12
#define L1		r55
#define R1		r56
#define tmpa1		r57
#define tmpb1		r61
#define tmpa2		r22
#define tmpb2		r47
#define tmpa3		r54
#define tmpb3		r63
#define tmpa4		r24
#define tmpb4		r60
#define tmp		r44
#define c1		r58
#define c2		r59
#define c3		r62
#define P0		r45
#define S00		r26
#define S01		r16
#define S02		r17
#define S03		r18
#define P1		r46
#define S10		r19
#define S11		r20
#define S12		r21
#define S13		r25
#define ptr0		r2
#define ptr1		r27
#define end		r3

.text
.global SYM(BF_encrypt2)
.type SYM(BF_encrypt2), @function

.macro BF2_2ROUND_A
	and tmpa1, L0, c1
	lsr tmpa3, L0, 0xe 
	and tmpa3, tmpa3, c2
	lsr tmpa4, L0, 0x16 
	and tmpa4, tmpa4, c2
	imul tmpa1, tmpa1, c3
	ldr tmpa3, [S01, +tmpa3] 
	ldr tmpa4, [S00, +tmpa4] 
	lsr tmpa2, L0, 6 
	and tmpa2, tmpa2, c2
	iadd tmpa3, tmpa4, tmpa3 
	ldr tmpa2, [S02, +tmpa2] 
	ldr tmp, [P0], 0x1 
	ldr tmpa1, [S03, +tmpa1] 
	lsr tmpb4, L1, 0x18 
	eor R0, R0, tmp 
	eor tmpa3, tmpa2, tmpa3 
	imul tmpb4, tmpb4, c3
	and tmpb1, L1, c1
	lsr tmpb3, L1, 0xe 
	and tmpb3, tmpb3, c2
	iadd tmpa3, tmpa3, tmpa1 
	imul tmpb1, tmpb1, c3
	ldr tmpb3, [S11, +tmpb3] 
	ldr tmpb4, [S10, +tmpb4] 
	lsr tmpb2, L1, 6 
	and tmpb2, tmpb2, c2
	eor R0, R0, tmpa3 
	iadd tmpb3, tmpb4, tmpb3 
	ldr tmpb2, [S12, +tmpb2] 
	ldr tmp, [P1], 0x1 
	ldr tmpb1, [S13, +tmpb1] 
	lsr tmpa4, R0, 0x18 
	eor R1, R1, tmp 
	eor tmpb3, tmpb2, tmpb3 
	imul tmpa4, tmpa4, c3
	and tmpa1, R0, c1
	lsr tmpa3, R0, 0xe 
	and tmpa3, tmpa3, c2
	iadd tmpb3, tmpb3, tmpb1 
	imul tmpa1, tmpa1, c3
	ldr tmpa3, [S01, +tmpa3] 
	ldr tmpa4, [S00, +tmpa4] 
	lsr tmpa2, R0, 6 
	and tmpa2, tmpa2, c2
	eor R1, R1, tmpb3 
	iadd tmpa3, tmpa4, tmpa3 
	ldr tmpa2, [S02, +tmpa2] 
	ldr tmp, [P0], 0x1 
	ldr tmpa1, [S03, +tmpa1] 
	lsr tmpb4, R1, 0x18 
	eor L0, L0, tmp 
	eor tmpa3, tmpa2, tmpa3 
	imul tmpb4, tmpb4, c3
	and tmpb1, R1, c1
	lsr tmpb3, R1, 0xe 
	and tmpb3, tmpb3, c2
	iadd tmpa3, tmpa3, tmpa1 
	imul tmpb1, tmpb1, c3
	ldr tmpb3, [S11, +tmpb3] 
	ldr tmpb4, [S10, +tmpb4] 
	lsr tmpb2, R1, 6 
	and tmpb2, tmpb2, c2
	eor L0, L0, tmpa3
	iadd tmpb3, tmpb4, tmpb3 
	ldr tmpb2, [S12, +tmpb2] 
	ldr tmp, [P1], 0x1 
	ldr tmpb1, [S13, +tmpb1] 
	eor L1, L1, tmp 
	eor tmpb3, tmpb2, tmpb3 
	add tmpb3, tmpb3, tmpb1 
	eor L1, L1, tmpb3
.endm

.macro BF2_2ROUND_B P1, P2, P3, P4
	and tmpa1, L0, c1
	lsr tmpa3, L0, 0xe
	and tmpa3, tmpa3, c2
	lsr tmpa4, L0, 0x16 
	and tmpa4, tmpa4, c2
	imul tmpa1, tmpa1, c3
	ldr tmpa3, [S01, +tmpa3] 
	ldr tmpa4, [S00, +tmpa4] 
	lsr tmpa2, L0, 6 
	and tmpa2, tmpa2, c2
	iadd tmpa3, tmpa4, tmpa3 
	ldr tmpa2, [S02, +tmpa2] 
	ldr tmpa1, [S03, +tmpa1] 
	lsr tmpb4, L1, 0x18 
	eor R0, R0, \P1
	eor tmpa3, tmpa2, tmpa3 
	imul tmpb4, tmpb4, c3
	and tmpb1, L1, c1
	lsr tmpb3, L1, 0xe 
	and tmpb3, tmpb3, c2
	iadd tmpa3, tmpa3, tmpa1 
	imul tmpb1, tmpb1, c3
	ldr tmpb3, [S11, +tmpb3] 
	ldr tmpb4, [S10, +tmpb4] 
	lsr tmpa1, L1, 6 
	and tmpa1, tmpa1, c2
	eor R0, R0, tmpa3 
	iadd tmpb3, tmpb4, tmpb3 
	ldr tmpa1, [S12, +tmpa1] 
	ldr tmpb1, [S13, +tmpb1] 
	lsr tmpa4, R0, 0x18 
	eor R1, R1, \P3
	eor tmpb3, tmpa1, tmpb3 
	imul tmpa4, tmpa4, c3
	and tmpa1, R0, c1
	lsr tmpa3, R0, 0xe 
	and tmpa3, tmpa3, c2
	iadd tmpb3, tmpb3, tmpb1 
	imul tmpa1, tmpa1, c3
	ldr tmpa3, [S01, +tmpa3] 
	ldr tmpa4, [S00, +tmpa4] 
	lsr tmpa2, R0, 6 
	and tmpa2, tmpa2, c2
	eor R1, R1, tmpb3 
	iadd tmpa3, tmpa4, tmpa3 
	ldr tmpa2, [S02, +tmpa2] 
	ldr tmpa1, [S03, +tmpa1] 
	lsr tmpb4, R1, 0x18 
	eor L0, L0, \P2
	eor tmpa3, tmpa2, tmpa3 
	imul tmpb4, tmpb4, c3
	and tmpb1, R1, c1
	lsr tmpb3, R1, 0xe 
	and tmpb3, tmpb3, c2
	iadd tmpa3, tmpa3, tmpa1 
	ldr tmpb3, [S11, +tmpb3] 
	ldr tmpb4, [S10, +tmpb4] 
	imul tmpb1, tmpb1, c3
	lsr tmpa1, R1, 6 
	and tmpa1, tmpa1, c2
	iadd tmpb3, tmpb4, tmpb3 
	eor L0, L0, tmpa3
	ldr tmpa1, [S12, +tmpa1] 
	eor L1, L1, \P4
	ldr tmpb1, [S13, +tmpb1] 
	eor tmpb3, tmpa1, tmpb3
	add tmpb3, tmpb3, tmpb1 
	eor L1, L1, tmpb3
.endm

SYM(BF_encrypt2):
	isub r52, ctx1, ctx0
	mov S11, 0x448
	mov S12, 0x848
	mov S13, 0xc48
	iadd S01, ctx0, S11
	iadd S02, ctx0, S12
	iadd S03, ctx0, S13
	add S00, ctx0, 72
	add S10, ctx1, 72
	iadd S11, ctx1, S11
	iadd S12, ctx1, S12
	iadd S13, ctx1, S13
	add r53, r52, 4
	mov L0, 0x0
	mov R0, 0x0
	mov L1, 0x0
	mov R1, 0x0
	mov c3, 0x4
	mov c2, 0x3fc
	mov c1, 0xff
	mov ptr0, ctx0
	mov ptr1, ctx1
	add end, ptr0, 72

loop1: 
	ldr tmp, [ctx0]
	iadd P0, ctx0, c3
	eor L0, tmp, L0
	ldr tmp, [ctx1]
	iadd P1, ctx1, c3
	eor L1, tmp, L1
	BF2_2ROUND_A
	BF2_2ROUND_A
	BF2_2ROUND_A
	BF2_2ROUND_A
	BF2_2ROUND_A
	BF2_2ROUND_A
	BF2_2ROUND_A
	BF2_2ROUND_A
	ldr tmpa2, [ctx0, +0x11]
	ldr tmpa3, [ctx1, +0x11]
	eor tmpa2, R0, tmpa2
	strd tmpa2, [ptr0], +0x1
	eor tmpa3, R1, tmpa3
	strd tmpa3, [ptr1], +0x1
	mov R0, L0
	mov R1, L1
	mov L0, tmpa2
	mov L1, tmpa3
	sub tmpa4, end, ptr0
	bgtu loop1
		
#undef tmp
#undef P0
#undef P1

#define P00		r4
#define P01		r5
#define P02		r6
#define P03		r7
#define P04		r8
#define P05		r9
#define P06		r10
#define P07		r11
#define P08		r14
#define P09		r15
#define P010		r28
#define P011		r29
#define P012		r30
#define P013		r31
#define P014		r32
#define P015		r33
#define P016		r34
#define P017		r35

#define P10		r36
#define P11		r37
#define P12		r38
#define P13		r39
#define P14		r40
#define P15		r41
#define P16		r42
#define P17		r43
#define P18		r44
#define P19		r45
#define P110		r46
#define P111		r47
#define P112		r48
#define P113		r49
#define P114		r50
#define P115		r51
#define P116		r52
#define P117		r53
		
	add ptr0, ctx0, 72
	add ptr1, ctx1, 72
	mov end, 0x1000
	strd P00, [sp, -0x1]
	strd P02, [sp, -0x2]
	strd P04, [sp, -0x3]
	strd P06, [sp, -0x4]
	strd P08, [sp, -0x5]
	strd P010, [sp, -0x6]
	strd P012, [sp, -0x7]
	strd P014, [sp, -0x8]
	strd P016, [sp, -0x9]
	strd P10, [sp, -0xa]
	strd P12, [sp, -0xb]
	strd P14, [sp, -0xc]
	strd P16, [sp, -0xd]
	iadd end, ptr0, end
	ldrd P00, [ctx0]
	ldrd P02, [ctx0, +0x1]
	ldrd P04, [ctx0, +0x2]
	ldrd P06, [ctx0, +0x3]
	ldrd P08, [ctx0, +0x4]
	ldrd P010, [ctx0, +0x5]
	ldrd P012, [ctx0, +0x6]
	ldrd P014, [ctx0, +0x7]
	ldrd P016, [ctx0, +0x8]
	ldrd P10, [ctx1]
	ldrd P12, [ctx1, +0x1]
	ldrd P14, [ctx1, +0x2]
	ldrd P16, [ctx1, +0x3]
	ldrd P18, [ctx1, +0x4]
	ldrd P110, [ctx1, +0x5]
	ldrd P112, [ctx1, +0x6]
	ldrd P114, [ctx1, +0x7]
	ldrd P116, [ctx1, +0x8]

loop2: 
	eor L0, P00, L0
	eor L1, P10, L1
	BF2_2ROUND_B P01, P02, P11, P12
	BF2_2ROUND_B P03, P04, P13, P14
	BF2_2ROUND_B P05, P06, P15, P16
	BF2_2ROUND_B P07, P08, P17, P18
	BF2_2ROUND_B P09, P010, P19, P110
	BF2_2ROUND_B P011, P012, P111, P112
	BF2_2ROUND_B P013, P014, P113, P114
	BF2_2ROUND_B P015, P016, P115, P116
	eor tmpa2, R0, P017
	strd tmpa2, [ptr0], +0x1
	eor tmpa3, R1, P117
	strd tmpa3, [ptr1], +0x1
	mov R0, L0
	mov R1, L1
	mov L0, tmpa2
	mov L1, tmpa3
	sub tmpa4, end, ptr0
	bgtu loop2
	ldrd P00, [sp, -0x1]
	ldrd P02, [sp, -0x2]
	ldrd P04, [sp, -0x3]
	ldrd P06, [sp, -0x4]
	ldrd P08, [sp, -0x5]
	ldrd P010, [sp, -0x6]
	ldrd P012, [sp, -0x7]
	ldrd P014, [sp, -0x8]
	ldrd P016, [sp, -0x9]
	ldrd P10, [sp, -0xa]
	ldrd P12, [sp, -0xb]
	ldrd P14, [sp, -0xc]
	ldrd P16, [sp, -0xd]
	rts
	.size	SYM(BF_encrypt2), .-SYM(BF_encrypt2)
	.balign 8
