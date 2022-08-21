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
module('test_stack', lunit.testcase, package.seeall)

local stack = require('stack')

function test_stack_create()
    assert_function(stack)
    assert_table(stack())
end

function test_stack_size()
    local s = stack()
    assert_equal(0, s.size())
end

function test_stack_push()
    local s = stack()
    for i = 1, 10 do
        -- statements
        s.push(111)
        assert_equal(i, s.size())
    end
end

function test_stack_pop()
    local s = stack()
    for i = 1, 10 do
        -- statements
        s.push(i)
    end
    for i = 1, 10 do
        -- statements
        assert_equal(10 - i + 1, s.pop())
        assert_equal(10 - i, s.size())
    end
end

function test_stack_top()
    local s = stack()
    for i = 1, 10 do
        -- statements
        s.push(i * 2)
        assert_equal(i * 2, s.top())
    end
    for i = 1, 10 do
        -- statements
        assert_equal((10 - i + 1) * 2, s.top())
        s.pop()
    end
end

function test_stack_bottom()
    local s = stack()
    for i = 1, 10 do
        -- statements
        s.push(i * 2)
        assert_equal(2, s.bottom())
    end
    while s.size() > 0 do
        s.pop()
    end
    assert_nil(s.bottom())
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
