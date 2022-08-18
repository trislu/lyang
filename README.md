<div align="center">
    <h1>lyang</h1>
    <p align="center">
        A <ins><b>L</b></ins>ua based <ins><b>YANG</b></ins> validator and converter
    </p>
    <p>
        <a href="https://github.com/trislu/lyang/actions/workflows/makefile.yml">
            <img src="https://github.com/trislu/lyang/actions/workflows/makefile.yml/badge.svg" alt="Unit Test status">
        </a>
    </p>
</div>

## Overview

**lyang** is a compiler-oriented [YANG](https://www.rfc-editor.org/info/rfc7950) validator and converter written in [Lua](http://www.lua.org/). It was designed (but not restricted) to run on embedded devices.

By providing the basic YANG parsing ability and extensibility via addons. **lyang** can serve as various kinds of roles: schema library, hotfix framework, online upgrade, etc.

## Dependencies

+ `Lua` (5.1 | higher) or `LuaJIT` (2.1 | higher) interpreter
+ `lunit` unit testing framework (already added as git submodule )
+ `make` for running unit tests

## Features

+ standard `*.yang` to `*.yin` convertion
+ `*.yang` to `*.res` compilation
+ customizable YANG lexer (tokenizer) / parser

## Binding C/C++

In terms of program performance, **lyang** follows the same philosophy with Lua :
```
If something is slow or heavy, implements it in C.
```
I.e. if any functionalities of lyang were considered to be "*performance-sensitive*", you could always customize them with [Lua C API](http://www.lua.org/manual/5.1/manual.html#3) or [LuaJIT FFI Library](http://luajit.org/ext_ffi.html), to reduce the execution time and memory consumption.

## Usage

```bash
# source environment variables in current directory
source env.sh
# display usage
lua lyang.lua -h
# or
./lyang.lua -h
```

## Run unittest

```bash
# enter "test" directory
cd test
# display usage
make usage
# run all the test cases
make test
```
