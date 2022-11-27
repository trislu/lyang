FROM alpine:3.15

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk update \
    && apk add --no-cache build-base gdb valgrind cmake lua5.1 luajit-dev luarocks luacheck

WORKDIR /workspace
