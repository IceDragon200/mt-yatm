local nmos_assembly = {
  ["adc"] = {
    {"adc_imm", {"immediate"}},
    {"adc_zpg", {"zeropage"}},
    {"adc_zpg_x", {"zeropage_x"}},
    {"adc_abs", {"absolute"}},
    {"adc_abs_x", {"absolute_x"}},
    {"adc_abs_y", {"absolute_y"}},
    {"adc_ind_x", {"indirect_x"}},
    {"adc_ind_y", {"indirect_y"}},
  },
  ["and"] = {
    {"and_imm", {"immediate"}},
    {"and_zpg", {"zeropage"}},
    {"and_zpg_x", {"zeropage_x"}},
    {"and_abs", {"absolute"}},
    {"and_abs_x", {"absolute_x"}},
    {"and_abs_y", {"absolute_y"}},
    {"and_ind_x", {"indirect_x"}},
    {"and_ind_y", {"indirect_y"}},
  },
  ["asl"] = {
    {"asl_a", {"register_a"}},
    {"asl_zpg", {"zeropage"}},
    {"asl_zpg_x", {"zeropage_x"}},
    {"asl_abs", {"absolute"}},
    {"asl_abs_x", {"absolute_x"}},
  },

  ["bit"] = {
    {"bit_zpg", {"zeropage"}},
    {"bit_abs", {"absolute"}},
  },

  ["bpl"] = {
    {"bpl", {}},
  },
  ["bmi"] = {
    {"bmi", {}},
  },
  ["bvc"] = {
    {"bvc", {}},
  },
  ["bcc"] = {
    {"bcc", {}},
  },
  ["bcs"] = {
    {"bcs", {}},
  },
  ["bne"] = {
    {"bne", {}},
  },
  ["beq"] = {
    {"beq", {}},
  },

  ["brk"] = {
    {"brk", {}},
  },

  ["cmp"] = {
    {"cmp_imm", {"immediate"}},
    {"cmp_zpg", {"zeropage"}},
    {"cmp_zpg_x", {"zeropage_x"}},
    {"cmp_abs", {"absolute"}},
    {"cmp_abs_x", {"absolute_x"}},
    {"cmp_abs_y", {"absolute_y"}},
    {"cmp_ind_x", {"indirect_x"}},
    {"cmp_ind_y", {"indirect_y"}},
  },

  ["cpx"] = {
    {"cpx_imm", {"immediate"}},
    {"cpx_zpg", {"zeropage"}},
    {"cpx_abs", {"absolute"}},
  },

  ["cpy"] = {
    {"cpy_imm", {"immediate"}},
    {"cpy_zpg", {"zeropage"}},
    {"cpy_abs", {"absolute"}},
  },

  ["dec"] = {
    {"dec_zpg", {"zeropage"}},
    {"dec_zpg_x", {"zeropage_x"}},
    {"dec_abs", {"absolute"}},
    {"dec_abs_x", {"absolute_x"}},
  },

  ["eor"] = {
    {"eor_imm", {"immediate"}},
    {"eor_zpg", {"zeropage"}},
    {"eor_zpg_x", {"zeropage_x"}},
    {"eor_abs", {"absolute"}},
    {"eor_abs_x", {"absolute_x"}},
    {"eor_abs_y", {"absolute_y"}},
    {"eor_ind_x", {"indirect_x"}},
    {"eor_ind_y", {"indirect_y"}},
  },

  ["clc"] = {
    {"clc", {}},
  },
  ["sec"] = {
    {"sec", {}},
  },
  ["cli"] = {
    {"cli", {}},
  },
  ["sei"] = {
    {"sei", {}},
  },
  ["clv"] = {
    {"clv", {}},
  },
  ["cld"] = {
    {"cld", {}},
  },
  ["sed"] = {
    {"sed", {}},
  },

  ["inc"] = {
    {"inc_zpg", {"zeropage"}},
    {"inc_zpg_x", {"zeropage_x"}},
    {"inc_abs", {"absolute"}},
    {"inc_abs_x", {"absolute_x"}},
  },
  ["jmp"] = {
    {"jmp", {"absolute"}},
    {"jmp", {"indirect"}},
  },
  ["jsr"] = {
    {"jsr_abs", {"absolute"}},
  },
  ["lda"] = {
    {"lda_imm", {"immediate"}},
    {"lda_zpg", {"zeropage"}},
    {"lda_zpg_x", {"zeropage_x"}},
    {"lda_abs", {"absolute"}},
    {"lda_abs_x", {"absolute_x"}},
    {"lda_abs_y", {"absolute_y"}},
    {"lda_ind_x", {"indirect_x"}},
    {"lda_ind_y", {"indirect_y"}},
  },
  ["ldx"] = {
    {"ldx_imm", {"immediate"}},
    {"ldx_zpg", {"zeropage"}},
    {"ldx_zpg_y", {"zeropage_y"}},
    {"ldx_abs", {"absolute"}},
    {"ldx_abs_y", {"absolute_y"}},
  },
  ["ldy"] = {
    {"ldy_imm", {"immediate"}},
    {"ldy_zpg", {"zeropage"}},
    {"ldy_zpg_x", {"zeropage_x"}},
    {"ldy_abs", {"absolute"}},
    {"ldy_abs_x", {"absolute_x"}},
  },
  ["lsr"] = {
    {"ldy_a", {"register_a"}},
    {"ldy_zpg", {"zeropage"}},
    {"ldy_zpg_x", {"zeropage_x"}},
    {"ldy_abs", {"absolute"}},
    {"ldy_abs_x", {"absolute_x"}},
  },

  ["nop"] = {
    {"nop", {}},
  },

  ["ora"] = {
    {"ora_imm", {"immediate"}},
    {"ora_zpg", {"zeropage"}},
    {"ora_zpg_x", {"zeropage_x"}},
    {"ora_abs", {"absolute"}},
    {"ora_abs_x", {"absolute_x"}},
    {"ora_abs_y", {"absolute_y"}},
    {"ora_ind_x", {"indirect_x"}},
    {"ora_ind_y", {"indirect_y"}},
  },

  ["tax"] = {
    {"tax", {}},
  },
  ["txa"] = {
    {"txa", {}},
  },
  ["dex"] = {
    {"dex", {}},
  },
  ["inx"] = {
    {"inx", {}},
  },
  ["tay"] = {
    {"tay", {}},
  },
  ["tya"] = {
    {"tya", {}},
  },
  ["dey"] = {
    {"dey", {}},
  },
  ["iny"] = {
    {"iny", {}},
  },

  ["rol"] = {
    {"rol_a", {"register_a"}},
    {"rol_zpg", {"zeropage"}},
    {"rol_zpg_x", {"zeropage_x"}},
    {"rol_abs", {"absolute"}},
    {"rol_abs_x", {"absolute_x"}},
  },
  ["ror"] = {
    {"ror_a", {"register_a"}},
    {"ror_zpg", {"zeropage"}},
    {"ror_zpg_x", {"zeropage_x"}},
    {"ror_abs", {"absolute"}},
    {"ror_abs_x", {"absolute_x"}},
  },

  ["rti"] = {
    {"rti", {}},
  },
  ["rts"] = {
    {"rts", {}},
  },

  ["sbc"] = {
    {"sbc_imm", {"immediate"}},
    {"sbc_zpg", {"zeropage"}},
    {"sbc_zpg_x", {"zeropage_x"}},
    {"sbc_abs", {"absolute"}},
    {"sbc_abs_x", {"absolute_x"}},
    {"sbc_abs_y", {"absolute_y"}},
    {"sbc_ind_x", {"indirect_x"}},
    {"sbc_ind_y", {"indirect_y"}},
  },
  ["sta"] = {
    {"sta_zpg", {"zeropage"}},
    {"sta_zpg_x", {"zeropage_x"}},
    {"sta_abs", {"absolute"}},
    {"sta_abs_x", {"absolute_x"}},
    {"sta_abs_y", {"absolute_y"}},
    {"sta_ind_x", {"indirect_x"}},
    {"sta_ind_y", {"indirect_y"}},
  },
  ["txs"] = {
    {"txs", {}},
  },
  ["tsx"] = {
    {"tsx", {}},
  },
  ["pha"] = {
    {"pha", {}},
  },
  ["pla"] = {
    {"pla", {}},
  },
  ["php"] = {
    {"php", {}},
  },
  ["plp"] = {
    {"plp", {}},
  },
  ["stx"] = {
    {"sty_zpg", {"zeropage"}},
    {"sty_zpg_y", {"zeropage_y"}},
    {"sty_abs", {"absolute"}},
  },
  ["sty"] = {
    {"sty_zpg_x", {"zeropage_x"}},
    {"sty_zpg", {"zeropage"}},
    {"sty_abs", {"absolute"}},
  },
}

local result = {}

for ins_name, patterns in pairs(nmos_assembly) do
  local ins_table = {}
  for _, row in pairs(patterns) do
    if row[2][1] then
      ins_table[row[2][1]] = row[1]
    else
      ins_table["implied"] = row[1]
    end
  end
  result[ins_name] = ins_table
end

yatm_oku.OKU.isa.MOS6502.NMOS_Assembly = result
