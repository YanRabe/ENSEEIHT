# RatToTam Compiler -- ENSEEIHT 2SN Language Translation and Compilation Course

## Overview
This project is an OCaml-based compiler that translates a structured source language called **RAT** (specialized in rational numbers representation) into a low-level assembly-like target language called **TAM**. It was developed as part of the *Traduction des Langages* (Language Translation) module.

## Architecture
The compiler processes the source code through 5 sequential passes :
1. **Lexical & Syntactical Analysis**: Validates the grammar and generates the initial Abstract Syntax Tree (AST).
2. **Identifier Management (TDS)**: Analyzes the AST to verify identifier scoping and constructs the Symbol Table (Table des Symboles).
3. **Typing**: Verifies type consistency across the program, applies implicit conversions, and annotates the AST with type information.
4. **Memory Placement**: Calculates and attributes memory addresses (using SB and LB stacks) to variables based on their type sizes.
5. **Code Generation**: Translates the final evaluated AST into low-level TAM assembly instructions.

## Features
In addition to the base RAT language, this compiler has been extended to support:
- **Pointers**: Support for address referencing (`&`), dereferencing (`*`), dynamic memory allocation (`new`), and `null` pointers.
- **Procedures**: Support for void-returning functions intended strictly for side effects (printing, modifying variables, etc.).

*(Note: Passing variables by reference and enumerated types are not currently supported).*

## How to Use

The project relies on `dune` as its build system. Ensure you have OCaml and Dune installed on your machine.

### Building the Project
To compile the entire project, run the following command in the root directory:
```bash
dune build
```

### Running the tests
The repository includes a comprehensive suite of tests verifying each pass, including specific tests for pointers and procedures. You can execute the test suite with:
```bash
dune runtest
```

### Use the Compiler
To compile a specific RAT file (e.g., `testUtilisation8.rat`) into TAM code, execute the compiler through dune. (*Depending on the exact executable name defined in your dune file, the command will look something like this*):
```bash
dune exec ./compilateur.exe -- path/to/file.rat
```
