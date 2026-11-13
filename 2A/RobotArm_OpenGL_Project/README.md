# TP Robot &mdash; ENSEEIHT 2SN Computer Graphics course (OpenGL)

A small computer graphics project using OpenGL and C++ to render a primitve robot arm. This project uses OpenGL and depends on FreeGLUT (included in the project).

## Prerequisites
- A C++ compiler (GCC/Clang)
- [CMake](https://cmake.org/)
- OpenGL & FreeGLUT

## How to Build and Run

To compile the project, you need to create a dedicated build directory, configure the project with CMake, and then compile it:

1. Create and enter the build folder:
```bash
   mkdir build
   cd build
```

2. Generate the build files using CMake:
```bash
   cmake ..
```

3. Compile the code and execute the program:
```bash
   make robot
   ./robot
```
