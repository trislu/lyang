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
assert(..., [[this is a require only module, don't use it as the main]])

local lex = require('lex')
local token = lex.token

local function emit_error(state, err)
    local errs = state.errs
    errs[#errs+1] = err
end

local function get_current_token(state)
    return state.tokens[state.index]
end

local function consume_current_token(state)
    state.index = state.index + 1
end

local parse_until_valid(state, valid_states)
    -- go to next state
    local token_type
    while state.index < #state.tokens do
        token_type, content, row, col = table.unpack(get_current_token(state))
        local next = valid_states[token_type]
        if next then
            return next
        end
        -- todo: emit error for unexpected token
        emit_error(state, {
            start = {
                row = row,
                col = col
            },
            length = #content,
            type = 'UNEXPECTED_TOKEN'
        })
        -- consume unexpected token
        consume_current_token(state)
    end
    return nil
end

local parse_keyword_next = {}
local parse_keyword = function(state)
    local _, content, row, col = table.unpack(get_current_token(state))
    -- emit statement
    local stmt = {
        keyword = content,
        argument = nil,
        position = {
            row = row,
            col = col
        },
        parent = state.stmt_stack[#state.stmt_stack],
        substatement = {}
    }
    -- push onto stack
    state.stmt_stack[#state.stmt_stack + 1] = stmt
    -- consume keyword
    consume_current_token(state)
    -- parse until next valid state
    return parse_until_valid(state, parse_keyword_next)
end

local parse_argument_next = {}
local parse_argument = function(state)
    local _, content = table.unpack(get_current_token(state))
    -- current stmt
    local cur_stmt = state.stmt_stack[#state.stmt_stack]
    -- update argument
    if cur_stmt.argument then
        -- concat argument string
        cur_stmt.argument = cur_stmt.argument..content
    else
        cur_stmt.argument = content
    end
    -- consume argument string
    consume_current_token(state)
    -- parse until next valid state
    return parse_until_valid(state, parse_argument_next)
end

local parse_plus_next = {}
local parse_plus = function(state)
    -- consume plus
    consume_current_token(state)
    -- parse until next valid state
    return parse_until_valid(state, parse_plus_next)
end

local parse_lbrace_next = {}
local parse_lbrace = function(state)
    -- consume lbrace
    consume_current_token(state)
    -- parse until next valid state
    return parse_until_valid(state, parse_lbrace_next)
end

local parse_rbrace_next = {}
local parse_rbrace = function(state)
    -- consume rbrace
    consume_current_token(state)
    -- add current statement
    local cur_stmt = state.stmt_stack[#state.stmt_stack]
    if cur_stmt.parent then
        -- as parent's substatement
        cur_stmt.parent.substatement[#cur_stmt.parent.substatement + 1] = cur_stmt
    else
        -- root statement
        local ast = state.ast
        ast[#ast + 1] = cur_stmt
    end
    -- pop statement stack
    state.stmt_stack[#state.stmt_stack] = nil
    -- parse until next valid state
    return parse_until_valid(state, parse_rbrace_next)
end

local parse_scolon_next = {}
local parse_scolon = function(state)
    -- consume rbrace
    consume_current_token(state)
    -- add current statement
    local cur_stmt = state.stmt_stack[#state.stmt_stack]
    if cur_stmt.parent then
        -- as parent's substatement
        cur_stmt.parent.substatement[#cur_stmt.parent.substatement + 1] = cur_stmt
    else
        -- root statement
        local ast = state.ast
        ast[#ast + 1] = cur_stmt
    end
    -- pop statement stack
    state.stmt_stack[#state.stmt_stack] = nil
    -- parse until next valid state
    return parse_until_valid(state, parse_scolon_next)
end

-- next valid states of "parse keyword"
parse_keyword_next[token.UQSTR] = parse_argument
parse_keyword_next[token.SQSTR] = parse_argument
parse_keyword_next[token.DQSTR] = parse_argument
parse_keyword_next[token.SCOLON] = parse_scolon
parse_keyword_next[token.LBRACE] = parse_lbrace

-- next valid states of "parse argument"
parse_argument_next[token.PLUS] = parse_plus
parse_argument_next[token.SCOLON] = parse_scolon
parse_argument_next[token.LBRACE] = parse_lbrace

-- next valid states of "parse plus"
parse_plus_next[token.SQSTR] = parse_argument
parse_plus_next[token.DQSTR] = parse_argument

-- next valid states of "parse lbrace"
parse_lbrace_next[token.UQSTR] = parse_keyword
parse_lbrace_next[token.RBRACE] = parse_rbrace

-- next valid states of "parse rbrace"
parse_rbrace_next[token.UQSTR] = parse_keyword
parse_rbrace_next[token.RBRACE] = parse_rbrace

-- next valid states of "parse rbrace"
parse_scolon_next[token.UQSTR] = parse_keyword
parse_scolon_next[token.RBRACE] = parse_rbrace

return function(str)
    local state = {
        -- version = version,
        ast = {},
        errs = {},
        index = 1,
        stmt_stack = {},
        tokens = lex.emit_tokens(str)
    }

    -- do parse
    local next = parse_keyword
    while next do
        next = next(state)
    end

    local result = {
        ast = state.ast,
        errs = state.errs
    }

    return result
end
