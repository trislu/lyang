-- cache global env firstly
local genv = {
    -- add needed global functions here
    getfenv = getfenv,
    pcall = pcall,
    print = print,
    setfenv = setfenv
}

local argparse = require('argparse')

-- global env will be broke by lunit
require('lunit')
module('test_argparse', lunit.testcase)

function test_create_parser()
    local p = argparse.create()
    assert_not_nil(p, 'create paser return nil!')
end

function test_print_usage()
    local p = argparse.create()
    local _sandbox = genv.getfenv(p.print_usage)
    _sandbox.print = function(params)
        -- sandbox print
        if params then
        --genv.print('[sandbox.print]', params)
        end
    end
    genv.setfenv(p.print_usage, _sandbox)
    local status, err = genv.pcall(p.print_usage)
    assert_true(status, err)
end

function test_add_arguments()
    local p = argparse.create()
    -- nil
    assert_false(genv.pcall(p.add_argument, nil))
    -- string
    assert_false(genv.pcall(p.add_argument, 'foo'))
    -- number
    assert_false(genv.pcall(p.add_argument, 123))
    -- boolean
    assert_false(genv.pcall(p.add_argument, true))
    assert_false(genv.pcall(p.add_argument, false))
    -- invalid table : name not given
    local invalid_option = {
        help = 'just for test'
    }
    -- option name not given
    assert_false(genv.pcall(p.add_argument, invalid_option))
    -- too much option names
    invalid_option[#invalid_option + 1] = '-t'
    invalid_option[#invalid_option + 1] = '--test'
    invalid_option[#invalid_option + 1] = 'bad'
    assert_false(genv.pcall(p.add_argument, invalid_option))
    -- action not specified
    invalid_option[3] = nil
    invalid_option.action = nil
    assert_false(genv.pcall(p.add_argument, invalid_option))
    -- unknown action
    invalid_option.action = 'unknown'
    assert_false(genv.pcall(p.add_argument, invalid_option))
    -- unknown nargs
    invalid_option.action = 'store'
    invalid_option.nargs = 'zzz'
    assert_false(genv.pcall(p.add_argument, invalid_option))
    -- invalid option name
    invalid_option.nargs = nil
    invalid_option[1] = 'tt'
    assert_false(genv.pcall(p.add_argument, invalid_option))
    -- fix every thing, now it becomes a valid option
    invalid_option[1] = '-t'
    assert_true(genv.pcall(p.add_argument, invalid_option))
end

function test_parse_args()
    local p = argparse.create()
    -- prepare test option
    local test_option = {
        '-t',
        '--test',
        action = 'store_true',
        dest = 'test',
        help = 'Display this information'
    }
    p.add_argument(test_option)
    -- test positional argument
    local status, ret = genv.pcall(p.parse_args, {'test.lua'})
    assert_true(status)
    assert_equal(#ret, 1)
    assert_equal(ret[1], 'test.lua')
    -- test short form
    status, ret = genv.pcall(p.parse_args, {'-t'})
    assert_true(status)
    -- test long form
    status, ret = genv.pcall(p.parse_args, {'--test'})
    assert_true(status)
    -- test action
    status, ret = genv.pcall(p.parse_args, {'--test'})
    assert_true(status)
    assert_not_nil(ret.test)
    assert_boolean(ret.test)
    -- test nargs
    local nargs_option = {
        '-n',
        '--nargs',
        action = 'store',
        nargs = 2,
        dest = 'result',
        help = 'Display this information'
    }
    p.add_argument(nargs_option)
    status, ret = genv.pcall(p.parse_args, {'--nargs', 'a', 'b'})
    assert_true(status)
    assert_not_nil(ret.result)
    assert_table(ret.result)
    assert_equal(2, #ret.result)
    assert_equal('a', ret.result[1])
    assert_equal('b', ret.result[2])
end

lunit.main(...)
