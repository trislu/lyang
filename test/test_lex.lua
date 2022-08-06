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
    setfenv = setfenv,
    type = type
}

local buffer = require('buffer')
local lex = require('lex')
local token = require('token')

-- global env will be broke by lunit
require('lunit')
module( "test_buffer", lunit.testcase)

function test_unquoted_string()
    local b = buffer()
    local str = 'hello world'
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens+1] = tk
        else
            break
        end
    end
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', b.sub(tk1.start, tk1.start + tk1.length))
    local tk2 = tokens[2]
    assert_equal(token.UQSTR, tk2.type)
    assert_equal('world', b.sub(tk2.start, tk2.start + tk2.length))
end

function test_single_quoted_string()
    local b = buffer()
    local str = 'hello \'world\''
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens+1] = tk
        else
            break
        end
    end
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', b.sub(tk1.start, tk1.start + tk1.length))
    local tk2 = tokens[2]
    assert_equal(token.SQSTR, tk2.type)
    assert_equal('world', b.sub(tk2.start, tk2.start + tk2.length))
end

function test_double_quoted_string()
    local b = buffer()
    local str = 'hello "world"'
    b.loadstring(str)
    local lexer = lex(b)
    local tokens = {}
    while true do
        local tk = lexer.next_token()
        if tk then
            tokens[#tokens+1] = tk
        else
            break
        end
    end
    local tk1 = tokens[1]
    assert_equal(token.UQSTR, tk1.type)
    assert_equal('hello', b.sub(tk1.start, tk1.start + tk1.length))
    local tk2 = tokens[2]
    assert_equal(token.DQSTR, tk2.type)
    assert_equal('world', b.sub(tk2.start, tk2.start + tk2.length))
end

lunit.main(...)