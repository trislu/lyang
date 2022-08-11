-- cache global env firstly
local genv = {
    -- add needed global functions here
    getfenv = getfenv,
    pcall = pcall,
    print = print,
    setfenv = setfenv,
    type = type
}

local syntax = require('syntax')

-- global env will be broke by lunit
require('lunit')
module('test_syntax', lunit.testcase)

function test_valid_module()
    local v_module = syntax.validate_substmt_of('module')
    assert_true(v_module.meet('yang-version'))
    assert_true(v_module.meet('namespace'))
    assert_true(v_module.meet('prefix'))
    assert_true(v_module.meet('container'))
    assert_true(v_module.fin())
end

function test_invalid_module()
    local v_module = syntax.validate_substmt_of('module')
    assert_false(v_module.meet('foo'))
    assert_equal(v_module.lasterr(),'"foo" is not a valid substatement of "module"')
    assert_false(v_module.fin())
    assert_equal(v_module.lasterr(),'"module" requires one "yang-version" substatement but there is none')
end

lunit.main(...)
