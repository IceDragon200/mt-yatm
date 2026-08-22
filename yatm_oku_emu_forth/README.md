# YATM OKU Forth

YATM OKU Forth is a high-level, token-threaded Forth-like virtual machine for
OKU computers. It provides 8-, 16-, and 32-bit cell variants while leaving the
entire guest memory available for data.

The implementation is intentionally a hybrid rather than an emulation of a
historical Forth processor. User definitions and control-flow tokens live in a
bounded, serializable host-side dictionary. The data stack and `@`/`!` memory
operations use guest memory.

See [docs/architecture.md](docs/architecture.md) for the machine model,
resource limits, vocabulary, and intentional differences from traditional
Forth systems.
