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
module('test_system', lunit.testcase, package.seeall)

local system = require('system')

local sep = package.config:sub(1, 1)

function test_sep()
    assert_equal(sep, system.sep())
end

function test_type()
    if '/' == sep then
        assert_equal(system.UNIX, system.type())
    elseif '\\' == sep then
        assert_equal(system.WINDOWS, system.type())
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

function test_path_basename()
    assert_equal('abc.lua', system.path.basename('/a/b/c/abc.lua'))
    assert_equal('abc.lua', system.path.basename('http://foo.com/abc.lua'))
    assert_equal('abc.lua', system.path.basename('abc.lua'))
    assert_equal('abc', system.path.basename('abc'))
end

function test_path_splitext()
    local r = nil
    -- local path
    r = system.path.splitext('/a/b/c/abc.lua')
    assert_table(r)
    assert_equal(2, #r)
    assert_equal('abc', r[1])
    assert_equal('.lua', r[2])
    -- network path
    r = system.path.splitext('http://foo.com/abc.lua')
    assert_table(r)
    assert_equal(2, #r)
    assert_equal('abc', r[1])
    assert_equal('.lua', r[2])
    -- without seperator
    r = system.path.splitext('abc.lua')
    assert_table(r)
    assert_equal(2, #r)
    assert_equal('abc', r[1])
    assert_equal('.lua', r[2])
    -- without ext
    r = system.path.splitext('/foo/abc')
    assert_table(r)
    assert_equal(1, #r)
    assert_equal('abc', r[1])
    assert_nil(r[2])
end

lunit.main(...)
