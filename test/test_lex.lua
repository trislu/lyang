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
require('lunit')
module('test_lex', lunit.testcase, package.seeall)

local buffer = require('buffer')
local lex = require('lex')
local token = require('token')

function test_unquoted_string()
    local b = buffer()
    local str = 'hello world'
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens + 1] = tk
        else
            break
        end
    end
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', tk1.content)
    local tk2 = tokens[2]
    assert_equal(token.UQSTR, tk2.type)
    assert_equal('world', tk2.content)
end

function test_single_quoted_string()
    local b = buffer()
    local str = "hello 'world'"
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens + 1] = tk
        else
            break
        end
    end
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', tk1.content)
    local tk2 = tokens[2]
    assert_equal(token.SQSTR, tk2.type)
    assert_equal('world', tk2.content)
end

function test_double_quoted_string()
    local b = buffer()
    local str = 'hello "world"'
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens + 1] = tk
        else
            break
        end
    end
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', tk1.content)
    local tk2 = tokens[2]
    assert_equal(token.DQSTR, tk2.type)
    assert_equal('world', tk2.content)
end

function test_single_character()
    local b = buffer()
    local str = 'hello "world";{}'
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens + 1] = tk
        else
            break
        end
    end
    local tk1 = tokens[3]
    assert_equal(token.SCOLON, tk1.type)
    assert_equal(';', tk1.content)
    local tk2 = tokens[4]
    assert_equal(token.LBRACE, tk2.type)
    assert_equal('{', tk2.content)
    local tk3 = tokens[5]
    assert_equal(token.RBRACE, tk3.type)
    assert_equal('}', tk3.content)
end

function test_line_comment()
    local b = buffer()
    local str = [[
            hello
            // skip this line
            "world";
        ]]
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens + 1] = tk
        else
            break
        end
    end
    assert_equal(3, #tokens)
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', tk1.content)
    local tk2 = tokens[2]
    assert_equal(token.DQSTR, tk2.type)
    assert_equal('world', tk2.content)
    local tk3 = tokens[3]
    assert_equal(token.SCOLON, tk3.type)
    assert_equal(';', tk3.content)
end

function test_block_comment()
    local b = buffer()
    local str =
        [[
            hello
            /*
                skip this block
            */
            "world";
        ]]
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens + 1] = tk
        else
            break
        end
    end
    assert_equal(3, #tokens)
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', tk1.content)
    local tk2 = tokens[2]
    assert_equal(token.DQSTR, tk2.type)
    assert_equal('world', tk2.content)
    local tk3 = tokens[3]
    assert_equal(token.SCOLON, tk3.type)
    assert_equal(';', tk3.content)
end

lunit.main(...)
