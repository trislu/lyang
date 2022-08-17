#!/usr/bin/env lua
loca = load or loadstring
unpack = unpack or table.unpack --luacheck: ignore
--[[
MIT License

Copyright (c) 2022 Lu Kai

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
local addon = require('addon')
local argparse = require('argparse')
local context = require('context')
local link = require('link')

local function main(...)
    -- create context
    local ctx = context()

    -- load addons
    for source in addon.scan() do
        local a = require(source)
        -- useless init() ?
        a:init()
        -- add option to argparse
        a:add_option(argparse)
        -- add convertor
        a:add_convertor(ctx)
        addon.load(source, a)
    end

    -- parse arguments
    local ap = argparse()
    ctx.args = ap.parse_args {...}

    -- print help
    if ctx.args.help then
        ap.print_usage()
        os.exit(0)
    end

    --[[ limits ]]
    -- convertor not chosen
    if not ctx.args.cov then
        error('convertor not chosen')
    end
    -- convertor not found
    local cov = ctx.convertors.get(ctx.args.cov)
    if not cov then
        error('convertor "' .. ctx.args.cov .. '" not found')
    end
    -- number of input files
    local files = ctx.args
    if 0 == #files then
        error('missing input files')
    elseif 1 < #files and not cov.multiple then
        error('too many files to convert')
    end

    --[[ core ]]
    -- setup context
    for a in addon.list() do
        a:setup_context(ctx)
    end
    -- input modules
    for i = 1, #files do
        ctx:input_module(files[i])
    end
    -- if "linker" mode is enbaled
    if ctx.args.link then
        if not cov.multiple then
            error('only the multi-module convertors can enable the linker mode')
        end
        local linker = link()
        linker.link(ctx)
    end
    -- output
    if ctx.args.output then
        -- "-o/--output" is specified
        local tmpname = os.tmpname()
        local fd = io.open(tmpname, 'w+')
        local ok, errmsg =
            xpcall(
            function()
                cov:convert(ctx, fd)
            end,
            function()
                fd:close()
                os.remove(tmpname)
            end
        )
        if not ok then
            error(errmsg)
        end
        fd:close()
        os.rename(tmpname, ctx.args.output)
    else
        -- write to stdout by default
        cov:convert(ctx, io.stdout)
    end
end

local ok, errmsg = pcall(main, ...)
if not ok then
    print(errmsg)
    os.exit(1)
end
