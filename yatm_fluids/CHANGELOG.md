# 2.7.0

* Added additional FluidExchange functions for dealing with:
  * tank to container
  * meta to container
  * container to container
  * container to tank
  * container to meta

# 2.6.0

* Added FluidStack metatable, most functions available on the module are now available on the instance class
* Changed `FluidStack.merge/1+` behaviour, it now uses the first argument as the result fluid stack, to get the old behaviour please use `merge_new/1+` which always returns a new resultant FluidStack

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
