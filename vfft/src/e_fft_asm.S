/*
 * e_fft_asm.S
 *
 * ASM optimized FFT routines
 *
 * Copyright (C) 2015 - Sylvain Munaut <tnt@246tNt.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 */

/* ANSI concatenation macros.  */
#define CONCAT1(a, b) CONCAT2(a, b)
#define CONCAT2(a, b) a ## b
/* Use the right prefix for global labels.  */
#define SYM(x) CONCAT1 (__USER_LABEL_PREFIX__, x)

/* Macro for easy hw loop setup */
.macro hwloop start, end, tmp_reg
	mov	\tmp_reg, %low(\start)
#ifdef NON_LOCAL_TEXT
	movt	\tmp_reg, %high(\start)
#endif
	movts	ls, \tmp_reg

	mov	\tmp_reg, %low(\end - 4)
#ifdef NON_LOCAL_TEXT
	movt	\tmp_reg, %high(\end - 4)
#endif
	movts	le, \tmp_reg
.endm


/* ========================================================================= */
/*                                                                           */
/* Forward - 1D - Radix 2 - DIT                                              */
/*                                                                           */
/* ========================================================================= */

	/* ----------------------------------------------------------------- */
	/* First stage                                                       */
	/* ----------------------------------------------------------------- */

	.global SYM(fft_1d_r2_dit_asm_first_stage)
SYM(fft_1d_r2_dit_asm_first_stage):

	// Register assignement
	// r0  = buf
	// r1  = twiddle
	// r2  = logN
	// r16 = data_base_0
	// r17 = data_base_1
	// r44 = v0a.r
	// r45 = v0a.i
	// r46 = v1a.r
	// r47 = v1a.i
	// r48 = v0a'.r
	// r49 = v0a'.i
	// r50 = v1a'.r
	// r51 = v1a'.i
	// r52 = v0b.r
	// r53 = v0b.i
	// r54 = v1b.r
	// r55 = v1b.i
	// r56 = v0b'.r
	// r57 = v0b'.i
	// r58 = v1b'.r
	// r59 = v1b'.i

	// HW loop init
	hwloop	1f, 2f, r3

	mov	r3, #1
	lsl	r3, r3, r2
	lsr	r3, r3, #2
	sub	r3, r3, #1
	movts	lc, r3

	// Init data pointers
	mov	r3, #4
	lsl	r3, r3, r2
	mov	r16, r0
	add	r17, r0, r3

	// Disable interrupt (hw loop)
	gid

	// Pipeline fill 1
	ldrd.l	r44, [r16]	// v0a
	ldrd.l	r46, [r17]	// v1a

	// Pipeline fill 2
	fadd.l	r48, r44, r46
	ldrd.l	r52, [r16, #1]	// v0b

	fadd.l	r49, r45, r47
	ldrd.l	r54, [r17, #1]	// v1b

	fsub.l	r50, r44, r46

	fsub.l	r51, r45, r47

	// Directly jump into the loop
	// (because the second half is the same
	//  for the loop and for the pre-load)
	b 3f

	// Loop
	.balignw 8,0x01a2	// align to 8-byte boundary
1:
	fadd.l	r48, r44, r46
	ldrd.l	r52, [r16, #2]	// v0b

	fadd.l	r49, r45, r47
	ldrd.l	r54, [r17, #2]	// v1b

	fsub.l	r50, r44, r46
	strd.l	r56, [r16], #1	// v0b'

	fsub.l	r51, r45, r47
	strd.l	r58, [r17], #1	// v1b'
3:
	fadd.l	r56, r52, r54
	ldrd.l	r44, [r16, #2]	// v0a

	fadd.l	r57, r53, r55
	ldrd.l	r46, [r17, #2]	// v1a

	fsub.l	r58, r52, r54
	strd.l	r48, [r16], #1	// v0a'

	fsub.l	r59, r53, r55
	strd.l	r50, [r17], #1	// v1a'
2:
	// Pipeline flush 1
	fadd.l	r48, r44, r46
	ldrd.l	r52, [r16, #2]	// v0b

	fadd.l	r49, r45, r47
	ldrd.l	r54, [r17, #2]	// v1b

	fsub.l	r50, r44, r46
	strd.l	r56, [r16], #1	// v0b'

	fsub.l	r51, r45, r47
	strd.l	r58, [r17], #1	// v1b'

	fadd.l	r56, r52, r54

	fadd.l	r57, r53, r55

	fsub.l	r58, r52, r54
	strd.l	r48, [r16], #1	// v0a'

	fsub.l	r59, r53, r55
	strd.l	r50, [r17], #1	// v1a'

	// Pipeline flush 2
	strd.l	r56, [r16]	// v0b'
	strd.l	r58, [r17]	// v1b'

	// Restore interrupt
	gie

	rts


	/* ----------------------------------------------------------------- */
	/* Middle stages                                                     */
	/* ----------------------------------------------------------------- */

	.global SYM(fft_1d_r2_dit_asm_mid_stages)
SYM(fft_1d_r2_dit_asm_mid_stages):

	// Register assignement
	// r0 = buf
	// r1 = twiddle
	// r2 = logN
	// r3 = # iteration of HW loop

	// r16 = data_a
	// r17 = data_b
	// r18 = # iteration of outer loop remaining
	// r19 = shft
	// r20 = ofs
	// r21 = msk
	// r22 = i
	// r23 = idx_tw
	// r24 = idx_v0
	// r25 = idx_v1
	// r26 = idx_v0_prev
	// r27 = idx_v1_prev

	// r42 = tw.r
	// r43 = tw.i

	// r44 = v0a.r
	// r45 = v0a.i
	// r46 = v1a.r
	// r47 = v1a.i
	// r48 = tmp_a.r
	// r49 = tmp_a.i
	// r50 = v0a'.r
	// r51 = v0a'.i
	// r52 = v1a'.r
	// r53 = v1a'.i
	// r54 = v0b.r
	// r55 = v0b.i
	// r56 = v1b.r
	// r57 = v1b.i
	// r58 = tmp_b.r
	// r59 = tmp_b.i
	// r60 = v0b'.r
	// r61 = v0b'.i
	// r62 = v1b'.r
	// r63 = v1b'.i

	// Save r42-r43 on stack (they're "callee saved")
	strd	r42, [sp]

	// HW loop init
	hwloop	mid_inner_start, mid_inner_end, r3

	mov	r3, #1
	lsl	r3, r3, r2
	lsr	r3, r3, #2
	sub	r3, r3, #2

	// Outer loop
		// Init for stage=1
	mov	r16, r0		// data_a = buf
	add	r17, r16, #8	// data_b = buf + 8

	sub	r18, r2, #2	// # outer iterations = logN - 2

	mov	r19, #28
	sub	r19, r19, r2
	sub	r19, r19, r2	// shft = 27 - 2 * logN + stage

	mov	r20, #2
	lsl	r20, r20, r2	// ofs = 8 << (logN - stage - 1)

mid_outer:
	sub	r21, r20, #1	// msk = ofs - 1

	// Disable interrupt (hw loop)
	gid

	// Inner Pipeline fill 1 & 2
		// Because the tw first twiddle factors are
		// always 1+0j, we can optimize the first iteration

	ldrd.l	r44, [r16]	// v0a
	mov.l	r26, #0

	ldrd.l	r46, [r16, r20]	// v1a
	mov.l	r27, r20

	ldrd.l	r54, [r17]	// v0b
	mov.l	r22, #16

	ldrd.l	r56, [r17, r20]	// v1b
	and.l	r24, r22, r21

	fadd.l  r50, r44, r46
	sub.l	r23, r22, r24   // idx_tw = i & ~msk ( = i - (i & msk) )

	fadd.l  r51, r45, r47
	bitr.l	r25, r23

	fsub.l  r52, r44, r46
	lsr.l	r25, r25, r19

	fsub.l  r53, r45, r47
	orr.l	r24, r24, r25   // idx_v0 = (bitr(idx_tw) >> shft) | (i & msk)

	fadd.l  r60, r54, r56
	add.l	r25, r24, r20   // idx_v1 = idx_v0 + ofs

	fadd.l  r61, r55, r57
	mov.l	r22, #32

	fsub.l  r62, r54, r56
	ldrd.l	r46, [r16, r25]	// v1a

	fsub.l  r63, r55, r57
	ldrd.l	r56, [r17, r25]	// v1b

	ldrd.l	r42, [r1, r23]	// tw
	ldrd.l	r44, [r16, r24]	// v0a
	ldrd.l	r54, [r17, r24]	// v0b

	// Inner HW Loop
	movts	lc, r3

	.balignw 8,0x01a2	// align to 8-byte boundary
mid_inner_start:

	fmul.l	r48, r46, r42
	strd.l	r50, [r16, r26]

	fmul.l	r49, r46, r43
	strd.l	r60, [r17, r26]

	fmul.l	r58, r56, r42
	mov.l	r26, r24

	fmul.l	r59, r56, r43
	and.l	r24, r22, r21	// r24 = i & msk

		// 1 Stall cycle
	sub.l	r23, r22, r24	// idx_tw = i & ~msk ( = i - (i & msk) )

	fmsub.l	r48, r47, r43
	strd.l	r52, [r16, r27]

	fmadd.l	r49, r47, r42
	strd.l	r62, [r17, r27]

	fmsub.l	r58, r57, r43
	mov.l	r27, r25

	fmadd.l	r59, r57, r42
	bitr.l	r25, r23

		// 1 Stall cycle
	lsr.l	r25, r25, r19

	fadd.l	r50, r44, r48
	orr.l	r24, r24, r25	// idx_v0 = (bitr(idx_tw) >> shft) | (i & msk)

	fadd.l	r51, r45, r49
	add.l	r25, r24, r20	// idx_v1 = idx_v0 + ofs

	fsub.l	r52, r44, r48
	add.l	r22, r22, #16	// i = i + 16

	fsub.l	r53, r45, r49
	ldrd.l	r42, [r1, r23]	// tw

	fadd.l	r60, r54, r58
	ldrd.l	r46, [r16, r25]	// v1a

	fadd.l	r61, r55, r59
	ldrd.l	r56, [r17, r25]	// v1b

	fsub.l	r62, r54, r58
	ldrd.l	r44, [r16, r24]	// v0a

	fsub.l	r63, r55, r59
	ldrd.l	r54, [r17, r24]	// v0b
		// There is a conflict in that last pair that will prevent
		// dual-issue on the first iteration. So for the subsequent
		// iterations the alternate pairing of instructions will
		// happen ... But it will keep being 18 cycles

mid_inner_end:

	// Inner pipeline flush 1
	fmul.l	r48, r46, r42
	fmul.l	r49, r46, r43
	fmul.l	r58, r56, r42
	fmul.l	r59, r56, r43

		// 1 Stall cycle

	fmsub.l	r48, r47, r43
	strd.l	r50, [r16, r26]

	fmadd.l	r49, r47, r42
	strd.l	r60, [r17, r26]

	fmsub.l	r58, r57, r43
	strd.l	r52, [r16, r27]

	fmadd.l	r59, r57, r42
	strd.l	r62, [r17, r27]

		// 1 Stall cycle

	fadd.l	r50, r44, r48
	fadd.l	r51, r45, r49
	fsub.l	r52, r44, r48
	fsub.l	r53, r45, r49
	fadd.l	r60, r54, r58
	fadd.l	r61, r55, r59
	fsub.l	r62, r54, r58
	fsub.l	r63, r55, r59

	// Inner pipeline flush 2
	strd.l	r50, [r16, r24]
	strd.l	r60, [r17, r24]
	strd.l	r52, [r16, r25]
	strd.l	r62, [r17, r25]

	// Restore interrupts
	gie

	// Outer loop: next iteration and branch
	add	r19, r19, #1	// shft = shft + 1
	lsr	r20, r20, #1	// ofs  = ofs >> 1

	sub	r18, r18, #1
	bne	mid_outer

	// Restore r42-r43 from stack (they're "callee saved")
	ldrd	r42, [sp]

	rts


	/* ----------------------------------------------------------------- */
	/* Last stage                                                        */
	/* ----------------------------------------------------------------- */

	.global SYM(fft_1d_r2_dit_asm_last_stage)
SYM(fft_1d_r2_dit_asm_last_stage):

	// Last stage
	// ----------

	// Register assignment
	// r0 = buf
	// r1 = twiddle
	// r2 = logN

	// r16 = twiddle_a
	// r17 = twiddle_b
	// r18 = shft
	// r19 = i
	// r20 = idx_tw

	// r24 = tmp_a.r
	// r25 = tmp_a.i
	// r26 = tmp_b.r
	// r27 = tmp_b.i

	// r44 = v0a.r
	// r45 = v0a.i
	// r46 = v1a.r
	// r47 = v1a.i
	// r48 = twa.r
	// r49 = twa.i
	// r50 = v0a'.r
	// r51 = v0a'.i
	// r52 = v1a'.r
	// r53 = v1a'.i
	// r54 = v0b.r
	// r55 = v0b.i
	// r56 = v1b.r
	// r57 = v1b.i
	// r58 = twb.r
	// r59 = twb.i
	// r60 = v0b'.r
	// r61 = v0b'.i
	// r62 = v1b'.r
	// r63 = v1b'.i

	// HW loop init
	hwloop	1f, 2f, r3

	mov	r3, #1
	lsl	r3, r3, r2
	lsr	r3, r3, #2
	sub	r3, r3, #2
	movts	lc, r3

	// Init loop constants
	mov	r3, #2
	lsl	r3, r3, r2
	mov	r16, r1		// twiddle_a
	add	r17, r1, r3	// twiddle_b

	mov	r18, #29
	sub	r18, r18, r2	// shft

	mov	r19, #8		// i

	// Disable interrupt (hw loop)
	gid

	// Pipeline fill 1 & 2
		// Because the two first twiddle factors are
		// always 1+0j and 0-1j, we can optimize the first
		// iteration`
	ldrd.l	r44, [r0]	// v0a
	ldrd.l	r46, [r0, #1]	// v1a
	ldrd.l	r54, [r0, #2]	// v0b
	ldrd.l	r56, [r0, #3]	// v1b

	mov.l	r20, #4
	fadd.l	r50, r44, r46

	bitr.l	r20, r20
	fadd.l	r51, r45, r47

	lsr.l	r20, r20, r18
	fsub.l	r52, r44, r46

	fsub.l	r53, r45, r47

	fadd.l	r60, r54, r57

	fsub.l	r61, r55, r56

	fsub.l	r62, r54, r57
	ldrd.l	r46, [r0, #5]	// v1a

	fadd.l	r63, r55, r56
	ldrd.l	r48, [r16, r20]	// twa

	ldrd.l	r56, [r0, #7]	// v1b

	ldrd.l	r58, [r17, r20]	// twb

	// Loop
	.balignw 8,0x01a2	// align to 8-byte boundary
1:
	fmul.l	r24, r46, r48
	bitr.l	r20, r19

	fmul.l	r25, r46, r49
	lsr.l	r20, r20, r18

	fmul.l	r26, r56, r58
	ldrd.l	r44, [r0, #4]	// v0a

	fmul.l	r27, r56, r59
	ldrd.l	r54, [r0, #6]	// v0b

		// 1 Stall cycle

	fmsub.l	r24, r47, r49
	strd.l	r50, [r0], #1	// v0a'

	fmadd.l	r25, r47, r48
	strd.l	r52, [r0], #1	// v1a'

	fmsub.l	r26, r57, r59
	strd.l	r60, [r0], #1	// v0b'

	fmadd.l	r27, r57, r58
	strd.l	r62, [r0], #1	// v1b'

		// 1 Stall cycle

	fadd.l	r50, r44, r24
	add.l	r19, r19, #4

	fadd.l	r51, r45, r25
	add.l	r19, r19, #0	// Dummy for 8 byte align

	fsub.l	r52, r44, r24

	fsub.l	r53, r45, r25

	fadd.l	r60, r54, r26
	ldrd.l	r46, [r0, #5]	// v1a

	fadd.l	r61, r55, r27
	ldrd.l	r48, [r16, r20]	// twa

	fsub.l	r62, r54, r26
	ldrd.l	r56, [r0, #7]	// v1b

	fsub.l	r63, r55, r27
	ldrd.l	r58, [r17, r20]	// twb
2:
	// Pipeline flush 1
	fmul.l	r24, r46, r48
	bitr.l	r20, r19

	fmul.l	r25, r46, r49
	lsr.l	r20, r20, r18

	fmul.l	r26, r56, r58
	ldrd.l	r44, [r0, #4]	// v0a

	fmul.l	r27, r56, r59
	ldrd.l	r54, [r0, #6]	// v0b

		// 1 Stall cycle

	fmsub.l	r24, r47, r49
	strd.l	r50, [r0], #1	// v0a'

	fmadd.l	r25, r47, r48
	strd.l	r52, [r0], #1	// v1a'

	fmsub.l	r26, r57, r59
	strd.l	r60, [r0], #1	// v0b'

	fmadd.l	r27, r57, r58
	strd.l	r62, [r0], #1	// v1b'

		// 1 Stall cycle

	fadd.l	r50, r44, r24
	fadd.l	r51, r45, r25
	fsub.l	r52, r44, r24
	fsub.l	r53, r45, r25

	fadd.l	r60, r54, r26
	fadd.l	r61, r55, r27
	fsub.l	r62, r54, r26
	fsub.l	r63, r55, r27

	// Pipeline flush 2
	strd.l	r50, [r0], #1	// v0a'
	strd.l	r52, [r0], #1	// v1a'
	strd.l	r60, [r0], #1	// v0b'
	strd.l	r62, [r0], #1	// v1b'

	// Restore interrupts
	gie

	rts


	/* ----------------------------------------------------------------- */
	/* Complete FFT                                                      */
	/* ----------------------------------------------------------------- */

	.global SYM(fft_1d_r2_dit_asm)
SYM(fft_1d_r2_dit_asm):
	mov	r12, lr
	bl	SYM(fft_1d_r2_dit_asm_first_stage)
	bl	SYM(fft_1d_r2_dit_asm_mid_stages)
	bl	SYM(fft_1d_r2_dit_asm_last_stage)
	jr	r12
