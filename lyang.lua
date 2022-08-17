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

local function main(...)
    -- create context
    local ctx = context()

    -- load addons
    for source in addon.scan() do
        local a = require(source)
        a:init()
        a:add_option(argparse)
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
    -- formatter not chosen
    if not ctx.args.format then
        error('formatter not chosen')
    end
    -- formatter not found
    local formatter = addon.get_formatter(ctx.args.format)
    if not formatter then
        error('formatter "' .. ctx.args.format .. '" not found')
    end
    -- number of input files
    local files = ctx.args
    if 0 == #files then
        error('missing input files')
    elseif 1 < #files and not formatter.multiple then
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
    -- output
    if ctx.args.output then
        -- "-o/--output" is specified
        local tmpname = os.tmpname()
        local fd = io.open(tmpname, 'w+')
        local ok, errmsg =
            xpcall(
            function()
                formatter:convert(ctx, fd)
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
        formatter:convert(ctx, io.stdout)
    end
end

local ok, errmsg = pcall(main, ...)
if not ok then
    print(errmsg)
    os.exit(1)
end
