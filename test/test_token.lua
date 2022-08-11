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
-- global env will be broke by lunit
require('lunit')
module('test_token', lunit.testcase, package.seeall)

local token = require('token')

function test_create()
    assert_table(token)
    local tk = token.new(token.LeftBrace, '{', 2, 3)
    assert_table(tk)
    assert_equal(tk.type, token.LeftBrace)
    assert_equal('{', tk.content)
    assert_equal(tk.row, 2)
    assert_equal(tk.col, 3)
end

function test_create2()
    local tk1 = token.new(token.RightBrace, '}', 2, 3)
    local tk2 = token.new(token.UnquotedString, 'unquoted-string', 6, 7)
    assert_not_equal(tk1, tk2)
    assert_table(tk1)
    assert_equal(tk1.type, token.RightBrace)
    assert_equal('}', tk1.content)
    assert_equal(tk1.row, 2)
    assert_equal(tk1.col, 3)
    assert_table(tk2)
    assert_equal(tk2.type, token.UnquotedString)
    assert_equal('unquoted-string', tk2.content)
    assert_equal(tk2.row, 6)
    assert_equal(tk2.col, 7)
end

lunit.main(...)
