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

local token = require('token')

-- global env will be broke by lunit
require('lunit')
module('test_token', lunit.testcase)

function test_create()
    assert_table(token)
    local tk = token.create(token.CHAR, 0, 1, 2, 3)
    assert_table(tk)
    assert_equal(tk.type, token.CHAR)
    assert_equal(tk.start, 0)
    assert_equal(tk.length, 1)
    assert_equal(tk.row, 2)
    assert_equal(tk.col, 3)
end

function test_create2()
    local tk1 = token.create(token.CHAR, 0, 1, 2, 3)
    local tk2 = token.create(token.UQSTR, 4, 5, 6, 7)
    assert_not_equal(tk1, tk2)
    assert_table(tk1)
    assert_equal(tk1.type, token.CHAR)
    assert_equal(tk1.start, 0)
    assert_equal(tk1.length, 1)
    assert_equal(tk1.row, 2)
    assert_equal(tk1.col, 3)
    assert_table(tk2)
    assert_equal(tk2.type, token.UQSTR)
    assert_equal(tk2.start, 4)
    assert_equal(tk2.length, 5)
    assert_equal(tk2.row, 6)
    assert_equal(tk2.col, 7)
end

lunit.main(...)
