--
-- Helper module for building MOS6502 instruction binaries
--
local ByteEncoder = yatm.ByteEncoder

if not ByteEncoder then
  minetest.log("warn", "Memory module requires yatm.ByteEncoder")
  return
end

local Builder = {}
local m = Builder

local function imm(val)
  return ByteEncoder:e_i8(val)
end

local function abs(addr)
  return ByteEncoder:e_u16(addr)
end

-- BRK impl      // case 0x00:
function m.brk()
  return "\x00"
end

-- ADC #         // case 0x69:
function m.adc_imm(val)
  return "\x69" .. imm(val)
end

-- ADC abs       // case 0x6D:
function m.adc_abs(addr)
  return "\x6D" .. abs(addr)
end

-- ADC abs,X     // case 0x7D:
function m.adc_abs_x(addr)
  return "\x7D" .. abs(addr)
end

-- ADC abs,Y     // case 0x79:
function m.adc_abs_y(addr)
  return "\x79" .. abs(addr)
end

-- ADC ind,Y     // case 0x71:
function m.adc_ind_y(addr)
  return "\x71" .. imm(addr)
end

-- ADC X,ind     // case 0x61:
function m.adc_x_ind(addr)
  return "\x61" .. imm(addr)
end

-- ADC zpg       // case 0x65:
function m.adc_zpg(addr)
  return "\x65" .. imm(addr)
end

-- ADC zpg,X     // case 0x75:
function m.adc_zpg_x(addr)
  return "\x75" .. imm(addr)
end

-- AND #         // case 0x29:
function m.and_imm(val)
  return "\x29" .. imm(val)
end

-- AND abs       // case 0x2D:
function m.and_abs(addr)
  return "\x2D" .. abs(addr)
end

-- AND abs,X     // case 0x3D:
function m.and_abs_x(addr)
  return "\x3D" .. abs(addr)
end

-- AND abs,Y     // case 0x39:
function m.and_abs_y(addr)
  return "\x39" .. abs(addr)
end

-- AND ind,Y     // case 0x31:
function m.and_ind_y(addr)
  return "\x31" .. imm(addr)
end

-- AND X,ind     // case 0x21:
function m.and_x_ind(addr)
  return "\x21" .. imm(addr)
end

-- AND zpg       // case 0x25:
function m.and_zpg(addr)
  return "\x25" .. imm(addr)
end

-- AND zpg,X     // case 0x35:
function m.and_zpg_x(addr)
  return "\x35" .. imm(addr)
end


-- ASL A         // case 0x0A:
function m.asl_a()
  return "\x0A"
end

-- ASL abs       // case 0x0E:
function m.asl_abs(val)
  return "\x0E" .. abs(val)
end

-- ASL abs,X     // case 0x1E:
function m.asl_abs_x(val)
  return "\x1E" .. abs(val)
end

-- ASL zpg       // case 0x06:
function m.asl_zpg(addr)
  return "\x06" .. imm(addr)
end

-- ASL zpg,X     // case 0x16:
function m.asl_zpg_x(addr)
  return "\x16" .. imm(addr)
end

-- BCC rel       // case 0x90:
function m.bcc(offset)
  return "\x90" .. imm(offset)
end

-- BCS rel       // case 0xB0:
function m.bcs(offset)
  return "\xB0" .. imm(offset)
end

-- BEQ rel       // case 0xF0:
function m.beq(offset)
  return "\xF0" .. imm(offset)
end

-- BIT abs       // case 0x2C:
function m.bit(addr)
  return "\x2C" .. abs(addr)
end

-- BIT zpg       // case 0x24:
function m.bit(addr)
  return "\x24" .. imm(addr)
end

-- BMI rel       // case 0x30:
function m.bmi(offset)
  return "\x30" .. imm(offset)
end

-- BNE rel       // case 0xD0:
function m.bne(offset)
  return "\xD0" .. imm(offset)
end

-- BPL rel       // case 0x10:
function m.bpl(offset)
  return "\x10" .. imm(offset)
end

-- BVC rel       // case 0x50:
function m.bvc(offset)
  return "\x50" .. imm(offset)
end

-- BVS rel       // case 0x70:
function m.bvs(offset)
  return "\x70" .. imm(offset)
end

-- CLC impl      // case 0x18:
function m.clc()
  return "\x18"
end

-- CLD impl      // case 0xD8:
function m.cld()
  return "\xD8"
end

-- CLI impl      // case 0x58:
function m.cli()
  return "\x58"
end

-- CLV impl      // case 0xB8:
function m.clv()
  return "\xB8"
end

-- CMP #         // case 0xC9:
function m.cmp_imm(val)
  return "\xC9" .. imm(val)
end

-- CMP abs       // case 0xCD:
function m.cmp_abs(addr)
  return "\xCD" .. abs(addr)
end

-- CMP abs,X     // case 0xDD:
function m.cmp_abs_x(addr)
  return "\xDD" .. abs(addr)
end

-- CMP abs,Y     // case 0xD9:
function m.cmp_abs_y(addr)
  return "\xD9" .. abs(addr)
end

-- CMP ind,Y     // case 0xD1:
function m.cmp_ind_y(addr)
  return "\xD1" .. imm(addr)
end

-- CMP X,ind     // case 0xC1:
function m.cmp_x_ind(addr)
  return "\xC1" .. imm(addr)
end

-- CMP zpg       // case 0xC5:
function m.cmp_zpg(addr)
  return "\xC5" .. imm(addr)
end

-- CMP zpg,X     // case 0xD5:
function m.cmp_zpg_x(addr)
  return "\xD5" .. imm(addr)
end

-- CPX #         // case 0xE0:
function m.cpx_imm(val)
  return "\xE0" .. imm(val)
end

-- CPX abs       // case 0xEC:
function m.cpx_abs(addr)
  return "\xEC" .. abs(addr)
end

-- CPX zpg       // case 0xE4:
function m.cpx_zpg(addr)
  return "\xE4" .. zpg(addr)
end

-- CPY #         // case 0xC0:
function m.cpy_imm(val)
  return "\xC0" .. imm(val)
end

-- CPY abs       // case 0xCC:
function m.cpy_abs(addr)
  return "\xCC" .. abs(addr)
end

-- CPY zpg       // case 0xC4:
function m.cpy_zpg(addr)
  return "\xCC" .. imm(addr)
end

-- DEC abs       // case 0xCE:
function m.dec_abs(addr)
  return "\xCE" .. abs(addr)
end

-- DEC abs,X     // case 0xDE:
function m.dec_abs_x(addr)
  return "\xDE" .. abs(addr)
end

-- DEC zpg       // case 0xC6:
function m.dec_zpg(addr)
  return "\xC6" .. imm(addr)
end

-- DEC zpg,X     // case 0xD6:
function m.dec_zpg_x(addr)
  return "\xD6" .. imm(addr)
end

-- DEX impl      // case 0xCA:
function m.dex()
  return "\xCA"
end

-- DEY impl      // case 0x88:
function m.dey()
  return "\x88"
end

-- EOR #         // case 0x49:
function m.eor_imm(val)
  return "\x49" .. imm(val)
end

-- EOR abs       // case 0x4D:
function m.eor_abs(addr)
  return "\x4D" .. abs(addr)
end

-- EOR abs,X     // case 0x5D:
function m.eor_abs_x(addr)
  return "\x5D" .. abs(addr)
end

-- EOR abs,Y     // case 0x59:
function m.eor_abs_y(addr)
  return "\x59" .. abs(addr)
end

-- EOR ind,Y     // case 0x51:
function m.eor_ind_y(addr)
  return "\x51" .. imm(addr)
end

-- EOR X,ind     // case 0x41:
function m.eor_x_ind(addr)
  return "\x41" .. imm(addr)
end

-- EOR zpg       // case 0x45:
function m.eor_zpg(adrr)
  return "\x45" .. imm(addr)
end

-- EOR zpg,X     // case 0x55:
function m.eor_zpg(addr)
  return "\x55" .. imm(addr)
end

-- INC abs       // case 0xEE:
function m.inc_abs(addr)
  return "\xEE" .. abs(addr)
end

-- INC abs,X     // case 0xFE:
function m.inc_abs_x(addr)
  return "\xFE" .. abs(addr)
end

-- INC zpg       // case 0xE6:
function m.inc_zpg(addr)
  return "\xE6" .. imm(addr)
end

-- INC zpg,X     // case 0xF6:
function m.inc_zpg_x(addr)
  return "\xF6" .. imm(addr)
end


-- INX impl      // case 0xE8:
function m.inx()
  return "\xE8"
end

-- INY impl      // case 0xC8:
function m.iny()
  return "\xC8"
end

-- JMP abs       // case 0x4C:
function m.jmp_abs(addr)
  return "\x4C" .. abs(addr)
end

-- JMP ind       // case 0x6C:
function m.jmp_ind(add)
  return "\x6C" .. abs(addr)
end

-- JSR abs       // case 0x20:
function m.jsr_abs(addr)
  return "\x20" .. abs(addr)
end

-- LDA #         // case 0xA9:
function m.lda_imm(val)
  return "\xA9" .. imm(val)
end

-- LDA abs       // case 0xAD:
function m.lda_abs(addr)
  return "\xAD" .. abs(addr)
end

-- LDA abs,X     // case 0xBD:
function m.lda_abs_x(addr)
  return "\xBD" .. abs(addr)
end

-- LDA abs,Y     // case 0xB9:
function m.lda_abs_y(addr)
  return "\xB9" .. abs(addr)
end

-- LDA ind,Y     // case 0xB1:
function m.lda_ind_y(addr)
  return "\xB1" .. imm(addr)
end

-- LDA X,ind     // case 0xA1:
function m.lda_x_ind(addr)
  return "\xA1" .. imm(addr)
end

-- LDA zpg       // case 0xA5:
function m.lda_zpg(addr)
  return "\xA5" .. imm(addr)
end

-- LDA zpg,X     // case 0xB5:
function m.lda_zpg_x()
  return "\xB5" .. imm(addr)
end

-- LDX #         // case 0xA2:
function m.ldx_imm(val)
  return "\xA2" .. imm(val)
end

-- LDX abs       // case 0xAE:
function m.ldx_abs(addr)
  return "\xAE" .. abs(addr)
end

-- LDX abs,Y     // case 0xBE:
function m.ldx_abs(addr)
  return "\xBE" .. abs(addr)
end

-- LDX zpg       // case 0xA6:
function m.ldx_zpg(addr)
  return "\xA6" .. imm(addr)
end

-- LDX zpg,Y     // case 0xB6:
function m.ldx_zpg(addr)
  return "\xB6" .. imm(addr)
end

-- LDY #         // case 0xA0:
function m.ldy_imm(val)
  return "\xA0" .. imm(val)
end

-- LDY abs       // case 0xAC:
function m.ldy_abs(addr)
  return "\xAC" .. abs(addr)
end

-- LDY abs,X     // case 0xBC:
function m.ldy_abs_x(addr)
  return "\xBC" .. abs(addr)
end

-- LDY zpg       // case 0xA4:
function m.ldy_zpg(addr)
  return "\xA4" .. imm(addr)
end

-- LDY zpg,X     // case 0xB4:
function m.ldy_zpg_x(addr)
  return "\xB4" .. imm(addr)
end

-- LSR A         // case 0x4A:
function m.lsr_a()
  return "\x4A"
end

-- LSR abs       // case 0x4E:
function m.lsr_abs(addr)
  return "\x4E" .. abs(addr)
end

-- LSR abs,X     // case 0x5E:
function m.lsr_abs_x(addr)
  return "\x5E" .. abs(addr)
end

-- LSR zpg       // case 0x46:
function m.lsr_zpg(addr)
  return "\x46" .. imm(addr)
end

-- LSR zpg,X     // case 0x56:
function m.lsr_zpg_x(addr)
  return "\x56" .. imm(addr)
end

-- NOP impl      // case 0xEA:
function m.nop()
  return "\xEA"
end

-- ORA #         // case 0x09:
function m.ora_imm(val)
  return "\x09" .. imm(val)
end

-- ORA abs       // case 0x0D:
function m.ora_abs(addr)
  return "\x0D" .. abs(addr)
end

-- ORA abs,X     // case 0x1D:
function m.ora(addr)
  return "\x1D" .. abs(addr)
end

-- ORA abs,Y     // case 0x19:
function m.ora(addr)
  return "\x19" .. abs(addr)
end

-- ORA ind,Y     // case 0x11:
function m.ora(addr)
  return "\x11" .. imm(addr)
end

-- ORA X,ind     // case 0x01:
function m.ora(addr)
  return "\x01" .. imm(addr)
end

-- ORA zpg       // case 0x05:
function m.ora(addr)
  return "\x05" .. imm(addr)
end

-- ORA zpg,X     // case 0x15:
function m.ora(addr)
  return "\x15" .. imm(addr)
end

-- PHA impl      // case 0x48:
function m.pha()
  return "\x48"
end

-- PHP impl      // case 0x08:
function m.php()
  return "\x08"
end

-- PLA impl      // case 0x68:
function m.pla()
  return "\x68"
end

-- PLP impl      // case 0x28:
function m.plp()
  return "\x28"
end

-- ROL A         // case 0x2A:
function m.rol_a()
  return "\x36"
end

-- ROL abs       // case 0x2E:
function m.rol_abs(addr)
  return "\x2E" .. abs(addr)
end

-- ROL abs,X     // case 0x3E:
function m.rol_abs_x(addr)
  return "\x3E" .. abs(addr)
end

-- ROL zpg       // case 0x26:
function m.rol_zpg()
  return "\x26" .. imm(addr)
end

-- ROL zpg,X     // case 0x36:
function m.rol_zpg_x(addr)
  return "\x36" .. imm(addr)
end

-- ROR A         // case 0x6A:
function m.ror_a()
  return "\x6A"
end

-- ROR abs       // case 0x6E:
function m.ror_abs(addr)
  return "\x6E" .. abs(addr)
end

-- ROR abs,X     // case 0x7E:
function m.ror_abs_x(addr)
  return "\x7E" .. abs(addr)
end

-- ROR zpg       // case 0x66:
function m.ror_zpg(addr)
  return "\x66" .. imm(addr)
end

-- ROR zpg,X     // case 0x76:
function m.ror_zpg_x(addr)
  return "\x76" .. imm(addr)
end

-- RTI impl      // case 0x40:
function m.rti()
  return "\x40"
end

-- RTS impl      // case 0x60:
function m.rts()
  return "\x60"
end

-- SBC #         // case 0xE9:
function m.sbc_imm(val)
  return "\xE9" .. imm(val)
end

-- SBC abs       // case 0xED:
function m.sbc_abs(addr)
  return "\xED" .. abs(addr)
end

-- SBC abs,X     // case 0xFD:
function m.sbc_abs_x(addr)
  return "\xFD" .. abs(addr)
end

-- SBC abs,Y     // case 0xF9:
function m.sbc_abx_y(addr)
  return "\xF9" .. abs(addr)
end

-- SBC ind,Y     // case 0xF1:
function m.sbc_ind_y(addr)
  return "\xF1" .. imm(addr)
end

-- SBC X,ind     // case 0xE1:
function m.sbc_x_ind(addr)
  return "\xE1" .. imm(addr)
end

-- SBC zpg       // case 0xE5:
function m.sbc_zpg(addr)
  return "\xE5" .. imm(addr)
end

-- SBC zpg,X     // case 0xF5:
function m.sbc_zpg_x(addr)
  return "\xF5" .. imm(addr)
end

-- SEC impl      // case 0x38:
function m.sec()
  return "\x38"
end

-- SED impl      // case 0xF8:
function m.sed()
  return "\xF8"
end

-- SEI impl      // case 0x78:
function m.sei()
  return "\x78"
end

-- STA abs       // case 0x8D:
function m.sta_abs(addr)
  return "\x8D" .. abs(addr)
end

-- STA abs,X     // case 0x9D:
function m.sta_abs_x(addr)
  return "\x9D" .. abs(addr)
end

-- STA abs,Y     // case 0x99:
function m.sta_abs_y(addr)
  return "\x99" .. abs(addr)
end

-- STA ind,Y     // case 0x91:
function m.sta_ind_y(addr)
  return "\x91" .. imm(addr)
end

-- STA X,ind     // case 0x81:
function m.sta_x_ind(addr)
  return "\x81" .. imm(addr)
end

-- STA zpg       // case 0x85:
function m.sta_zpg(addr)
  return "\x85" .. imm(addr)
end

-- STA zpg,X     // case 0x95:
function m.sta_zpg_x(addr)
  return "\x95" .. imm(addr)
end

-- STX abs       // case 0x8E:
function m.stx_abs(addr)
  return "\x8E" .. abs(addr)
end

-- STX zpg       // case 0x86:
function m.stx_zpg(addr)
  return "\x86" .. imm(addr)
end

-- STX zpg,Y     // case 0x96:
function m.stx_zpg_y(addr)
  return "\x96" .. imm(addr)
end

-- STY abs       // case 0x8C:
function m.sty_abs(addr)
  return "\x8C" .. abs(addr)
end

-- STY zpg       // case 0x84:
function m.sty_zpg(addr)
  return "\x84" .. imm(addr)
end

-- STY zpg,X     // case 0x94:
function m.sty_zpg_x(addr)
  return "\x94" .. imm(addr)
end

-- TAX impl      // case 0xAA:
function m.tax()
  return "\xAA"
end

-- TAY impl      // case 0xA8:
function m.tay()
  return "\xA8"
end

-- TSX impl      // case 0xBA:
function m.tsx()
  return "\xBA"
end

-- TXA impl      // case 0x8A:
function m.txa()
  return "\x8A"
end

-- TXS impl      // case 0x9A:
function m.txs()
  return "\x9A"
end

-- TYA impl      // case 0x98:
function m.tya()
  return "\x98"
end

yatm_oku.OKU.isa.MOS6502.Builder = Builder
