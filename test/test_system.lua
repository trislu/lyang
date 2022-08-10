-- cache global env firstly
local genv = {
    -- add needed global functions here
    getfenv = getfenv,
    pcall = pcall,
    print = print,
    setfenv = setfenv
}

local system = require('system')
local _type = {
    win = WINDOWS,
    unix = UNIX
}

local sep = package.config:sub(1, 1)

-- global env will be broke by lunit
require('lunit')
module('test_system', lunit.testcase)

function test_sep()
    assert_equal(sep, system.sep())
end

function test_type()
    if '/' == sep then
        assert_equal(_type.unix, system.type())
    elseif '\\' == sep then
        assert_equal(_type.win, system.type())
    end
end

function test_dir()
    local filelist = {
        ['devcontainer.json'] = 1,
        ['Dockerfile'] = 2
    }
    local testdir = '../.devcontainer/'
    for abspath in system.dir(testdir) do
        local trimed = abspath:sub(#testdir + 1, #abspath)
        assert_not_nil(filelist[trimed])
    end
end

lunit.main(...)
