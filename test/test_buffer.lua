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
module('test_buffer', lunit.testcase, package.seeall)

local buffer = require('buffer')

function test_require()
    assert_function(buffer)
    local b = buffer()
    assert_table(b)
end

function test_load()
    local b1 = buffer()
    b1.load('Makefile')
    assert_table(b1)
    local b2 = buffer()
    b2.load('test_buffer.lua')
    assert_table(b2)
    assert_not_equal(b1.len(), b2.len())
end

function test_sub()
    local b = buffer()
    b.load('Makefile')
    assert_equal('usage', b.sub(0, 4))
end

function test_at()
    -- statements
    local b = buffer()
    b.load('Makefile')
    assert_equal('u', b.at(0))
    assert_equal('s', b.at(1))
    assert_equal('a', b.at(2))
    assert_equal('g', b.at(3))
    assert_equal('e', b.at(4))
    assert_equal(':', b.at(5))
end

function test_loadstring()
    -- statements
    local b = buffer()
    local str = 'hello world'
    b.loadstring(str)
    assert_equal(str, b.sub(0, b.len() - 1))
end

function test_clear()
    local b = buffer()
    local str = 'hello world'
    b.loadstring(str)
    b.clear()
    assert_equal(b.len(), 0)
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
