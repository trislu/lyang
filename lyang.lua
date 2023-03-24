#!/usr/bin/env lua
local load = load or loadstring
local unpack = unpack or table.unpack --luacheck: ignore
local error = error
local os = os
local pcall = pcall
local print = print
local require = require
local table = table
local io = io
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
package.path = package.path .. ';src/?.lua;addons/?.lua;;'

local addon = require('addon')
local argparse = require('argparse')
local context = require('context')
local linker = require('linker')
local log = require('log')
local system = require('system')
local parser = require('parser')

local _ENV = {}
if setfenv then
    setfenv(1, _ENV)
end

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
    ap.add_argument {
        '-p',
        '--path',
        action = 'store',
        dest = 'path',
        help = 'Loading path of yang files.'
    }

    -- do parse arguments
    local arguments = ap.parse_args {...}

    -- print help
    if not arguments or arguments.help then
        ap.print_usage()
        os.exit(0)
    end

    --[[ limits ]]
    -- converter not chosen
    if not arguments.cov then
        error('converter not chosen')
    end
    -- converter not found
    local cov = ctx.converters.get(arguments.cov)
    if not cov then
        error('unknown converter "' .. arguments.cov .. '"')
    end
    -- number of input files
    local positional_argument_count = #arguments
    if 0 == positional_argument_count then
        --error('missing input files')
    elseif 1 < positional_argument_count and not cov.multiple then
        --error('too many files to convert')
    end

    -- input files
    local files = {}
    for i = 0, positional_argument_count do
        files[#files + 1] = arguments[i]
    end

    --[[ core ]]
    -- setup context
    for a in addon.list() do
        a:setup_context(ctx)
    end

    -- extend modules
    if arguments.extend then
        for i = 0, #arguments.extend do
            local p = parser(ctx)
            local fd = io.open(arguments.extend[i], 'r')
            local text = fd:read('*a')
            local err = p.parse(text)
            if err then
                error(err)
            end
        end
    end
    ctx.modules.do_extend()

    -- loading path or positional argument?
    if arguments.path then
        for file in system.dir(arguments.path) do
            local ret = system.path.splitext(file)
            if '.yang' == ret[2] then
                files[#files + 1] = file
            end
        end
    end

    -- input modules
    for i = 1, #files do
        local fd = io.open(files[i], 'r')
        local text = fd:read('*a')
        local p = parser(ctx)
        local err = p.parse(text)
        if err then
            error(err)
        end
    end
    -- if the "linker" mode is enbaled
    if ctx.args.link then
        if not cov.multiple then
            error('only the multi-module converters can enable the linker mode')
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
            error(errmsg)
        end
        fd:close()
        -- try os.rename() firstly
        local success, _ = os.rename(tmpname, ctx.args.output)
        if not success then
            -- use os.execute('mv source destination') secondly
            system.move(tmpname, ctx.args.output)
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
