--
-- Frames
--
yatm.codex.register_entry("yatm_frames:frame", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame",
      },
      heading = "Motor Frame",
      lines = {
        "Motor frames attach to other frames.",
        "Frames will move any connected frames.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_frames:frame_sticky", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame_sticky",
      },
      heading = "Motor Frame (Sticky)",
      lines = {
        "Motor frames attach to other frames.",
        "These frames will move any node on its sticky side.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_frames:frame_wire", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame_sticky",
      },
      heading = "Motor Frame (Wire)",
      lines = {
        "Motor frames attach to other frames.",
        "These frames will not move frames on its wire wide.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_frames:frame_wire_and_sticky", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame",
      },
      heading = "Motor Frame (Wire & Sticky)",
      lines = {
        "Motor frames attach to other frames.",
        "These frames are a combination of the sticky and wire frames.",
        "There sticky sides will drag along any nodes.",
        "While the wire side will not drag any attached frames.",
      },
    },
  },
})

--
-- Frame Motors
--
yatm.codex.register_entry("yatm_frames:frame_motor", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame_motor",
      },
      heading = "Frame Motor",
      lines = {
        "Frame Motors move attached frames.",
        "The arrows on top, determine where the frames will move.",
        "This is a base motor, and cannot be triggered (currently).",
        "You should try the data or mesecon variants instead.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_frames:frame_motor_mesecon", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame_motor_mesecon_on",
      },
      heading = "Frame Motor (Mesecon)",
      lines = {
        "Frame Motors move attached frames.",
        "The arrows on top, determine where the frames will move.",
        "This particular frame motor is operated with mesecon."
      },
    },
  },
})

yatm.codex.register_entry("yatm_frames:frame_motor_data", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_frames:frame_motor_data_on",
      },
      heading = "Frame Motor (Data)",
      lines = {
        "Frame Motors move attached frames.",
        "The arrows on top, determine where the frames will move.",
        "This particular frame motor is operated with the data interface."
      },
    },
  },
})


