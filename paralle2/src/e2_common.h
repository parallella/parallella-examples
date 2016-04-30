#define CORE_N 16

//to DEVICE
#pragma pack(4)
typedef struct S_input {
	uint64_t tuile2do;
	uint bordertuile2do;
	uc tdam[180];
}Sinput;
//from DEVICE
#pragma pack(4)
typedef struct S_output {
	uint64_t globaltsolN[160];
  uint globalres;
}Soutput;
//shared MEMORY
#pragma pack(4)
typedef struct S_io {
  uint    tcmd[CORE_N];
  Sinput  tin [CORE_N];
  Soutput tout[CORE_N];
}Sio;

#define SHARED_RAM (0x01000000)
#define CMD_LEN (CORE_N * sizeof(uint)) //ARM handling Epiphany tasks: start, end
#define CMD_INIT 0x80000000 //host init
#define CMD_DONE 0x40000000 //eCore did the job properly (probably ; some bug might crush this word but it's highly improbable)

//ARM <-> Epiphany
#define SHARED_IN  0x6000 // (SHARED_RAM + CMD_LEN)
#define SHARED_OUT (SHARED_IN  + sizeof(Sinput))

//specific to the project

#define NORTH 0
#define EAST  1
#define SOUTH 2
#define WEST  3

#define A1 0
#define A2 1
#define A3 2
#define A4 3
#define A5 4
#define A6 5
#define A7 6
#define A8 7
#define A9 8
#define A10 9
#define B1 16
#define B2 17
#define B3 18
#define B4 19
#define B5 20
#define B6 21
#define B7 22
#define B8 23
#define B9 24
#define B10 25
#define C1 32
#define C2 33
#define C3 34
#define C4 35
#define C5 36
#define C6 37
#define C7 38
#define C8 39
#define C9 40
#define C10 41
#define D1 48
#define D2 49
#define D3 50
#define D4 51
#define D5 52
#define D6 53
#define D7 54
#define D8 55
#define D9 56
#define D10 57
#define E1 64
#define E2 65
#define E3 66
#define E4 67
#define E5 68
#define E6 69
#define E7 70
#define E8 71
#define E9 72
#define E10 73
#define F1 80
#define F2 81
#define F3 82
#define F4 83
#define F5 84
#define F6 85
#define F7 86
#define F8 87
#define F9 88
#define F10 89
#define G1 96
#define G2 97
#define G3 98
#define G4 99
#define G5 100
#define G6 101
#define G7 102
#define G8 103
#define G9 104
#define G10 105
#define H1 112
#define H2 113
#define H3 114
#define H4 115
#define H5 116
#define H6 117
#define H7 118
#define H8 119
#define H9 120
#define H10 121
#define I1 128
#define I2 129
#define I3 130
#define I4 131
#define I5 132
#define I6 133
#define I7 134
#define I8 135
#define I9 136
#define I10 137
#define J1 144
#define J2 145
#define J3 146
#define J4 147
#define J5 148
#define J6 149
#define J7 150
#define J8 151
#define J9 152
#define J10 153

#define B1N  9
#define B2N  10
#define B3N  11
#define B4N  12
#define B5N  13
#define B6N  14
#define B7N  15
#define B8N  16
#define B9N  17
#define B10N 18
#define C1N  28
#define C2N  29
#define C3N  30
#define C4N  31
#define C5N  32
#define C6N  33
#define C7N  34
#define C8N  35
#define C9N  36
#define C10N 37
#define D1N  47
#define D2N  48
#define D3N  49
#define D4N  50
#define D5N  51
#define D6N  52
#define D7N  53
#define D8N  54
#define D9N  55
#define D10N 56
#define E1N  66
#define E2N  67
#define E3N  68
#define E4N  69
#define E5N  70
#define E6N  71
#define E7N  72
#define E8N  73
#define E9N  74
#define E10N 75
#define F1N  85
#define F2N  86
#define F3N  87
#define F4N  88
#define F5N  89
#define F6N  90
#define F7N  91
#define F8N  92
#define F9N  93
#define F10N 94
#define G1N  104
#define G2N  105
#define G3N  106
#define G4N  107
#define G5N  108
#define G6N  109
#define G7N  110
#define G8N  111
#define G9N  112
#define G10N 113
#define H1N  123
#define H2N  124
#define H3N  125
#define H4N  126
#define H5N  127
#define H6N  128
#define H7N  129
#define H8N  130
#define H9N  131
#define H10N 132
#define I1N  142
#define I2N  143
#define I3N  144
#define I4N  145
#define I5N  146
#define I6N  147
#define I7N  148
#define I8N  149
#define I9N  150
#define I10N 151
#define J1N  161
#define J2N  162
#define J3N  163
#define J4N  164
#define J5N  165
#define J6N  166
#define J7N  167
#define J8N  168
#define J9N  169
#define J10N 170

#define A1E  0
#define A2E  1
#define A3E  2
#define A4E  3
#define A5E  4
#define A6E  5
#define A7E  6
#define A8E  7
#define A9E  8
#define B1E  19
#define B2E  20
#define B3E  21
#define B4E  22
#define B5E  23
#define B6E  24
#define B7E  25
#define B8E  26
#define B9E  27
#define C1E  38
#define C2E  39
#define C3E  40
#define C4E  41
#define C5E  42
#define C6E  43
#define C7E  44
#define C8E  45
#define C9E  46
#define D1E  57
#define D2E  58
#define D3E  59
#define D4E  60
#define D5E  61
#define D6E  62
#define D7E  63
#define D8E  64
#define D9E  65
#define E1E  76
#define E2E  77
#define E3E  78
#define E4E  79
#define E5E  80
#define E6E  81
#define E7E  82
#define E8E  83
#define E9E  84
#define F1E  95
#define F2E  96
#define F3E  97
#define F4E  98
#define F5E  99
#define F6E  100
#define F7E  101
#define F8E  102
#define F9E  103
#define G1E  114
#define G2E  115
#define G3E  116
#define G4E  117
#define G5E  118
#define G6E  119
#define G7E  120
#define G8E  121
#define G9E  122
#define H1E  133
#define H2E  134
#define H3E  135
#define H4E  136
#define H5E  137
#define H6E  138
#define H7E  139
#define H8E  140
#define H9E  141
#define I1E  152
#define I2E  153
#define I3E  154
#define I4E  155
#define I5E  156
#define I6E  157
#define I7E  158
#define I8E  159
#define I9E  160
#define J1E 171
#define J2E 172
#define J3E 173
#define J4E 174
#define J5E 175
#define J6E 176
#define J7E 177
#define J8E 178
#define J9E 179

#define ARG_TO_COLOR 5 //from true color to program color (-5 pour les couleurs interieures)

#define getlongcolor(longcolor,orient) (((longcolor) >> ((orient)*8)) & 255)
#define getnord(longcolor) ((longcolor)&0xff)
#define getest(longcolor) (((longcolor)>>8)&0xff)
#define getsud(longcolor) (((longcolor)>>16)&0xff)
#define getouest(longcolor) (((longcolor)>>24)&0xff)

#define macro_globaltrace(niveau) out.globaltsolN[niveau]++;

const uint tcoin[4]={0,1,2,3};

//#######################################
//from 16-NEnoifpext2.c

#define BORDERCOLOR_D 0
#define BORDERCOLOR_G 4
#define BORDERCOLOR_I 9
#define BORDERCOLOR_N 19 //19 couleurs, avec la 1re qui est vide, les couleurs 1-4 sont pour D(roite), 5-8 pour G(auche), 9-18 pour I(nterieur)
