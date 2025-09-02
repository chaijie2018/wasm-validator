# wasm-validator
WebAssembly (Wasm) is a portable low-level bytecode format widely used across various platforms, including browsers and servers. To ensure the correctness of Wasm programs before execution, they must first undergo static validation through a validator.

Wasm validator does a recursive walk of the AST, passing down the expected type for expressions, and checking each expression against that. An expected empty type can be matched by any result, corresponding to implicit dropping of unused values (e.g. in a block).

## Features
 
- Supports the validation rules of Wasm 1.0 MVP, including but not limited to module structure verification, type checking, and control flow validation
- Capable of performing static verification on .wasm files and providing detailed information and locations of verification errors 

## Reference

- [WebAssembly Specification](https://webassembly.github.io/spec/core/valid/index.html)
- [WebAssembly Interpreter](https://github.com/WebAssembly/spec/tree/main/interpreter)
- [WABT: The WebAssembly Binary Toolkit](https://github.com/WebAssembly/wabt)
