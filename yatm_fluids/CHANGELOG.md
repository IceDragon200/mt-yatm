# 2.5.0

* Added ErrorCodes module
  * `ERR_OK`
  * `ERR_OUT_OF_RANGE`
  * `ERR_LIST_NOT_FOUND`
  * `ERR_FLUID_IS_PRESENT`
  * `ERR_FLUID_NOT_FOUND`

* Refactored FluidInventory a bit
  * Some functions now return additional error codes
  * Some functions no longer return self, but instead the leftover fluid stack

# 2.4.0

* Can now register its own buckets instead of relying on `buckets`

# 2.3.0

* Fixup function specs

# 2.0.0

* `yatm.fluids.FluidRegistry` has been moved to `yatm.fluids.fluid_registry`
