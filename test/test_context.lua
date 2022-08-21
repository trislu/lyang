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
module('test_context', lunit.testcase, package.seeall)

local context = require('context')

function test_add_converter()
    local cov_name = 'foo'
    local cov = {'bar'}
    local ctx = context()
    assert_error(
        function()
            ctx.converters.add(cov_name, cov)
        end
    )
    cov.convert = function()
        -- dummy convert
    end
    assert_pass(
        function()
            ctx.converters.add(cov_name, cov)
        end
    )
end

function test_list_converter()
    local cov_names = {'alice', 'bob', 'carol', 'dave', 'eve'}
    local cov = {
        convert = function()
        end
    }
    local ctx = context()
    for i = 1, #cov_names do
        assert_pass(
            function()
                ctx.converters.add(cov_names[i], cov)
            end
        )
    end

    local j = 1
    for cov_name in ctx.converters.list() do
        assert_equal(cov_names[j], cov_name)
        j = j + 1
    end
end

function test_get_converter()
    local cov_names = {'alice', 'bob', 'carol', 'dave', 'eve'}
    local cov = {
        convert = function()
        end
    }
    local ctx = context()
    for i = 1, #cov_names do
        assert_pass(
            function()
                ctx.converters.add(cov_names[i], cov)
            end
        )
    end

    for j = 1, #cov_names do
        assert_not_nil(ctx.converters.get(cov_names[j]))
    end

    assert_nil(ctx.converters.get('zack'))
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
