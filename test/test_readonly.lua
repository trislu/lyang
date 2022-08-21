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
module('test_readonly', lunit.testcase, package.seeall)

local readonly = require('readonly')

function test_ro()
    local ro =
        readonly {
        alice = 'alice',
        bob = {'bob'},
        42,
        function()
            return {foo = 'bar'}
        end
    }
    assert_equal('alice', ro.alice)
    assert_equal('bob', ro.bob[1])
    assert_equal(42, ro[1])
    assert_function(ro[2])
    assert_error(
        function()
            ro[1] = 43
        end
    )
    assert_error(
        function()
            ro[3] = 'new'
        end
    )
    -- the return table is mutable
    local ret = ro[2]()
    assert_table(ret)
    assert_equal('bar', ret.foo)
    assert_pass(
        function()
            ret.foo = 'qux'
        end
    )
    assert_pass(
        function()
            ret[1] = 'baz'
        end
    )
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
