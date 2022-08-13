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
module('test_parser', lunit.testcase, package.seeall)

local parser = require('parser')

function test_empty_module()
    local mod = [[
        module foo {}
    ]]
    local p = parser()
    local err, root = p.parse_string(mod)
    assert_string(err)
    assert_table(root)
    assert_equal('module', root.keyword)
    assert_equal('foo', root.argument)
end

function test_valid_module()
    local mod =
        [[
        module foo {
            yang-version 1.1;
            prefix f;
            namespace "http://lyang/foo";
        }
    ]]
    local p = parser()
    local err, root = p.parse_string(mod)
    assert_nil(err)
    assert_table(root)
    assert_equal('module', root.keyword)
    assert_equal('foo', root.argument)
    -- 3 substatemnts
    assert_equal(3, root.substmt_count())
    --
    local sub1 = root.substmt(1)
    assert_equal('yang-version', sub1.keyword)
    assert_equal('1.1', sub1.argument)
    assert_equal(0, sub1.substmt_count())
    --
    local sub2 = root.substmt(2)
    assert_equal('prefix', sub2.keyword)
    assert_equal('f', sub2.argument)
    assert_equal(0, sub2.substmt_count())
    --
    local sub3 = root.substmt(3)
    assert_equal('namespace', sub3.keyword)
    assert_equal('http://lyang/foo', sub3.argument)
    assert_equal(0, sub3.substmt_count())
end

lunit.main(...)
