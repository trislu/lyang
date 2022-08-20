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
local utils = require('utils')

local yin = addon.create()
-- standard yin namespace
local namespace = 'urn:ietf:params:xml:ns:yang:yin:1'

function yin:init()
    -- yin is a single module converter
    self.name = 'yin'
    self.multiple = false
end

function yin:add_converter(ctx_)
    ctx_.converters.add(self.name, self)
end

local function convert_stmt(ctx, mod, stmt, fd)
    -- the statement is validated already
    local arg_ident, child_elem = nil, false
    local _, prefix, ident = utils.decouple_nodeid(stmt.keyword)
    if prefix then
        -- prefix comes from which import
        local import_stmt =
            mod.find_child(
            'import',
            function(s)
                local px = s.find_child('prefix')
                return px.argument == prefix
            end
        )
        -- find import module from context
        local extmod = ctx.modules.get(import_stmt.argument)
        -- find extension definition
        local extension_stmt =
            extmod.find_child(
            'extension',
            function(s)
                return s.argument == ident
            end
        )
        -- find arugment substatement
        local argument_stmt = extension_stmt.find_child('argument')
        if argument_stmt then
            local yinelem_stmt = argument_stmt.find_child('yin-element')
            if yinelem_stmt and yinelem_stmt.argument == 'true' then
                arg_ident = prefix .. ':' .. argument_stmt.argument
                child_elem = true
            else
                arg_ident = argument_stmt.argument
            end
        end
    else
        -- standard keywords
        arg_ident, child_elem = stmt.syntax.yinarg()
    end
    -- write xml tag for this statement
    if arg_ident and child_elem then
        -- begin tag
        fd:write('<' .. stmt.keyword .. '>\n')
        -- argument of this statement is a child element
        fd:write('<' .. arg_ident .. '>')
        fd:write(utils.escape(stmt.argument))
        fd:write('</' .. arg_ident .. '>\n')
        -- recurse
        for i = 1, stmt.substmt_count() do
            convert_stmt(ctx, mod, stmt.substmt(i), fd)
        end
        -- end tag
        fd:write('</' .. stmt.keyword .. '>\n')
    else
        -- begin tag
        fd:write('<' .. stmt.keyword)
        -- argument of this statement is an attribute
        if arg_ident then
            fd:write(' ' .. arg_ident .. '=' .. utils.quotedattr(stmt.argument))
        end
        -- recurse
        if 0 == stmt.substmt_count() then
            fd:write('/>\n')
        else
            fd:write('>\n')
            for i = 1, stmt.substmt_count() do
                convert_stmt(ctx, mod, stmt.substmt(i), fd)
            end
            -- end tag
            fd:write('</' .. stmt.keyword .. '>\n')
        end
    end
end

function yin:convert(ctx, fd) -- luacheck: ignore self
    local mod = ctx.modules.at(1)
    -- write prolog
    fd:write('<?xml version="1.0" encoding="UTF-8"?>\n')
    -- write module/submodule begin tag
    fd:write(string.format('<%s name="%s"\n', mod.keyword, mod.argument))
    local ns_indent = mod.keyword:len() + 2
    -- write standard namespace
    fd:write(string.rep(' ', ns_indent) .. 'xmlns="' .. namespace .. '"\n')
    -- write module's namespace
    if 'module' == mod.keyword then
        local prefix_stmt = mod.find_child('prefix')
        local namespace_stmt = mod.find_child('namespace')
        fd:write(
            string.rep(' ', ns_indent) ..
                string.format('xmlns:%s=%s', prefix_stmt.argument, utils.quotedattr(namespace_stmt.argument))
        )
    end
    -- write dependent module's namespace
    local deps = ctx.dependent_modules[mod.argument]
    if deps then
        for i = 1, #deps do
            -- find the prefix & namespace statements of the dependent module
            local px = deps[i].find_child('prefix')
            local ns = deps[i].find_child('namespace')
            fd:write(
                '\n' ..
                    string.rep(' ', ns_indent) ..
                        string.format('xmlns:%s=%s', px.argument, utils.quotedattr(ns.argument))
            )
        end
    end
    -- close begin tag of module/submodule
    fd:write('>\n')
    -- recurse substmts
    for i = 1, mod.substmt_count() do
        convert_stmt(ctx, mod, mod.substmt(i), fd)
    end
    -- end tag of module/submodule
    fd:write(string.format('</%s>\n', mod.keyword))
end

return yin
