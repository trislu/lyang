<div align="center">
    <h1>lyang</h1>
    <p align="center">
        A <b>L</b>ua based <b>YANG</b> validator and converter
    </p>
    <p>
        <a href="https://github.com/trislu/lyang/actions/workflows/makefile.yml">
            <img src="https://github.com/trislu/lyang/actions/workflows/makefile.yml/badge.svg" alt="Unit Test status">
        </a>
    </p>
</div>

## Overview

**lyang** is compiler-oriented [YANG](https://www.rfc-editor.org/info/rfc7950) validator and converter written in [Lua](http://www.lua.org/). It was designed (but not restricted) to run on embedded devices.

By providing the basic YANG parsing ability and extensibility via addons. lyang can serve as various kinds of roles: schema library, hotfix, online upgrade, etc.

## Dependencies
+ `Lua` (5.1 or higher) or `LuaJIT` (2.0 or higher)

## Usage
```bash
source env.sh
lua lyang.lua -h
# or
./lyang.lua -h
```

## Run unittest

```bash
cd test
make
```
