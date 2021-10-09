#ifndef _BIT16_H_
#define _BIT16_H_

// Bitwise helpers
#define BIT0 0x1
#define BIT1 0x2
#define BIT2 0x4
#define BIT3 0x8
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80
#define BIT8 0x100
#define BIT9 0x200
#define BIT10 0x400
#define BIT11 0x800
#define BIT12 0x1000
#define BIT13 0x2000
#define BIT14 0x4000
#define BIT15 0x8000

#define RBIT0(value) ((value) & 0x1)
#define RBIT1(value) (((value) >> 1) & 0x1)
#define RBIT2(value) (((value) >> 2) & 0x1)
#define RBIT3(value) (((value) >> 3) & 0x1)
#define RBIT4(value) (((value) >> 4) & 0x1)
#define RBIT5(value) (((value) >> 5) & 0x1)
#define RBIT6(value) (((value) >> 6) & 0x1)
#define RBIT7(value) (((value) >> 7) & 0x1)
#define RBIT8(value) (((value) >> 8) & 0x1)
#define RBIT9(value) (((value) >> 9) & 0x1)
#define RBIT10(value) (((value) >> 10) & 0x1)
#define RBIT11(value) (((value) >> 11) & 0x1)
#define RBIT12(value) (((value) >> 12) & 0x1)
#define RBIT13(value) (((value) >> 13) & 0x1)
#define RBIT14(value) (((value) >> 14) & 0x1)
#define RBIT15(value) (((value) >> 15) & 0x1)

#define WBIT0(base, value) (((base) & (0xFFFF ^ BIT0)) | ((value) & 0x1))
#define WBIT1(base, value) (((base) & (0xFFFF ^ BIT1)) | (((value) & 0x1) << 1))
#define WBIT2(base, value) (((base) & (0xFFFF ^ BIT2)) | (((value) & 0x1) << 2))
#define WBIT3(base, value) (((base) & (0xFFFF ^ BIT3)) | (((value) & 0x1) << 3))
#define WBIT4(base, value) (((base) & (0xFFFF ^ BIT4)) | (((value) & 0x1) << 4))
#define WBIT5(base, value) (((base) & (0xFFFF ^ BIT5)) | (((value) & 0x1) << 5))
#define WBIT6(base, value) (((base) & (0xFFFF ^ BIT6)) | (((value) & 0x1) << 6))
#define WBIT7(base, value) (((base) & (0xFFFF ^ BIT7)) | (((value) & 0x1) << 7))
#define WBIT8(base, value) (((base) & (0xFFFF ^ BIT8)) | (((value) & 0x1) << 8))
#define WBIT9(base, value) (((base) & (0xFFFF ^ BIT9)) | (((value) & 0x1) << 9))
#define WBIT10(base, value) (((base) & (0xFFFF ^ BIT10)) | (((value) & 0x1) << 10))
#define WBIT11(base, value) (((base) & (0xFFFF ^ BIT11)) | (((value) & 0x1) << 11))
#define WBIT12(base, value) (((base) & (0xFFFF ^ BIT12)) | (((value) & 0x1) << 12))
#define WBIT13(base, value) (((base) & (0xFFFF ^ BIT13)) | (((value) & 0x1) << 13))
#define WBIT14(base, value) (((base) & (0xFFFF ^ BIT14)) | (((value) & 0x1) << 14))
#define WBIT15(base, value) (((base) & (0xFFFF ^ BIT15)) | (((value) & 0x1) << 15))

#endif
