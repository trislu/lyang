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
module('test_utils', lunit.testcase, package.seeall)

local utils = require('utils')

function test_string_split()
    local slices = ('/a/b/c'):split('/')
    assert_table(slices)
    assert_equal(4, #slices)
    assert_equal('', slices[1])
    assert_equal('a', slices[2])
    assert_equal('b', slices[3])
    assert_equal('c', slices[4])
end

function test_xml_escape()
    assert_equal('a &amp; b', utils.escape('a & b'))
    assert_equal('a &gt; b', utils.escape('a > b'))
    assert_equal('a &lt; b', utils.escape('a < b'))
end

function test_xml_quotedattr()
    assert_equal("'[\"name\"]'", utils.quotedattr('["name"]'))
    assert_equal("\"[&quot;na'me&quot;]\"", utils.quotedattr("[\"na'me\"]"))
    assert_equal('"[name]"', utils.quotedattr('[name]'))
end

lunit.main(...)
