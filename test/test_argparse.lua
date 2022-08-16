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
module('test_argparse', lunit.testcase, package.seeall)

local argparse = require('argparse')

function test_create_parser()
    local p = argparse()
    assert_not_nil(p, 'create paser return nil!')
end

function test_print_usage()
    local p = argparse()
    local _sandbox = getfenv(p.print_usage)
    _sandbox.print = function(params_)
        -- sandbox print
    end
    setfenv(p.print_usage, _sandbox)
    local status, err = pcall(p.print_usage)
    assert_true(status, err)
end

function test_add_arguments()
    local p = argparse()
    -- nil
    assert_false(pcall(p.add_argument, nil))
    -- string
    assert_false(pcall(p.add_argument, 'foo'))
    -- number
    assert_false(pcall(p.add_argument, 123))
    -- boolean
    assert_false(pcall(p.add_argument, true))
    assert_false(pcall(p.add_argument, false))
    -- invalid table : name not given
    local invalid_option = {
        help = 'just for test'
    }
    -- option name not given
    assert_false(pcall(p.add_argument, invalid_option))
    -- too much option names
    invalid_option[#invalid_option + 1] = '-t'
    invalid_option[#invalid_option + 1] = '--test'
    invalid_option[#invalid_option + 1] = 'bad'
    assert_false(pcall(p.add_argument, invalid_option))
    -- action not specified
    invalid_option[3] = nil
    invalid_option.action = nil
    assert_false(pcall(p.add_argument, invalid_option))
    -- unknown action
    invalid_option.action = 'unknown'
    assert_false(pcall(p.add_argument, invalid_option))
    -- unknown nargs
    invalid_option.action = 'store'
    invalid_option.nargs = 'zzz'
    assert_false(pcall(p.add_argument, invalid_option))
    -- invalid option name
    invalid_option.nargs = nil
    invalid_option[1] = 'tt'
    assert_false(pcall(p.add_argument, invalid_option))
    -- fix every thing, now it becomes a valid option
    invalid_option[1] = '-t'
    assert_true(pcall(p.add_argument, invalid_option))
end

function test_parse_args()
    local p = argparse()
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
    local status, ret = pcall(p.parse_args, {'test.lua'})
    assert_true(status)
    assert_equal(1, #ret)
    assert_equal(ret[1], 'test.lua')
    -- test short form
    status, ret = pcall(p.parse_args, {'-t'})
    assert_true(status)
    -- test long form
    status, ret = pcall(p.parse_args, {'--test'})
    assert_true(status)
    -- test action
    status, ret = pcall(p.parse_args, {'--test'})
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
    status, ret = pcall(p.parse_args, {'--nargs', 'a', 'b'})
    assert_true(status)
    assert_not_nil(ret.result)
    assert_table(ret.result)
    assert_equal(2, #ret.result)
    assert_equal('a', ret.result[1])
    assert_equal('b', ret.result[2])
end

lunit.main(...)
