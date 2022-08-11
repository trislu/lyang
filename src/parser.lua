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
local stack = require('stack')
local token = require('token')
local buffer = require('buffer')
local lex = require('lex')
local syntax = require('syntax')

return function()
    local filename = nil
    local current_token = nil
    local argument_string = {}
    local stmt_stack = stack()
    local rule_stack = stack()
    local extension_flag = false
    local lasterr = nil
    local format_error = function(msg)
        return filename .. ':' .. current_token.line .. ':' .. current_token.col .. ': ' .. msg
    end
    local run = function()
        -- parser state
        local state = {}
        -- [keyword]
        state.keyword = function()
            if token.UnquotedString ~= current_token.type then
                --[[ (https://www.rfc-editor.org/rfc/rfc7950.html#section-6.1.3)
                "Note that any keyword can legally appear as an unquoted string."]]
                lasterr = format_error('expected unquoted string token but was ' .. token.typename(current_token.type))
                return nil
            end
            if current_token.content:find(':') then
                --[[
                    A keyword is either one of the YANG keywords defined in this document, or a
                    prefix identifier, followed by a colon (":"), followed by a language
                    extension keyword.
                ]]
                extension_flag = true
            end
            local rule = syntax(current_token.content)
            if nil == rule then
            end
        end
    end
    local p = {
        parse = function(f)
            -- record filename
            filename = f
            -- string buffer
            local b = buffer()
            b.load(f)
            -- lexer
            local l = lex(b)
        end
    }
    return p
end
