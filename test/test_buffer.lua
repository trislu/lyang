-- make sure test cases can source 'lunit'
package.path = package.path .. ';../3rd/lunit/?.lua'
-- make sure test cases can source 'src'
package.path = package.path .. ';../src/?.lua'

-- cache global env firstly
local genv = {
    -- add needed global functions here
    getfenv = getfenv,
    pcall = pcall,
    print = print,
    setfenv = setfenv
}

local buffer = require('buffer')

-- global env will be broke by lunit
require('lunit')
module('test_buffer', lunit.testcase)

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

lunit.main(...)
