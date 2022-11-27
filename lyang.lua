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
local linker = require('linker')
local log = require('log')
local system = require('system')
local parser = require('parser')

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
        -- add converter
        a:add_converter(ctx)
        addon.load(source, a)
    end

    -- parse arguments
    local ap = argparse()

    -- add default options
    ap.add_argument {
        '-h',
        '--help',
        action = 'store_true',
        dest = 'help',
        help = 'Display this information'
    }
    ap.add_argument {
        '-o',
        '--output',
        action = 'store',
        nargs = 1,
        dest = 'output',
        help = 'Save output to file'
    }
    ap.add_argument {
        '-e',
        '--extension',
        action = 'store',
        nargs = '*',
        dest = 'extend',
        help = 'Extension modules'
    }
    ap.add_argument {
        '-c',
        '--convert',
        action = 'store',
        nargs = 1,
        dest = 'cov',
        help = 'Choose a converter. \n\t\tSupported converters are: ' ..
            table.concat(
                (function()
                    local cov_list = {}
                    for name in ctx.converters.list() do
                        cov_list[#cov_list + 1] = name
                    end
                    return cov_list
                end)(),
                ', '
            )
    }
    ap.add_argument {
        '-l',
        '--link',
        action = 'store_true',
        dest = 'link',
        help = 'Enable the linker mode'
    }

    -- do parse arguments
    ctx.args = ap.parse_args {...}

    -- print help
    if ctx.args.help then
        ap.print_usage()
        os.exit(0)
    end

    --[[ limits ]]
    -- converter not chosen
    if not ctx.args.cov then
        log.error('converter not chosen')
    end
    -- converter not found
    local cov = ctx.converters.get(ctx.args.cov[1])
    if not cov then
        log.error('unknown converter "' .. ctx.args.cov[1] .. '"')
    end
    -- number of input files
    local files = ctx.args
    if 0 == #files then
        log.error('missing input files')
    elseif 1 < #files and not cov.multiple then
        log.error('too many files to convert')
    end

    --[[ core ]]
    -- setup context
    for a in addon.list() do
        a:setup_context(ctx)
    end

    -- extend modules
    if ctx.args.extend then
        for i = 0, #ctx.args.extend do
            local p = parser(ctx)
            local err = p.parse(ctx.args.extend[i])
            if err then
                log.error(err)
            end
        end
    end
    ctx.modules.do_extend()

    -- input modules
    for i = 1, #files do
        local p = parser(ctx)
        local err = p.parse(files[i])
        if err then
            log.error(err)
        end
    end
    -- if the "linker" mode is enbaled
    if ctx.args.link then
        if not cov.multiple then
            log.error('only the multi-module converters can enable the linker mode')
        end
        local l = linker()
        l.link(ctx)
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
            log.error(errmsg)
        end
        fd:close()
        -- try os.rename() firstly
        local success, _ = os.rename(tmpname, ctx.args.output[1])
        if not success then
            -- use os.execute('mv source destination') secondly
            system.move(tmpname, ctx.args.output[1])
        end
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
