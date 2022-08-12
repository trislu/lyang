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
local statement = require('statement')

return function()
    local filename = nil
    local current_token = nil
    local argument_string = {}
    local stmt_stack = stack()
    local rule_stack = stack()
    local extension_root = nil
    local lasterr = nil
    local format_error = function(msg)
        return filename .. ':' .. current_token.line .. ':' .. current_token.col .. ': ' .. msg
    end
    local run = function(l)
        -- input lexer
        local lexer = l
        -- parser state
        local state = {}
        -- [[end statement]]
        state.statement_end = function()
            if extension_root then
                if extension_root == stmt_stack.size() then
                    -- leave the extension context totally
                    extension_root = nil
                end
                --[[TOOD:verify extension syntax?]]
            else
                -- end of what
                local rule = rule_stack.top()
                if not rule.fin() then
                    lasterr = format_error(rule.lasterr())
                    return nil
                end
                -- pop rule stacks
                rule_stack.pop()
            end
            stmt_stack.pop()
        end
        state.substatement_begin = function()
        end
        -- [[extension]]
        state.extension = function()
            -- create statement
            local stmt = statement()
            stmt.keyword = current_token.content
            stmt.position.line = current_token.line
            stmt.position.col = current_token.col
            stmt.parent = stmt_stack.top()
            stmt_stack.push(stmt)
            -- mark as extension
            current_token = lexer.next_token()
            if token.UnquotedString == current_token.type then
                -- unquoted argument string
                return state.unquoted_argument
            elseif token.SingleQuotedString == current_token.type or token.DoubleQuotedString == current_token.type then
                -- quoted argument string
                return state.quoted_argument
            elseif token.LeftBrace then
                -- begin substatement
                return state.substatement_begin
            elseif token.Semicolon then
                -- end statement
                return state.statement_end
            else
                lasterr = format_error('expected token "' .. token.typename(current_token.type) .. '"')
                return nil
            end
        end
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
                if nil == extension_root then
                    -- enter extension statement firstly
                    extension_root = stmt_stack.size() + 1
                end
                return state.extension
            else
                local rule = syntax(current_token.content)
                if nil == rule then
                    lasterr = format_error('unknown keyword "' .. current_token.content .. '"')
                    return nil
                end
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
