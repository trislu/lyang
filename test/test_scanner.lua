-- cache global env firstly
local genv = {
    -- add needed global functions here
    getfenv = getfenv,
    pcall = pcall,
    print = print,
    setfenv = setfenv
}

local buffer = require('buffer')
local scanner = require('scanner')
local token = require('token')

-- global env will be broke by lunit
require('lunit')
module('test_scanner', lunit.testcase)

function test_create()
    assert_function(scanner)
    local s = scanner(buffer())
    assert_table(s)
end

function test_next()
    local b = buffer()
    b.loadstring('hello world')
    local s = scanner(b)
    for i = 1, b.len() do
        -- statements
        local ch = s.next()
        assert_equal(ch, b.at(i - 1))
    end
    assert_nil(s.next())
end

function test_peek()
    local b = buffer()
    b.loadstring('hello world')
    local s = scanner(b)
    assert_equal('h', s.peek())
end

function test_peek2()
    local b = buffer()
    b.loadstring('hello world')
    local s1 = scanner(b)
    assert_equal('he', s1.peek2())
    b.loadstring('d')
    local s2 = scanner(b)
    assert_equal(1, b.len())
    --assert_nil(s2.peek2())
end

function test_make_token()
    local b = buffer()
    b.loadstring('hello world')
    local s = scanner(b)
    local ch = s.next() -- h
    s.consume() -- point to 'h'
    local tk1 = s.make_token(token.CHAR)
    assert_equal('h', b.sub(tk1.start, tk1.start + tk1.length))
    s.next() -- e
    s.next() -- l
    s.next() -- l
    s.next() -- o
    local tk2 = s.make_token(token.UQSTR)
    assert_equal('hello', b.sub(tk2.start, tk2.start + tk2.length))
    s.next() -- skip ws
    s.next() -- w
    s.consume() -- point to 'w'
    s.next() -- o
    s.next() -- r
    s.next() -- l
    s.next() -- d
    local tk3 = s.make_token(token.UQSTR)
    assert_equal('world', b.sub(tk3.start, tk3.start + tk3.length))
end

lunit.main(...)
