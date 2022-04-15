yatm.codex.register_entry("yatm_data_logic:data_pulser", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_data_logic:data_pulser",
      },
      heading = "DATA Pulser",
      lines = {
        "Emits a DATA signal ever interval, the interval can be configured as a fraction of a second.",
      }
    }
  }
})

yatm.codex.register_entry("yatm_data_logic:data_arith_identity", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_data_logic:data_arith_identity",
      },
      heading = "DATA Arithemtic Unit - Identity",
      lines = {
        "This Arithemtic Unit, takes multiple inputs and produces a single output.",
      }
    }
  }
})

yatm.codex.register_entry("yatm_data_logic:data_arith_add", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_data_logic:data_arith_add",
      },
      heading = "DATA Arithemtic Unit - Addition",
      lines = {
        "This Arithemtic Unit, takes multiple inputs and produces a single output.",
        "Inputs are added together to produce a single value, overflows are carried over up to 16 byes.",
      }
    }
  }
})

yatm.codex.register_entry("yatm_data_logic:data_arith_subtract", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_data_logic:data_arith_subtract",
      },
      heading = "DATA Arithemtic Unit - Subtraction",
      lines = {
        "This Arithemtic Unit, takes multiple inputs and produces a single output.",
        "Inputs are subtracted from each other to produce a single value.",
        "The order can be specified in the configuration using a DATA Programmer.",
      }
    }
  }
})

yatm.codex.register_entry("yatm_data_logic:data_arith_multiply", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_data_logic:data_arith_multiply",
      },
      heading = "DATA Arithemtic Unit - Multiplication",
      lines = {
        "This Arithemtic Unit, takes multiple inputs and produces a single output.",
        "Inputs are multiplied together to produce a single value.",
      }
    }
  }
})
