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
module('test_scanner', lunit.testcase, package.seeall)

local buffer = require('buffer')
local scanner = require('scanner')
local token = require('token')

function test_create()
    assert_function(scanner)
    local s = scanner(buffer())
    assert_table(s)
end

function test_next()
    local b = buffer()
    b.loadstring('hello world')
    local s = scanner(b)
    for i = 1, b.len() do
        -- statements
        local ch = s.next()
        assert_equal(ch, b.at(i - 1))
    end
    assert_nil(s.next())
end

function test_peek()
    local b = buffer()
    b.loadstring('hello world')
    local s = scanner(b)
    assert_equal('h', s.peek())
end

function test_peek2()
    local b = buffer()
    b.loadstring('hello world')
    local s1 = scanner(b)
    assert_equal('he', s1.peek2())
    b.loadstring('d')
    local s2 = scanner(b)
    assert_equal(1, b.len())
    --assert_nil(s2.peek2())
end

function test_make_token()
    local b = buffer()
    b.loadstring('hello world')
    local s = scanner(b)
    local ch = s.next() -- h
    s.consume() -- point to 'h'
    s.next() -- e
    s.next() -- l
    s.next() -- l
    s.next() -- o
    local tk2 = s.make_string_token(token.UQSTR)
    assert_equal('hello', tk2.content)
    s.next() -- skip ws
    s.next() -- w
    s.consume() -- point to 'w'
    s.next() -- o
    s.next() -- r
    s.next() -- l
    s.next() -- d
    local tk3 = s.make_string_token(token.UQSTR)
    assert_equal('world', tk3.content)
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
