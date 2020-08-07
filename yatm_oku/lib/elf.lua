--
-- Utility module for parsing ELF32 binares and possibly ELF64 in the future...
--
local ByteBuf = assert(foundation.com.ByteBuf)

assert(foundation.com.binary_types)
local Enum = assert(foundation.com.binary_types.Enum)
local BitFlags = assert(foundation.com.binary_types.BitFlags)
local BinSchema = assert(foundation.com.BinSchema)

local list_reduce = assert(foundation.com.list_reduce)

local ELF = {}
local ELF32 = {}
--local ELF64 = {}

-- Reference: http://sco.com/developers/gabi/latest/ch4.eheader.html

ELF.Class = Enum:new("u8", {
  ELFCLASSNONE = 0,
  ELFCLASS32 = 1,
  ELFCLASS64 = 2
})

ELF.Data = Enum:new("u8", {
  ELFDATA2NONE = 0,
  ELFDATA2LSB = 1,
  ELFDATA2MSB = 2
})

ELF.OSABI = Enum:new("u8", {
  ELFOSABI_NONE = 0,
  ELFOSABI_LINUX = 3
})

ELF32.Ident = BinSchema:new("ELF32.Ident", {
  {"magic", foundation.com.binary_types.Bytes:new(4)},
  {"class", ELF.Class},
  {"data", ELF.Data},
  {"version", "u8"},
  {"osabi", ELF.OSABI},
  {"abiversion", "u8"},
  6, -- padding
  {"n_ident", "u8"},
})

local size = ELF32.Ident:size()
assert(size == 16, "expected ident field to be 16 bytes got " .. size)

ELF32.Type = Enum:new("u16", {
  ET_NONE = 0,
  ET_REL = 1,
  ET_EXEC = 2,
  ET_DYN = 3,
  ET_CORE = 4,
  ET_LOOS = 0xFe00,
  ET_HIOS = 0xFeFF,
  ET_LOPROC = 0xFF00,
  ET_HIPROC = 0xFFFF,
})

ELF32.Machine = Enum:new("u16", {
  EM_NONE = 0,
  EM_M32 = 1,
  EM_SPARC = 2,
  EM_E86 = 3,
  EM_68K = 4,
  EM_88K = 5,
  EM_IAMCU = 6,
  EM_860 = 7,
  EM_MIPS = 8,

  EM_RISCV = 243,
})

ELF32.Ehdr = BinSchema:new("ELF32.Ehdr", {
  {"ident", ELF32.Ident}, -- unsigned char
  {"type", ELF32.Type},                            -- Elf32_Half
  {"machine", ELF32.Machine},                      -- Elf32_Half
  {"version", "u32"},                              -- Elf32_Word
  {"entry", "u32"}, -- Elf32_Addr : virtual address
  {"phoff", "u32"}, -- Elf32_Off : Program Header offset (bytes)
  {"shoff", "u32"}, -- Elf32_Off : Section Header offset (bytes)
  {"flags", "u32"}, -- Elf32_Word : Processor Specifc Flags
  {"ehsize", "u16"}, -- Elf32_Half : ELF Header size (bytes)
  {"phentsize", "u16"}, -- Elf32_Half : Program Header table Element size (bytes)
  {"phnum", "u16"}, -- Elf32_Half : Program Header element count
  {"shentsize", "u16"}, -- Elf32_Half : Section header table Element size (bytes)
  {"shnum", "u16"}, -- Elf32_Half : Section header element count
  {"shstrndx", "u16"}, -- Elf32_Half : Section Header String Table Index
})

ELF32.SectionType = Enum:new("u32", {
  SHT_NULL = 0,
  SHT_PROGBITS = 1,
  SHT_SYMTAB = 2,
  SHT_STRTAB = 3,
  SHT_RELA = 4,
  SHT_HASH = 5,
  SHT_DYNAMIC =  6,
  SHT_NOTE = 7,
  SHT_NOBITS = 8,
  SHT_REL =  9,
  SHT_SHLIB =  10,
  SHT_DYNSYM = 11,
  SHT_INIT_ARRAY = 14,
  SHT_FINI_ARRAY = 15,
  SHT_PREINIT_ARRAY =  16,
  SHT_GROUP =  17,
  SHT_SYMTAB_SHNDX = 18,
  SHT_LOOS = 0x60000000,
  SHT_HIOS = 0x6fffffff,
  SHT_LOPROC = 0x70000000,
  SHT_HIPROC = 0x7fffffff,
  SHT_LOUSER = 0x80000000,
  SHT_HIUSER = 0xffffffff,
})

ELF32.Flags = BitFlags:new(4, {
  SHF_WRITE = 0x1,
  SHF_ALLOC = 0x2,
  SHF_EXECINSTR = 0x4,
  SHF_MERGE = 0x10,
  SHF_STRINGS = 0x20,
  SHF_INFO_LINK = 0x40,
  SHF_LINK_ORDER = 0x80,
  SHF_OS_NONCONFORMING = 0x100,
  SHF_GROUP = 0x200,
  SHF_TLS = 0x400,
  SHF_COMPRESSED = 0x800,
  SHF_MASKOS = 0x0ff00000,
  SHF_MASKPROC = 0xf0000000,
})

--[[
typedef struct {
  Elf32_Word  sh_name;
  Elf32_Word  sh_type;
  Elf32_Word  sh_flags;
  Elf32_Addr  sh_addr;
  Elf32_Off sh_offset;
  Elf32_Word  sh_size;
  Elf32_Word  sh_link;
  Elf32_Word  sh_info;
  Elf32_Word  sh_addralign;
  Elf32_Word  sh_entsize;
} Elf32_Shdr;
]]
ELF32.Shdr = BinSchema:new("ELF32.Shdr", {
  {"name_index", "u32"},
  {"type", ELF32.SectionType},
  {"flags", ELF32.Flags},
  {"addr", "u32"},
  {"offset", "u32"},
  {"size", "u32"},
  {"link", "u32"},
  {"info", "u32"},
  {"addralign", "u32"},
  {"entsize", "u32"},
})

--[[
typedef struct {
  Elf32_Word  st_name;
  Elf32_Addr  st_value;
  Elf32_Word  st_size;
  unsigned char st_info;
  unsigned char st_other;
  Elf32_Half  st_shndx;
} Elf32_Sym;
]]
ELF32.Sym = BinSchema:new("ELF32.Sym", {
  {"name_index", "u32"},
  {"addr", "u32"},
  {"size", "u32"},
  {"info", "u8"},
  {"other", "u8"},
  {"shndx", "u16"},
})

ELF32.SegmentType = Enum:new("u32", {
  PT_NULL = 0,
  PT_LOAD = 1,
  PT_DYNAMIC = 2,
  PT_INTERP = 3,
  PT_NOTE = 4,
  PT_SHLIB = 5,
  PT_PHDR = 6,
  PT_TLS = 7,
  PT_LOOS = 0x60000000,
  PT_HIOS = 0x6fffffff,
  PT_LOPROC = 0x70000000,
  PT_HIPROC = 0x7fffffff,
})

--[[
typedef struct {
  Elf32_Word  p_type;
  Elf32_Off p_offset;
  Elf32_Addr  p_vaddr;
  Elf32_Addr  p_paddr;
  Elf32_Word  p_filesz;
  Elf32_Word  p_memsz;
  Elf32_Word  p_flags;
  Elf32_Word  p_align;
} Elf32_Phdr;
]]
ELF32.Phdr = BinSchema:new("ELF32.Phdr", {
  {"type", ELF32.SegmentType},
  {"offset", "u32"},
  {"vaddr", "u32"},
  {"paddr", "u32"},
  {"filesz", "u32"},
  {"memsz", "u32"},
  {"flags", "u32"},
  {"align", "u32"},
})

yatm_oku.elf = {
  ELF = ELF,
  ELF32 = ELF32
}

local Prog = foundation.com.Class:extends("ELF.Program")

local ic = Prog.instance_class

function ic:initialize(options)
  ic._super.initialize(self)
  self.m_ehdr = options.ehdr
  self.m_sections = options.sections
  self.m_prog_segments = options.prog_segments
end

function ic:inspect()
  return dump({
    ehdr = self.m_ehdr,
    sections = self.m_sections,
    prog_segments = self.m_prog_segments,
  })
end

function ic:reduce_sections(acc, fn)
  return list_reduce(self.m_sections, acc, fn)
end

function ic:get_section(name)
  for _,section in pairs(self.m_sections) do
    if section.name == name then
      return section
    end
  end
  return nil
end

function ic:reduce_segments(acc, fn)
  return list_reduce(self.m_prog_segments, acc, fn)
end

function ic:get_prog_segment(name)
  for _,segment in pairs(self.m_prog_segments) do
    if segment.name == name then
      return segment
    end
  end
  return nil
end

function ic:get_entry_vaddr()
  return self.m_ehdr.entry
end

function yatm_oku.elf:read(stream)
  local ehdr = yatm_oku.elf.ELF32.Ehdr:read(stream)

  local shdrs = {}
  local phdrs = {}
  local sections = {}
  local prog_segments = {}
  local old_cursor = stream:tell()

  stream:seek(ehdr.phoff + 1)
  for _ = 1,ehdr.phnum do
    local ph = ELF32.Phdr:read(stream)
    table.insert(phdrs, ph)
  end

  stream:seek(ehdr.shoff + 1)
  for _ = 1,ehdr.shnum do
    local sh = ELF32.Shdr:read(stream)
    table.insert(shdrs, sh)
  end

  for _,shdr in ipairs(shdrs) do
    local section = {
      header = shdr
    }
    if shdr.offset > 0 and shdr.size > 0 then
      stream:seek(shdr.offset + 1)
      if shdr.type == "SHT_SYMTAB" then
        section.symbols = {}
        local count = shdr.size / shdr.entsize
        for _ = 1,count do
          local data = ELF32.Sym:read(stream)
          table.insert(section.symbols, data)
        end
      elseif shdr.type == "SHT_STRTAB" then
        local blob = ByteBuf.read(stream, shdr.size)
        section.entries = {}
        local offset = 0
        local iter = 0
        while #blob > 0 do
          local idx, edx = string.find(blob, '\0')
          if idx then
            local item = string.sub(blob, 1, edx - 1)
            section.entries[offset] = item
            blob = string.sub(blob, edx + 1, #blob)
            offset = offset + edx
            iter = iter + 1
          else
            break
          end
        end
      else
        local blob = ByteBuf.read(stream, shdr.size)
        section.blob = blob
      end
    end
    table.insert(sections, section)
  end

  for _,phdr in ipairs(phdrs) do
    local segment = {
      header = phdr
    }
    if phdr.filesz > 0 then
      stream:seek(phdr.offset + 1)

      local blob = ByteBuf.read(stream, phdr.filesz)
      segment.blob = blob
    end
    table.insert(prog_segments, segment)
  end

  if ehdr.shstrndx > 0 then
    local shstrtab = sections[ehdr.shstrndx + 1]

    for _, section in ipairs(sections) do
      section.name = shstrtab.entries[section.header.name_index]
    end
    print('shstrtab', dump(shstrtab))
  end

  local strtab
  local symtab
  for _, section in ipairs(sections) do
    if section.name == ".strtab" then
      strtab = section
    elseif section.name == ".symtab" then
      symtab = section
    end
  end

  if strtab and symtab then
    for _,symbol in ipairs(symtab.symbols) do
      local name = strtab.entries[symbol.name_index]
      symbol.name = name
    end
  end

  return Prog:new({
    ehdr = ehdr,
    sections = sections,
    prog_segments = prog_segments,
    --blob = blob,
  })
end
