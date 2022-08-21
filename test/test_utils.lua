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

function test_decouple_nodeid()
    local ok, prefix, indent = utils.decouple_nodeid('bob')
    assert_true(ok)
    assert_nil(prefix)
    assert_equal('bob', indent)

    ok, prefix, indent = utils.decouple_nodeid('a:b')
    assert_true(ok)
    assert_equal('a', prefix)
    assert_equal('b', indent)

    assert_false(utils.decouple_nodeid(':b'))
    assert_false(utils.decouple_nodeid('a::b'))
    assert_false(utils.decouple_nodeid('a:b:c'))
end

function test_tokenize_feature_expr()
    local tokens = utils.tokenize_feature_expr('outbound-tls or outbound-ssh')
    assert_table(tokens)
    assert_equal(3, #tokens)
    assert_equal('outbound-tls', tokens[1])
    assert_equal('or', tokens[2])
    assert_equal('outbound-ssh', tokens[3])

    tokens = utils.tokenize_feature_expr('not foo or bar and baz')
    assert_table(tokens)
    assert_equal(6, #tokens)
    assert_equal('not', tokens[1])
    assert_equal('foo', tokens[2])
    assert_equal('or', tokens[3])
    assert_equal('bar', tokens[4])
    assert_equal('and', tokens[5])
    assert_equal('baz', tokens[6])

    tokens = utils.tokenize_feature_expr('(not foo) or (bar and baz)')
    assert_table(tokens)
    assert_equal(10, #tokens)
    assert_equal('(', tokens[1])
    assert_equal('not', tokens[2])
    assert_equal('foo', tokens[3])
    assert_equal(')', tokens[4])
    assert_equal('or', tokens[5])
    assert_equal('(', tokens[6])
    assert_equal('bar', tokens[7])
    assert_equal('and', tokens[8])
    assert_equal('baz', tokens[9])
    assert_equal(')', tokens[10])
end

function test_match_positive_integer()
    for i = 1, 65536 do
        local s = tostring(i)
        assert_true(utils.is_postive_integer(s), s .. ' is not a positive integer')
    end

    assert_false(utils.is_postive_integer('-123'))
    assert_false(utils.is_postive_integer('0123'))
    assert_false(utils.is_postive_integer('123.'))
    assert_false(utils.is_postive_integer('123 '))
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
