#ifndef _BIT8_H_
#define _BIT8_H_

// Bitwise helpers
#define BIT0 0x1
#define BIT1 0x2
#define BIT2 0x4
#define BIT3 0x8
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80

#define RBIT0(value) ((value) & 0x1)
#define RBIT1(value) (((value) >> 1) & 0x1)
#define RBIT2(value) (((value) >> 2) & 0x1)
#define RBIT3(value) (((value) >> 3) & 0x1)
#define RBIT4(value) (((value) >> 4) & 0x1)
#define RBIT5(value) (((value) >> 5) & 0x1)
#define RBIT6(value) (((value) >> 6) & 0x1)
#define RBIT7(value) (((value) >> 7) & 0x1)

#define WBIT0(base, value) (((base) & (0xFF ^ BIT0)) | ((value) & 0x1))
#define WBIT1(base, value) (((base) & (0xFF ^ BIT1)) | (((value) & 0x1) << 1))
#define WBIT2(base, value) (((base) & (0xFF ^ BIT2)) | (((value) & 0x1) << 2))
#define WBIT3(base, value) (((base) & (0xFF ^ BIT3)) | (((value) & 0x1) << 3))
#define WBIT4(base, value) (((base) & (0xFF ^ BIT4)) | (((value) & 0x1) << 4))
#define WBIT5(base, value) (((base) & (0xFF ^ BIT5)) | (((value) & 0x1) << 5))
#define WBIT6(base, value) (((base) & (0xFF ^ BIT6)) | (((value) & 0x1) << 6))
#define WBIT7(base, value) (((base) & (0xFF ^ BIT7)) | (((value) & 0x1) << 7))

#endif
