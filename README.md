<div align="center">
    <h1>lyang</h1>
    <p align="center">
        A <ins><b>L</b></ins>ua based <ins><b>YANG</b></ins> parser
    </p>
    <p>
        <a href="https://github.com/trislu/lyang/actions/workflows/makefile.yml">
            <img src="https://github.com/trislu/lyang/actions/workflows/makefile.yml/badge.svg" alt="Unit Test status">
        </a>
    </p>
</div>

## Overview

**lyang** is a [YANG](https://www.rfc-editor.org/info/rfc7950) parser written in [Lua](http://www.lua.org/). It was designed (but not restricted) to run on embedded devices.

With basic YANG parsing ability and addon extensibility. **lyang** can serve as various kinds of roles: schema generator, hotfix framework, language protocol server, etc.

## Dependencies

+ `Lua` (5.1 | higher) or `LuaJIT` (2.1 | higher) interpreter
+ `lunit` unit testing framework (already added as git submodule )
+ `make` for running unit tests

## Docker dev
```bash
docker build -t lyang:dev -f Dockerfile .
docker run -v ${pwd}:/workspace -it --rm lyang:dev /bin/sh
```

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
