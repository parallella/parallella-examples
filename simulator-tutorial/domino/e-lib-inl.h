#ifndef _E_LIB_INT_H
#define _E_LIB_INT_H

/* Minimal implementation of e-lib. N.B: Some API differences. */

/* WARNING: Here be dragons (and in e-lib). Mode-setting implementation
 * (GID / modeset / GIE) assumes global interrupts should be enabled which is
 * ok for normal code but not for code that manipulates hardware, interrupts
 * WAND / IDLE etc.
 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/* compiler barrier */
#define barrier() __asm__ __volatile__ ("":::"memory")

/* Flags for newlib crt0.s */
#define LOADER_BSS_CLEARED_FLAG (1 << 0)
#define LOADER_CUSTOM_ARGS_FLAG (1 << 1)
/* without this flag crt0.s will clear bss at runtime = race condition. */
//uint32_t __loader_flags = LOADER_BSS_CLEARED_FLAG;

void pass();
void fail();

void
pass ()
{
  puts ("pass");
  exit (0);
}

void
fail ()
{
  puts ("fail");
  exit (1);
}


#define E_ERR 1
#define E_OK 0

/* MMR register locations */
#define E_REG_CONFIG           0xf0400
#define E_REG_STATUS           0xf0404
#define E_REG_PC               0xf0408
#define E_REG_DEBUGSTATUS      0xf040c
#define E_REG_LC               0xf0414
#define E_REG_LS               0xf0418
#define E_REG_LE               0xf041c
#define E_REG_IRET             0xf0420
#define E_REG_IMASK            0xf0424
#define E_REG_ILAT             0xf0428
#define E_REG_ILATST           0xf042C
#define E_REG_ILATCL           0xf0430
#define E_REG_IPEND            0xf0434
#define E_REG_CTIMER0          0xf0438
#define E_REG_CTIMER1          0xf043C
#define E_REG_FSTATUS          0xf0440
#define E_REG_DEBUGCMD         0xf0448

/* DMA Registers */
#define E_REG_DMA0CONFIG       0xf0500
#define E_REG_DMA0STRIDE       0xf0504
#define E_REG_DMA0COUNT        0xf0508
#define E_REG_DMA0SRCADDR      0xf050C
#define E_REG_DMA0DSTADDR      0xf0510
#define E_REG_DMA0AUTODMA0     0xf0514
#define E_REG_DMA0AUTODMA1     0xf0518
#define E_REG_DMA0STATUS       0xf051C
#define E_REG_DMA1CONFIG       0xf0520
#define E_REG_DMA1STRIDE       0xf0524
#define E_REG_DMA1COUNT        0xf0528
#define E_REG_DMA1SRCADDR      0xf052C
#define E_REG_DMA1DSTADDR      0xf0530
#define E_REG_DMA1AUTODMA0     0xf0534
#define E_REG_DMA1AUTODMA1     0xf0538
#define E_REG_DMA1STATUS       0xf053C

/* Memory Protection Registers */
#define E_REG_MEMSTATUS        0xf0604
#define E_REG_MEMPROTECT       0xf0608

/* Node Registers */
#define E_REG_MESHCFG          0xf0700
#define E_REG_COREID           0xf0704
#define E_REG_CORE_RESET       0xf070c

#define E_SELF (~0)

/* Interrupts */
#define E_SYNC          0
#define E_SW_EXCEPTION  1
#define E_MEM_FAULT     2
#define E_TIMER0_INT    3
#define E_TIMER1_INT    4
#define E_MESSAGE_INT   5
#define E_DMA0_INT      6
#define E_DMA1_INT      7
#define E_WAND_INT      8
#define E_USER_INT      9
typedef void (*sighandler_t)(void);


typedef uint32_t e_coreid_t;

typedef enum {
  E_NULL         = 0,
  E_EPI_PLATFORM = 1,
  E_EPI_CHIP     = 2,
  E_EPI_GROUP    = 3,
  E_EPI_CORE     = 4,
  E_EXT_MEM      = 5,
  E_MAPPING      = 6,
  E_SHARED_MEM   = 7,
} e_objtype_t;

typedef enum {
  E_E16G301 = 0,
  E_E64G401 = 1,
  E_E1KG501 = 2,
} e_chiptype_t;


/* structs */
typedef struct {
  union {
    e_objtype_t  objtype;           /* 0x28 */
    uint32_t     _fill1;
  };
  union {
    e_chiptype_t chiptype;          /* 0x2c */
    uint32_t     _fill2;
  };
  union {
    e_coreid_t   group_id;          /* 0x30 */
    uint32_t     _fill3;
  };
  uint32_t       group_row;         /* 0x34 */
  uint32_t       group_col;         /* 0x38 */
  uint32_t       group_rows;        /* 0x3c */
  uint32_t       group_cols;        /* 0x40 */
  uint32_t       core_row;          /* 0x44 */
  uint32_t       core_col;          /* 0x48 */
  uint32_t       alignment_padding; /* 0x4c */
} __attribute__((packed)) e_group_config_t;

typedef struct {
  union {
    e_objtype_t objtype;            /* 0x50 */
    uint32_t    _fill1;
  };
  uint32_t      base;               /* 0x54 */
} __attribute__((packed)) e_emem_config_t;


volatile const e_group_config_t e_group_config
		       __attribute__((section("workgroup_cfg"))) = {
  .objtype  = E_EPI_GROUP,
  .chiptype = E_E1KG501,
  /* No good way of assigning rest of values at compile time. */
};

/* Used by e_write()/e_read() which we don't implement here since there is
 * no host. So this is just a placeholder. */
volatile const e_emem_config_t e_emem_config __attribute__((section("ext_mem_cfg"))) = {
  .objtype = E_EXT_MEM,
  .base    = 0x0,
};


static inline void e_irq_global_mask (bool state);
void e_irq_mask (uint32_t irq, bool state);
void e_reg_write (uint32_t reg_id, register uint32_t val);
uint32_t e_reg_read (uint32_t reg_id);
void e_irq_attach (uint32_t irq, sighandler_t handler);
void e_irq_set (uint32_t row, uint32_t col, uint32_t irq);
static inline uint32_t e_get_coreid (void);
void e_coords_from_coreid(e_coreid_t coreid, uint32_t *row, uint32_t *col);
void *e_get_global_address (uint32_t row, uint32_t col, const void *ptr);
static inline void e_idle (void); /*not in e-lib */



static inline void
e_irq_global_mask (bool state)
{
  barrier();
  if (state)
    __asm__ __volatile__("gid");
  else
    __asm__ __volatile__("gie");
  barrier();
}

void
e_irq_mask (uint32_t irq, bool state)
{
  uint32_t previous;

  barrier();
  previous = e_reg_read (E_REG_IMASK);

  if (state)
    e_reg_write (E_REG_IMASK, previous | (  1<<(irq - E_SYNC)));
  else
    e_reg_write (E_REG_IMASK, previous & (~(1<<(irq - E_SYNC))));
  barrier();
}

void
e_reg_write (uint32_t reg_id, register uint32_t val)
{
  uint32_t *addr;

  barrier();
  switch (reg_id)
    {
    case E_REG_CONFIG:
      __asm__ __volatile__ ("movts config, %0" : : "r" (val) : "config");
      break;
    case E_REG_STATUS:
      __asm__ __volatile__ ("movts status, %0" : : "r" (val) : "status");
      break;
    default:
      //__asm__ __volatile__ ("movfs %0, coreid" : "=r" (addr) : : /*"coreid"*/);
      //addr = (uint32_t *) ((((uintptr_t) addr) << 20) | reg_id);
      addr = (uint32_t *) reg_id;
      *addr = val;
      break;
    }
  barrier();
}

uint32_t
e_reg_read (uint32_t reg_id)
{
  uint32_t *addr;
  uint32_t val;

  barrier();
  switch (reg_id)
    {
    case E_REG_CONFIG:
      __asm__ __volatile__ ("movfs %0, config" : "=r" (val) : : "config");
      break;
    case E_REG_STATUS:
      __asm__ __volatile__ ("movfs %0, status" : "=r" (val) : : "status");
      break;
    default:
      //__asm__ __volatile__ ("movfs %0, coreid" : "=r" (addr) : : /*"coreid"*/);
      //addr = (uint32_t *) ((((uintptr_t) addr) << 20) | reg_id);
      addr = (uint32_t *) reg_id;
      val = *addr;
      break;
    }
  barrier();
  return val;
}

void
e_irq_attach (uint32_t irq, sighandler_t handler)
{
  const uint32_t b_opcode = 0x000000e8; /* b.l */

  barrier();
  uint32_t *ivt = (uint32_t *) (irq << 2);

  /* Create branch insn with the relative branch offset. */
  uint32_t insn = b_opcode |
		  (((uintptr_t) handler - (uintptr_t) ivt) >> 1) << 8;

  /* Fill in IVT entry */
  *ivt = insn;
  barrier();
}

void
e_irq_set (uint32_t row, uint32_t col, uint32_t irq)
{
  uint32_t *ilatst;

  barrier();
  //	if ((row == E_SELF) || (col == E_SELF))
  //		ilatst = (unsigned *) E_ILATST;
  //	else
  ilatst = (uint32_t *) e_get_global_address (row, col, (void *) E_REG_ILATST);

  *ilatst = 1 << (irq - E_SYNC);
  barrier();
}

static inline uint32_t
e_get_coreid (void)
{
  uint32_t coreid;
  __asm__ __volatile__ ("movfs %0, coreid" : "=r" (coreid) : : /*"coreid"*/);

  return coreid;
}

/* e_group_* API not in e-lib */

inline static uint32_t
e_group_rows ()
{
  return e_group_config.group_rows;
}

inline static uint32_t
e_group_last_row ()
{
  uint32_t rows = e_group_config.group_rows;
  return rows ? rows - 1 : 0;
}

inline static uint32_t
e_group_last_col ()
{
  uint32_t cols = e_group_config.group_cols;
  return cols ? cols - 1 : 0;
}

inline static uint32_t
e_group_cols ()
{
  return e_group_config.group_cols;
}

inline static uint32_t
e_group_my_row ()
{
  return e_group_config.core_row;
}

inline static uint32_t
e_group_row (uint32_t rank)
{
  return rank / e_group_cols ();
}

inline static uint32_t
e_group_col (uint32_t rank)
{
  return rank % e_group_cols ();
}

inline static uint32_t
e_group_rank (uint32_t row, uint32_t col)
{
  return row * e_group_cols () + col;
}

inline static uint32_t
e_group_my_col ()
{
  return e_group_config.core_col;
}

inline static uint32_t
e_group_my_rank ()
{
  return e_group_config.core_row * e_group_config.group_cols
    + e_group_config.core_col;
}

uint32_t
e_group_leader_rank ()
{
  /* Leader col is adjusted to '1' when groupid (northwestmost coreid) is 0 */
  uint32_t leader_col = e_group_config.group_id ? 0x0 : 0x1;

  /* Leader row is always 0 */
  return leader_col;
}

bool
e_group_leader_p ()
{
  return e_group_my_rank () == e_group_leader_rank ();
}

uint32_t
e_group_size ()
{
  static bool cached = false;
  static uint32_t size = 0;

  /* ???: what to do when group_id = 0 */

  if (!cached)
    {
      cached = true;
      size = e_group_config.group_cols * e_group_config.group_rows;
    }

  return size;
}

uint32_t
e_rank_to_coreid (uint32_t rank)
{
  uint32_t row = e_group_row (rank);
  uint32_t col = e_group_col (rank);

  return (row << 6) | col;
}

void *
e_group_global_address (uint32_t rank, const void *ptr)
{
  uint32_t coreid;
  uintptr_t uptr = (uintptr_t) ptr;

  /* If the address is global, return the pointer unchanged */
  if (uptr & 0xfff00000)
    return (void *) uptr;

  if (rank == (uint32_t) E_SELF)
    coreid = e_get_coreid ();
  else
    coreid = e_rank_to_coreid (rank) +  e_group_config.group_id;

  /* Get the 20 ls bits of the pointer and add coreid. */
  uptr |= (coreid << 20);

  return (void *) uptr;
}

void
e_coords_from_coreid(e_coreid_t coreid, uint32_t *row, uint32_t *col)
{
  coreid = coreid - e_group_config.group_id;

  *row = (coreid >> 6) & 0x3f;
  *col = coreid & 0x3f;

  return;
}

e_coreid_t
e_coreid_from_coords (uint32_t row, uint32_t col)
{
  e_coreid_t coreid;

  coreid = ((row & 0x3f) << 6) | (col & 0x3f);
  coreid = coreid + e_group_config.group_id;

  return coreid;
}

void *
e_get_global_address (uint32_t row, uint32_t col, const void *ptr)
{
  uint32_t coreid;
  uintptr_t uptr = (uintptr_t) ptr;

  /* If the address is global, return the pointer unchanged */
  if (uptr & 0xfff00000)
    return (void *) uptr;

  if ((row == (unsigned) E_SELF) || (col == (unsigned) E_SELF))
    coreid = e_get_coreid ();
  else
    coreid = ((row << 6) | col) + e_group_config.group_id;

  /* Get the 20 ls bits of the pointer and add coreid. */
  uptr |= (coreid << 20);

  return (void *) uptr;
}

/* Not in e-lib (but should be) */
static inline void
e_idle (void)
{
#ifdef __EPIPHANY_ARCH_5__ /* (not in compiler yet) */
  /* epiphany-5+ idle clears gidisablebit */
  __asm__ __volatile__ ("idle");
#else
  /* For older chips we need to emit gie+idle. Align on a 64-bit boundary so
   * that no interrupt can sneak in between the instructions.
   * https://www.parallella.org/forums/viewtopic.php?f=23&t=432&start=10#p4014
   */

  /* nop opcode = 0x01a2 */
  __asm__ __volatile__ (".balignw 8,0x01a2`gie`idle");
#endif
}


/* DMA stuff */
typedef enum {
  E_DMA_ENABLE        = (1<<0),
  E_DMA_MASTER        = (1<<1),
  E_DMA_CHAIN         = (1<<2),
  E_DMA_STARTUP       = (1<<3),
  E_DMA_IRQEN         = (1<<4),
  E_DMA_BYTE          = (0<<5),
  E_DMA_HWORD         = (1<<5),
  E_DMA_WORD          = (2<<5),
  E_DMA_DWORD         = (3<<5),
  E_DMA_MSGMODE       = (1<<10),
  E_DMA_SHIFT_SRC_IN  = (1<<12),
  E_DMA_SHIFT_DST_IN  = (1<<13),
  E_DMA_SHIFT_SRC_OUT = (1<<14),
  E_DMA_SHIFT_DST_OUT = (1<<15),
} e_dma_config_t;

typedef enum {
  E_DMA_0 = 0,
  E_DMA_1 = 1,
} e_dma_id_t;

typedef struct {
  uint32_t config;
  uint32_t inner_stride;
  uint32_t count;
  uint32_t outer_stride;
  void     *src_addr;
  void     *dst_addr;
} __attribute__((packed)) __attribute__((aligned(8))) e_dma_desc_t;

int
e_dma_busy(e_dma_id_t chan)
{
  switch (chan)
    {
      case E_DMA_0:
	return e_reg_read(E_REG_DMA0STATUS) & 0xf;
      case E_DMA_1:
	return e_reg_read(E_REG_DMA1STATUS) & 0xf;
      default:
	return -1;
    }
}

int
e_dma_start(e_dma_desc_t *descriptor, e_dma_id_t chan)
{
  uintptr_t start;
  int       ret_val;

  ret_val = E_ERR;

  if ((chan | 1) != 1)
    return E_ERR;

  /* wait for the DMA engine to be idle */
  while (e_dma_busy(chan));

  start = ((uintptr_t)(descriptor) << 16) | E_DMA_STARTUP;

  switch (chan)
    {
    case E_DMA_0:
      e_reg_write(E_REG_DMA0CONFIG, start);
      ret_val = E_OK;
      break;
    case E_DMA_1:
      e_reg_write(E_REG_DMA1CONFIG, start);
      ret_val = E_OK;
      break;
    }

  return ret_val;
}

e_dma_desc_t _dma_copy_descriptor_ __attribute__((section(".data_bank0")));

int
e_dma_copy(void *dst, void *src, size_t n)
{
  const uintptr_t local_mask = 0xfff00000;
  e_dma_id_t chan;
  unsigned   index;
  unsigned   shift;
  unsigned   stride;
  unsigned   config;
  int        ret_val;

  const unsigned dma_data_size[8] = {
    E_DMA_DWORD,
    E_DMA_BYTE,
    E_DMA_HWORD,
    E_DMA_BYTE,
    E_DMA_WORD,
    E_DMA_BYTE,
    E_DMA_HWORD,
    E_DMA_BYTE,
  };

  chan  = E_DMA_1;

  index = (((uintptr_t) dst) | ((uintptr_t) src) | ((unsigned) n)) & 7;

  config = E_DMA_MASTER | E_DMA_ENABLE | dma_data_size[index];
  if ((((uintptr_t) dst) & local_mask) == 0)
    config = config | E_DMA_MSGMODE;
  shift = dma_data_size[index] >> 5;
  stride = 0x10001 << shift;

  _dma_copy_descriptor_.config       = config;
  _dma_copy_descriptor_.inner_stride = stride;
  _dma_copy_descriptor_.count        = 0x10000 | (n >> shift);
  _dma_copy_descriptor_.outer_stride = stride;
  _dma_copy_descriptor_.src_addr     = src;
  _dma_copy_descriptor_.dst_addr     = dst;

  ret_val = e_dma_start(&_dma_copy_descriptor_, chan);

  while (e_dma_busy(chan));

  return ret_val;
}

/* CTIMERS */
typedef enum {
  E_CTIMER_0 = 0,
  E_CTIMER_1 = 1
} e_ctimer_id_t;

/** @enum e_ctimer_config_t
 * The supported ctimer event
 */
typedef enum {
  E_CTIMER_OFF              = 0x0,
  E_CTIMER_CLK              = 0x1,
  E_CTIMER_IDLE             = 0x2,
  E_CTIMER_IALU_INST        = 0x4,
  E_CTIMER_FPU_INST         = 0x5,
  E_CTIMER_DUAL_INST        = 0x6,
  E_CTIMER_E1_STALLS        = 0x7,
  E_CTIMER_RA_STALLS        = 0x8,
  E_CTIMER_EXT_FETCH_STALLS = 0xc,
  E_CTIMER_EXT_LOAD_STALLS  = 0xd,
  /* Only on Epiphany-IV+ */
  E_CTIMER_64BIT            = 0x3,
} e_ctimer_config_t;

/** @def MAX_CTIMER_VALUE 0xffffffff
 * Defines the maximum timer value  (MAX_UINT)
*/
#define E_CTIMER_MAX (~0)

unsigned
e_ctimer_start(e_ctimer_id_t timer, uint32_t config)
{
  uint32_t mask;

  switch (timer)
    {
    case E_CTIMER_0:
      mask = 0xffffff0f;
      config = config << 4;
      break;
    case E_CTIMER_1:
      mask = 0xfffff0ff;
      config = config << 8;
      break;
    default:
      return 0;
    }

  __asm__ __volatile__ (
    "movfs	r16, config\n\t"   /* load config        */
    "and	r16, r16, %0\n\t"  /* apply mask         */
    "orr	r16, r16, %1\n\t"  /* tmp = config | val */
    "movts	config, r16"       /* config = tmp       */
    : : "r" (mask), "r" (config) : "r16", "config" /*, "ctimer0", "ctimer1" */);
  return config;

}

unsigned
e_ctimer_stop(e_ctimer_id_t timer)
{
  // TODO convert to assembly to eliminate 2 function calls.
  uint32_t shift;
  uint32_t mask;
  uint32_t config;
  uint32_t count;

  shift = (timer) ? 8:4;
  mask = 0xf << shift;
  config = e_reg_read(E_REG_CONFIG);
  // stop the timer
  e_reg_write(E_REG_CONFIG, config & (~mask));

  count = e_reg_read(timer ? E_REG_CTIMER1 : E_REG_CTIMER0);

  return count;
}

uint32_t
e_ctimer_set (uint32_t timer_id, uint32_t val)
{
  switch (timer_id)
    {
    case E_CTIMER_0:
      __asm__ __volatile__ ("movts ctimer0, %0" : :"r" (val) : /*"ctimer0"*/);
      break;
    case E_CTIMER_1:
      __asm__ __volatile__ ("movts ctimer1, %0" : :"r" (val) : /*"ctimer1"*/);
      break;
    default:
      val = 0;
      break;
    }
  return val;
}

uint32_t
e_ctimer_get (uint32_t timer_id)
{
  uint32_t val;

  switch (timer_id)
    {
    case E_CTIMER_0:
      __asm__ __volatile__ ("movfs %0, ctimer0" : "=r" (val) : : /*"ctimer0"*/);
      break;
    case E_CTIMER_1:
      __asm__ __volatile__ ("movfs %0, ctimer1" : "=r" (val) : : /*"ctimer1"*/);
      break;
    default:
      val = 0;
      break;
    }
  return val;
}

void
e_wait(e_ctimer_id_t timer, unsigned int clicks)
{
  // Program ctimer and start counting
  e_ctimer_stop(timer);
  e_ctimer_set(timer, clicks);
  e_ctimer_start(timer, E_CTIMER_CLK);

  // Wait until ctimer is idle
  while (e_ctimer_get(timer)) { };

  return;
}

#endif /* _E_LIB_INT_H */
