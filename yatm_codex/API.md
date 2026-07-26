# CODEX API

```lua
--- An instance of yatm.codex.CodexRegistry, see the class for additional details
yatm.codex.registry

--- If you need a custom domain to register your own entries for some reason
yatm.codex.registry:register_domain("custom_domain", {
  description = "Custom Domain"
})

--- items and entities are already predefined for domains, which are enough for most cases.

---
yatm.codex.registry:register_entry("items", "my_mod:my_codex_entry", {

})
```
