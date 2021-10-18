--
-- YATM's stock colours
--
yatm.colors = {
  { name = "white",      description = "White" },
  { name = "grey",       description = "Grey" },
  { name = "dark_grey",  description = "Dark Grey" },
  { name = "black",      description = "Black" },
  { name = "violet",     description = "Violet" },
  { name = "blue",       description = "Blue" },
  { name = "light_blue", description = "Light Blue" },
  { name = "cyan",       description = "Cyan" },
  { name = "dark_green", description = "Dark Green" },
  { name = "green",      description = "Green" },
  { name = "yellow",     description = "Yellow" },
  { name = "brown",      description = "Brown" },
  { name = "orange",     description = "Orange" },
  { name = "red",        description = "Red" },
  { name = "magenta",    description = "Magenta" },
  { name = "pink",       description = "Pink" },
}

yatm.colors_with_default =
  foundation.com.list_concat({{name = "default", description = "Default"}}, yatm.colors)
