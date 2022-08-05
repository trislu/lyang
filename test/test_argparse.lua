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
}

local argparse = require('argparse')

-- global env will be broke by lunit
require('lunit')
module( "test_argparse", lunit.testcase)

function test_create_parser()
    local p = argparse.create()
    assert_not_nil( p, "create paser return nil!")
end

function test_print_usage()
    local p = argparse.create()
    local _sandbox = genv.getfenv(p.print_usage)
    _sandbox.print = function(params)
        -- sandbox print
        if params then
            genv.print('[sandbox.print]', params)
        end
    end
    genv.setfenv(p.print_usage, _sandbox)
    local status, err = genv.pcall(p.print_usage)
    assert_true( status, err )
end

lunit.main(...)