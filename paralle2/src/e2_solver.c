static void Solver2016_BorderWest();
static void Solver2016_BorderEast();
static void Solver2016_InnerTile();
static void Solver2016_Special_H1();
static void Solver2016_Special_H2();
static void Solver2016_Special_I1();
static void Solver2016_BottomLine();
static void Solver2016_BorderLast();
//for debugging purpose
static void Solver2016_Special_Debug();

//#######################################
//STATIC DATA
const uint tlscouleur_B2016[BORDERCOLOR_N+1]={   0x00000000, 0x0870809A, 0x91032001, 0x42845140, 0x24080E24, 0x000000FF, 0x00007F00, 0x00FF8000, 0xFF000000, 0x00000001, 0x00018300, 0x03000406, 0x00000008, 0x00020830, 0x04041040, 0x38080000, 0x40100000, 0x00202000, 0x80C04080, 0x00000000 };
const uc tbordureD[32]={ 0x00000002, 0x00000001, 0x00000004, 0x00000001, 0x00000001, 0x00000004, 0x00000003, 0x00000001, 0x00000003, 0x00000004, 0x00000004, 0x00000004, 0x00000003, 0x00000002, 0x00000003, 0x00000001, 0x00000002, 0x00000002, 0x00000003, 0x00000004, 0x00000001, 0x00000001, 0x00000001, 0x00000003, 0x00000002, 0x00000003, 0x00000004, 0x00000001, 0x00000002, 0x00000004, 0x00000003, 0x00000002 };
const uc tbordureG[32]={ 0x00000001, 0x00000001, 0x00000001, 0x00000001, 0x00000001, 0x00000001, 0x00000001, 0x00000001, 0x00000002, 0x00000002, 0x00000002, 0x00000002, 0x00000002, 0x00000002, 0x00000002, 0x00000003, 0x00000003, 0x00000003, 0x00000003, 0x00000003, 0x00000003, 0x00000003, 0x00000003, 0x00000003, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004, 0x00000004 };
const uc tbordureI[32]={ 0x00000000, 0x00000002, 0x00000002, 0x00000003, 0x00000004, 0x00000004, 0x00000005, 0x00000009, 0x00000001, 0x00000001, 0x00000002, 0x00000004, 0x00000005, 0x00000008, 0x00000009, 0x00000001, 0x00000001, 0x00000004, 0x00000005, 0x00000006, 0x00000007, 0x00000008, 0x00000009, 0x00000009, 0x00000002, 0x00000002, 0x00000005, 0x00000006, 0x00000006, 0x00000006, 0x00000007, 0x00000009 };

//#pragma pack(16)
#pragma pack(4)
typedef struct S_NEnoifpext3 {
  uint64_t tuileB;
  uc tuileN;
  uc t14[14];
  uc align4;
}SNEnoifpext3;

const SNEnoifpext3 tNEnoif[100]={
  { 0x0000000000000001ULL,    1, {  0, 0x65,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000081102ULL,    4, {  1, 0x09,  8, 0x23, 19, 0x16, 12, 0x93,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000200440ULL,    3, {  6, 0x05, 21, 0x19, 10, 0x43,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000012000ULL,    2, { 13, 0x44, 16, 0x85,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000080ULL,    1, {  7, 0x13,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x000000000100004CULL,    4, {  3, 0x51, 24, 0x59,  6, 0x02,  2, 0x21,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000160001ULL,    4, { 18, 0x07, 17, 0x85,  0, 0x50, 20, 0x26,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000848210ULL,    5, { 23, 0x49, 18, 0x06,  9, 0x33,  4, 0x71, 15, 0x75,  0, 0x00,  0, 0x00 } },
  { 0x0000000000400020ULL,    2, {  5, 0x71, 22, 0x19,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000004802ULL,    3, {  1, 0x01, 11, 0x63, 14, 0x64,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x000000000000003EULL,    5, {  3, 0x55,  1, 0x90,  5, 0x87,  4, 0x77,  2, 0x52,  0, 0x00,  0, 0x00 } },
  { 0x0000000002080000ULL,    2, { 25, 0x59, 19, 0x60,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x000000090C000100ULL,    5, { 35, 0x78,  8, 0x30, 26, 0x15, 32, 0x97, 27, 0x17,  0, 0x00,  0, 0x00 } },
  { 0x0000000050000080ULL,    3, {  7, 0x04, 28, 0x62, 30, 0x44,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000406000000ULL,    3, { 34, 0x68, 25, 0x91, 26, 0x12,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000280080000ULL,    3, { 19, 0x01, 31, 0x75, 33, 0x58,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000028000000ULL,    2, { 29, 0x63, 27, 0x12,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000601000ULL,    3, { 22, 0x08, 21, 0x02, 12, 0x30,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000040ULL,    1, {  6, 0x50,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x000000001C200004ULL,    5, { 21, 0x90, 26, 0x51,  2, 0x05, 28, 0x36, 27, 0x71,  0, 0x00,  0, 0x00 } },
  { 0x0000003000000000ULL,    3, { 37, 0x33, 36, 0x29, 36, 0x92,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x000001E000000100ULL,    5, { 37, 0x32,  8, 0x01, 38, 0x28, 39, 0x29, 40, 0x43,  0, 0x00,  0, 0x00 } },
  { 0x0000100000000400ULL,    2, { 44, 0x77, 10, 0x30,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000100000ULL,    1, { 20, 0x06,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000020800000000ULL,    2, { 35, 0x81, 41, 0x54,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x00000C4000000000ULL,    3, { 43, 0x65, 42, 0x64, 38, 0x23,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000009100000000ULL,    3, { 36, 0x22, 39, 0x23, 32, 0x71,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000001F80ULL,    6, { 11, 0x96,  9, 0x73,  8, 0x12,  7, 0x41, 12, 0x19, 10, 0x24,  0, 0x00 } },
  { 0x0000000020000000ULL,    1, { 29, 0x76,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x000001E000000000ULL,    4, { 37, 0x23, 38, 0x82, 39, 0x92, 40, 0x34,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000202000000200ULL,    3, { 37, 0x22, 45, 0x77,  9, 0x07,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0024810040002000ULL,    6, { 13, 0x40, 50, 0x87, 53, 0x49, 47, 0x56, 40, 0x32, 30, 0x41,  0, 0x00 } },
  { 0x0010000000000000ULL,    1, { 52, 0x97,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0002000010000000ULL,    2, { 49, 0x86, 28, 0x21,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000200000000000ULL,    1, { 45, 0x73,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0040400000010000ULL,    3, { 54, 0x49, 16, 0x50, 46, 0x65,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0009000000000000ULL,    2, { 48, 0x56, 51, 0x87,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000006000ULL,    2, { 13, 0x34, 14, 0x96,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000040000080ULL,    2, {  7, 0x30, 30, 0x34,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000060000000000ULL,    2, { 41, 0x75, 42, 0x86,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000010000000400ULL,    2, { 40, 0x23, 10, 0x02,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x00A0000040002000ULL,    4, { 13, 0x03, 53, 0x93, 55, 0x87, 30, 0x13,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000800000000000ULL,    1, { 47, 0x63,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000100000000000ULL,    1, { 44, 0x72,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x1284000000000000ULL,    4, { 50, 0x73, 57, 0x68, 55, 0x74, 60, 0x69,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0D60000000800000ULL,    6, { 23, 0x07, 53, 0x34, 59, 0x88, 54, 0x38, 56, 0x56, 58, 0x78,  0, 0x00 } },
  { 0x0000000000038041ULL,    5, { 17, 0x68,  6, 0x20,  0, 0x06, 16, 0x38, 15, 0x77,  0, 0x00,  0, 0x00 } },
  { 0x0000000084000008ULL,    3, {  3, 0x05, 26, 0x21, 31, 0x67,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000080000000004ULL,    2, { 43, 0x86,  2, 0x10,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000400000000000ULL,    1, { 46, 0x86,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000020000000000ULL,    1, { 41, 0x27,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000001000008ULL,    2, {  3, 0x10, 24, 0x90,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0101800400000000ULL,    4, { 34, 0x81, 48, 0x39, 47, 0x34, 56, 0x49,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x4000000000000000ULL,    1, { 62, 0x77,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000200000000ULL,    1, { 33, 0x16,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x2010000003000000ULL,    4, { 24, 0x05, 52, 0x73, 25, 0x11, 61, 0x86,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x00000000001C0000ULL,    3, { 18, 0x70, 19, 0x11, 20, 0x62,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000010100000ULL,    2, { 20, 0x60, 28, 0x13,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0003800020000800ULL,    5, { 48, 0x95, 11, 0x09, 49, 0x68, 29, 0x17, 47, 0x45,  0, 0x00,  0, 0x00 } },
  { 0x0100040000004000ULL,    3, { 14, 0x09, 42, 0x28, 56, 0x95,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x2000480200000001ULL,    5, { 43, 0x28,  0, 0x00, 61, 0x98, 46, 0x38, 33, 0x81,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000080000000ULL,    1, { 31, 0x51,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0202000400020000ULL,    4, { 34, 0x15, 17, 0x50, 49, 0x63, 57, 0x48,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x1000000000000000ULL,    1, { 60, 0x48,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000040000ULL,    1, { 18, 0x60,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000108000030ULL,    4, {  5, 0x08,  4, 0x07, 32, 0x29, 27, 0x21,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000100000000000ULL,    1, { 44, 0x47,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x001C200000000200ULL,    5, { 50, 0x48, 45, 0x37,  9, 0x30, 52, 0x59, 51, 0x98,  0, 0x00,  0, 0x00 } },
  { 0x0080000000800000ULL,    2, { 23, 0x90, 55, 0x48,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x4000020080008000ULL,    4, { 62, 0x77, 41, 0x42, 31, 0x16, 15, 0x07,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000020000000ULL,    1, { 29, 0x31,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x4000300000008010ULL,    6, { 62, 0x75, 62, 0x57, 45, 0x33,  4, 0x10, 44, 0x24, 15, 0x50,  0, 0x00 } },
  { 0x0400000800000000ULL,    2, { 35, 0x12, 58, 0x49,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000E00400000ULL,    4, { 34, 0x56, 35, 0x27, 22, 0x90, 33, 0x65,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000004000000000ULL,    1, { 38, 0x32,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0E40000000000000ULL,    4, { 57, 0x86, 59, 0x98, 54, 0x93, 58, 0x97,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000030000ULL,    2, { 17, 0x06, 16, 0x03,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x32024C0000000000ULL,    7, { 43, 0x52, 49, 0x36, 57, 0x84, 61, 0x59, 60, 0x94, 42, 0x42, 46, 0x53 } },
  { 0x008C000000000020ULL,    4, { 50, 0x34,  5, 0x10, 55, 0x44, 51, 0x39,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x8800000000000000ULL,    3, { 59, 0x49, 63, 0x89, 63, 0x98,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x8000000000000000ULL,    1, { 63, 0x88,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000001E00002ULL,    5, {  1, 0x10, 23, 0x74, 22, 0x81, 24, 0x55, 21, 0x21,  0, 0x00,  0, 0x00 } },
  { 0x0000000002000000ULL,    1, { 25, 0x15,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000009000000000ULL,    2, { 36, 0x22, 39, 0x32,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0060000000001000ULL,    3, { 53, 0x44, 54, 0x84, 12, 0x01,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x1000000000000000ULL,    1, { 60, 0x86,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0101000000000000ULL,    2, { 48, 0x63, 56, 0x64,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000004800ULL,    2, { 11, 0x30, 14, 0x40,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0410000100000000ULL,    3, { 52, 0x35, 32, 0x12, 58, 0x84,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0xA808000000000000ULL,    4, { 59, 0x84, 51, 0x73, 61, 0x65, 63, 0x88,  0, 0x00,  0, 0x00,  0, 0x00 } },
  { 0x0000000000000000ULL,    0, {  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00,  0, 0x00 } }
};

typedef struct S_fncall {
  void *fn;
  uc north;
  uc east;
  uc south;
  uc west;
}Sfncall;
const Sfncall tfncall[78]={
  { Solver2016_BorderWest, C1N, C1E, D1N,  0 },
  { Solver2016_InnerTile,  C2N, C2E, D2N, C1E },
  { Solver2016_InnerTile,  C3N, C3E, D3N, C2E },
  { Solver2016_InnerTile,  C4N, C4E, D4N, C3E },
  { Solver2016_InnerTile,  C5N, C5E, D5N, C4E },
  { Solver2016_InnerTile,  C6N, C6E, D6N, C5E },
  { Solver2016_InnerTile,  C7N, C7E, D7N, C6E },
  { Solver2016_InnerTile,  C8N, C8E, D8N, C7E },
  { Solver2016_InnerTile,  C9N, C9E, D9N, C8E },
  { Solver2016_BorderEast, C10N, 0, D10N, C9E },
  { Solver2016_BorderWest, D1N, D1E, E1N,   0 },
  { Solver2016_InnerTile,  D2N, D2E, E2N, D1E },
  { Solver2016_InnerTile,  D3N, D3E, E3N, D2E },
  { Solver2016_InnerTile,  D4N, D4E, E4N, D3E },
  { Solver2016_InnerTile,  D5N, D5E, E5N, D4E },
  { Solver2016_InnerTile,  D6N, D6E, E6N, D5E },
  { Solver2016_InnerTile,  D7N, D7E, E7N, D6E },
  { Solver2016_InnerTile,  D8N, D8E, E8N, D7E },
  { Solver2016_InnerTile,  D9N, D9E, E9N, D8E },
  { Solver2016_BorderEast, D10N, 0, E10N, D9E },
  //{ Solver2016_Special_Debug, D10N, 0, E10N, D9E },
  { Solver2016_BorderWest, E1N, E1E, F1N,   0 },
  { Solver2016_InnerTile,  E2N, E2E, F2N, E1E },
  { Solver2016_InnerTile,  E3N, E3E, F3N, E2E },
  { Solver2016_InnerTile,  E4N, E4E, F4N, E3E },
  { Solver2016_InnerTile,  E5N, E5E, F5N, E4E },
  { Solver2016_InnerTile,  E6N, E6E, F6N, E5E },
  { Solver2016_InnerTile,  E7N, E7E, F7N, E6E },
  { Solver2016_InnerTile,  E8N, E8E, F8N, E7E },
  { Solver2016_InnerTile,  E9N, E9E, F9N, E8E },
  { Solver2016_BorderEast, E10N, 0, F10N, E9E },
  //{ Solver2016_Special_Debug, E10N, 0, F10N, E9E },
  { Solver2016_BorderWest, F1N, F1E, G1N,   0 },
  { Solver2016_InnerTile,  F2N, F2E, G2N, F1E },
  { Solver2016_InnerTile,  F3N, F3E, G3N, F2E },
  { Solver2016_InnerTile,  F4N, F4E, G4N, F3E },
  { Solver2016_InnerTile,  F5N, F5E, G5N, F4E },
  { Solver2016_InnerTile,  F6N, F6E, G6N, F5E },
  { Solver2016_InnerTile,  F7N, F7E, G7N, F6E },
  { Solver2016_InnerTile,  F8N, F8E, G8N, F7E },
  { Solver2016_InnerTile,  F9N, F9E, G9N, F8E },
  { Solver2016_BorderEast, F10N, 0, G10N, F9E },
  { Solver2016_BorderWest, G1N, G1E, H1N,   0 },
  { Solver2016_InnerTile,  G2N, G2E, H2N, G1E },
  { Solver2016_InnerTile,  G3N, G3E, H3N, G2E },
  { Solver2016_InnerTile,  G4N, G4E, H4N, G3E },
  { Solver2016_InnerTile,  G5N, G5E, H5N, G4E },
  { Solver2016_InnerTile,  G6N, G6E, H6N, G5E },
  { Solver2016_InnerTile,  G7N, G7E, H7N, G6E },
  { Solver2016_InnerTile,  G8N, G8E, H8N, G7E },
  { Solver2016_InnerTile,  G9N, G9E, H9N, G8E },
  { Solver2016_BorderEast, G10N, 0, H10N, G9E },
  { Solver2016_Special_H1, H1N, H1E, I1N,   0 },
  { Solver2016_Special_H2, H2N, H2E, I2N, H1E },
  { Solver2016_InnerTile,  H3N, H3E, I3N, H2E },
  { Solver2016_InnerTile,  H4N, H4E, I4N, H3E },
  { Solver2016_InnerTile,  H5N, H5E, I5N, H4E },
  { Solver2016_InnerTile,  H6N, H6E, I6N, H5E },
  { Solver2016_InnerTile,  H7N, H7E, I7N, H6E },
  { Solver2016_InnerTile,  H8N, H8E, I8N, H7E },
  { Solver2016_InnerTile,  H9N, H9E, I9N, H8E },
  { Solver2016_BorderEast, H10N, 0, I10N, H9E },
  { Solver2016_Special_I1, I1N, I1E, J1N,   0 },
  { Solver2016_InnerTile,  I2N, I2E, J2N, I1E },
  { Solver2016_InnerTile,  I3N, I3E, J3N, I2E },
  { Solver2016_InnerTile,  I4N, I4E, J4N, I3E },
  { Solver2016_InnerTile,  I5N, I5E, J5N, I4E },
  { Solver2016_InnerTile,  I6N, I6E, J6N, I5E },
  { Solver2016_InnerTile,  I7N, I7E, J7N, I6E },
  { Solver2016_InnerTile,  I8N, I8E, J8N, I7E },
  { Solver2016_InnerTile,  I9N, I9E, J9N, I8E },
  { Solver2016_BorderEast, I10N, 0, J10N, I9E },
  { Solver2016_BottomLine, J9N, J9E,   0, J8E },
  { Solver2016_BottomLine, J8N, J8E,   0, J7E },
  { Solver2016_BottomLine, J7N, J7E,   0, J6E },
  { Solver2016_BottomLine, J6N, J6E,   0, J5E },
  { Solver2016_BottomLine, J5N, J5E,   0, J4E },
  { Solver2016_BottomLine, J4N, J4E,   0, J3E },
  { Solver2016_BottomLine, J3N, J3E,   0, J2E },
  { Solver2016_BorderLast, J2N, J2E,   0, J1E }
};

//#######################################

static void Solver2016_BorderWest() {
  uint couleur, tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;

  couleur=in.tdam[tfncall[fn_idx].north];
  tuileB=tlscouleur_B2016[BORDERCOLOR_G + couleur] & in.bordertuile2do;
  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {//while(tuileB) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.tdam[tfncall[fn_idx].east]=tbordureI[tuile];
    in.tdam[tfncall[fn_idx].south]=tbordureD[tuile];
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }
}

static void Solver2016_BorderEast() {
  uint DtuileB, ItuileB, tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;

  DtuileB=tlscouleur_B2016[BORDERCOLOR_D + in.tdam[tfncall[fn_idx].north]] & in.bordertuile2do;
  ItuileB=tlscouleur_B2016[BORDERCOLOR_I + in.tdam[tfncall[fn_idx].west]] & in.bordertuile2do;
  tuileB= ItuileB & DtuileB;
  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.tdam[tfncall[fn_idx].south]=tbordureG[tuile];
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }
}

static void Solver2016_InnerTile() {
  uint64_t tuileB;
  uint tuile, couleur, fn1, tuileN;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;
  
  couleur= in.tdam[tfncall[fn_idx].west] + (in.tdam[tfncall[fn_idx].north] * 10);
  tuileB=in.tuile2do & tNEnoif[couleur].tuileB;  ifz(tuileB) goto fin;
  tuileN=tNEnoif[couleur].tuileN;   LOOP1(tuileN) {
    tuile=tNEnoif[couleur].t14[fn1*2 + 0];
    ifzbool64(in.tuile2do,tuile) continue;
    in.tdam[tfncall[fn_idx].east] =tNEnoif[couleur].t14[fn1*2 + 1] & 15;
    in.tdam[tfncall[fn_idx].south]=tNEnoif[couleur].t14[fn1*2 + 1] >> 4;
    in.tuile2do ^= (1ULL << tuile);
    fn_idx++;
    (*ptr)();
    in.tuile2do ^= (1ULL << tuile);
    fn_idx--;
  }
  fin:;
}

static void Solver2016_Special_H1() {
  uint couleur, tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;

  couleur= in.tdam[H1N];
  tuileB=tlscouleur_B2016[BORDERCOLOR_G + couleur] & in.bordertuile2do;
  ifz(tuileB) goto fin;

  //1st corner config //heavy customisation: corners 2 & 3 from brendan_pieces_10x10.txt 
  in.tdam[J1N] =2;
  in.tdam[J10N]=2;
  in.tdam[J9E] =4;
  in.tdam[J1E] =4;
  
  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.tdam[H1E]=tbordureI[tuile];
    in.tdam[I1N]=tbordureD[tuile];
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }

  //2nd corner config
  tuileB=tlscouleur_B2016[BORDERCOLOR_G + couleur] & in.bordertuile2do;
  
  //1st corner config //heavy customisation: corners 3 & 2 from brendan_pieces_10x10.txt 
  in.tdam[J1N] =4;
  in.tdam[J10N]=4;
  in.tdam[J9E] =2;
  in.tdam[J1E] =2;
  
  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.tdam[H1E]=tbordureI[tuile];
    in.tdam[I1N]=tbordureD[tuile];
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }

  fin:;
}

static void Solver2016_Special_H2() {
  uint64_t tuileB;
  uint couleuranticipee, tuile, couleur, fn1, tuileN;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;

  //O_O tremendous gain on my Haswell: 8 % !!! yes, global gain
  couleuranticipee=tlscouleur_B2016[BORDERCOLOR_G + in.tdam[I1N]] & tlscouleur_B2016[BORDERCOLOR_D + in.tdam[J1N]] & in.bordertuile2do;
  ifz(couleuranticipee) goto fin;

  couleur= in.tdam[H1E] + (in.tdam[H2N] * 10);
  tuileB=in.tuile2do & tNEnoif[couleur].tuileB;  ifz(tuileB) goto fin;

  tuileN=tNEnoif[couleur].tuileN;   LOOP1(tuileN) {
    tuile=tNEnoif[couleur].t14[fn1*2 + 0];
    ifzbool64(in.tuile2do,tuile) continue;
    in.tdam[H2E]=tNEnoif[couleur].t14[fn1*2 + 1] & 15;
    in.tdam[I2N]=tNEnoif[couleur].t14[fn1*2 + 1] >> 4;
    in.tuile2do ^= (1ULL << tuile);
    fn_idx++;
    (*ptr)();
    in.tuile2do ^= (1ULL << tuile);
    fn_idx--;
  }
  fin:;
}

static void Solver2016_Special_I1() {
  uint tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;
  
  tuileB=tlscouleur_B2016[BORDERCOLOR_G + in.tdam[I1N]] & tlscouleur_B2016[BORDERCOLOR_D + in.tdam[J1N]] & in.bordertuile2do;
  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.tdam[I1E]=tbordureI[tuile];
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    //Solver2016_I2();
    //tfncall[fn_idx].fn;
    //&tfncall[fn_idx].fn();
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }
}

static void Solver2016_Special_I10() {
  uint tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;
  tuileB=in.bordertuile2do & tlscouleur_B2016[BORDERCOLOR_D + in.tdam[H10N]] & tlscouleur_B2016[BORDERCOLOR_I + in.tdam[H9E]] & tlscouleur_B2016[BORDERCOLOR_G + in.tdam[J10N]];
  ifz(tuileB) goto fin;

  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }
  fin:;
}

static void Solver2016_BottomLine() {
  uint DtuileB, ItuileB, tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;
  
  DtuileB=tlscouleur_B2016[BORDERCOLOR_D + in.tdam[tfncall[fn_idx].east]]  & in.bordertuile2do;//east, not north !
  ItuileB=tlscouleur_B2016[BORDERCOLOR_I + in.tdam[tfncall[fn_idx].north]] & in.bordertuile2do;//north, not east !
  tuileB= DtuileB & ItuileB;
  ifz(tuileB) goto fin;

  tuileN=getbitN32(tuileB);
  LOOP1(tuileN) {
    tuile=__builtin_ctz(tuileB);
    tuileB^=(1U << tuile);
    in.tdam[tfncall[fn_idx].west]=tbordureG[tuile];//west, not south !
    in.bordertuile2do ^= (1U << tuile);
    fn_idx++;
    (*ptr)();
    in.bordertuile2do ^= (1U << tuile);
    fn_idx--;
  }
  fin:;
}

static void Solver2016_BorderLast() {
  uint tuileB;//DtuileB, ItuileB, GtuileB, 
  macro_globaltrace(fn_idx);
  tuileB=in.bordertuile2do & tlscouleur_B2016[BORDERCOLOR_D + in.tdam[J2E]] & tlscouleur_B2016[BORDERCOLOR_I + in.tdam[J2N]] & tlscouleur_B2016[BORDERCOLOR_I + in.tdam[J1E]];
  //ItuileB=tlscouleur_B2016[BORDERCOLOR_I + in.tdam[J2N]] & in.bordertuile2do;
  //GtuileB=tlscouleur_B2016[BORDERCOLOR_I + in.tdam[J1E]] & in.bordertuile2do;
  //tuileB= DtuileB & ItuileB & GtuileB;
  ifnz(tuileB) out.globalres++;//!!! bingo !!!
}

static void Solver2016_Special_Debug() {
  uint DtuileB, ItuileB, tuileB, tuileN, fn1, tuile;
  void (*ptr)(void);
  macro_globaltrace(fn_idx);
  ptr=tfncall[fn_idx+1].fn;

  DtuileB=tlscouleur_B2016[BORDERCOLOR_D + in.tdam[tfncall[fn_idx].north]] & in.bordertuile2do;
  ItuileB=tlscouleur_B2016[BORDERCOLOR_I + in.tdam[tfncall[fn_idx].west]] & in.bordertuile2do;
  tuileB= ItuileB & DtuileB;
  tuileN=getbitN32(tuileB);
  out.globalres+=tuileN;
}
