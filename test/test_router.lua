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
module('test_router', lunit.testcase, package.seeall)

local router = require('router')

function test_basic()
    local r = router()
    assert_pass(
        function()
            r.push('ietf-interfaces:interfaces')
            r.push('interface')
            r.push('name')
        end
    )
    assert_equal('/ietf-interfaces:interfaces/interface/name', r.concat())
    assert_pass(
        function()
            r.pop()
        end
    )
    assert_equal('/ietf-interfaces:interfaces/interface', r.concat())
end

function test_grouping()
    local r = router()
    assert_pass(
        function()
            r.push('ietf-interfaces:interfaces')
            r.push('interface')
            r.grouping_enter('ietf-interfaces:foo')
        end
    )
    assert_equal('/grouping@ietf-interfaces:foo', r.concat())

    assert_pass(
        function()
            r.push('foo-container')
            r.push('foo-list')
        end
    )
    assert_equal('/grouping@ietf-interfaces:foo/foo-container/foo-list', r.concat())

    assert_equal('foo-list', r.pop())
    assert_equal('foo-container', r.pop())

    assert_pass(
        function()
            r.grouping_leave()
        end
    )

    assert_equal('/ietf-interfaces:interfaces/interface', r.concat())
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
