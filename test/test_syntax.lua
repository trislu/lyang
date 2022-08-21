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
module('test_syntax', lunit.testcase, package.seeall)

local syntax = require('syntax')

function test_invalid_keywords()
    -- 'foo' is not a valid keyword in yang
    assert_nil(syntax('foo'))
end

function test_valid_keywords()
    -- all valid statements
    assert_not_nil(syntax('action'))
    assert_not_nil(syntax('anydata'))
    assert_not_nil(syntax('anyxml'))
    assert_not_nil(syntax('argument'))
    assert_not_nil(syntax('augment'))
    assert_not_nil(syntax('base'))
    assert_not_nil(syntax('belongs-to'))
    assert_not_nil(syntax('bit'))
    assert_not_nil(syntax('case'))
    assert_not_nil(syntax('choice'))
    assert_not_nil(syntax('config'))
    assert_not_nil(syntax('contact'))
    assert_not_nil(syntax('container'))
    assert_not_nil(syntax('default'))
    assert_not_nil(syntax('description'))
    assert_not_nil(syntax('deviate'))
    assert_not_nil(syntax('deviation'))
    assert_not_nil(syntax('enum'))
    assert_not_nil(syntax('error-app-tag'))
    assert_not_nil(syntax('error-message'))
    assert_not_nil(syntax('extension'))
    assert_not_nil(syntax('feature'))
    assert_not_nil(syntax('fraction-digits'))
    assert_not_nil(syntax('grouping'))
    assert_not_nil(syntax('identity'))
    assert_not_nil(syntax('if-feature'))
    assert_not_nil(syntax('import'))
    assert_not_nil(syntax('include'))
    assert_not_nil(syntax('input'))
    assert_not_nil(syntax('key'))
    assert_not_nil(syntax('leaf'))
    assert_not_nil(syntax('leaf-list'))
    assert_not_nil(syntax('length'))
    assert_not_nil(syntax('list'))
    assert_not_nil(syntax('mandatory'))
    assert_not_nil(syntax('max-elements'))
    assert_not_nil(syntax('min-elements'))
    assert_not_nil(syntax('modifier'))
    assert_not_nil(syntax('module'))
    assert_not_nil(syntax('must'))
    assert_not_nil(syntax('namespace'))
    assert_not_nil(syntax('notification'))
    assert_not_nil(syntax('ordered-by'))
    assert_not_nil(syntax('organization'))
    assert_not_nil(syntax('output'))
    assert_not_nil(syntax('path'))
    assert_not_nil(syntax('pattern'))
    assert_not_nil(syntax('position'))
    assert_not_nil(syntax('prefix'))
    assert_not_nil(syntax('presence'))
    assert_not_nil(syntax('range'))
    assert_not_nil(syntax('reference'))
    assert_not_nil(syntax('refine'))
    assert_not_nil(syntax('require-instance'))
    assert_not_nil(syntax('revision'))
    assert_not_nil(syntax('revision-date'))
    assert_not_nil(syntax('rpc'))
    assert_not_nil(syntax('status'))
    assert_not_nil(syntax('submodule'))
    assert_not_nil(syntax('type'))
    assert_not_nil(syntax('typedef'))
    assert_not_nil(syntax('unique'))
    assert_not_nil(syntax('units'))
    assert_not_nil(syntax('uses'))
    assert_not_nil(syntax('value'))
    assert_not_nil(syntax('when'))
    assert_not_nil(syntax('yang-version'))
    assert_not_nil(syntax('yin-element'))
end

function test_module_valid_substmt()
    local s_module = syntax('module')
    assert_true(s_module.meet('yang-version'))
    assert_true(s_module.meet('namespace'))
    assert_true(s_module.meet('prefix'))
    assert_true(s_module.meet('container'))
    assert(s_module.valid())
end

function test_module_invalid_substmt()
    local s_module = syntax('module')
    assert_false(s_module.meet('foo'))
    assert_equal(s_module.lasterr(), '"foo" is not a valid substatement of "module"')
end

function test_module_mandatory_substmt()
    local s_module = syntax('module')
    assert_true(s_module.meet('yang-version'))
    assert_true(s_module.meet('namespace'))
    assert(not s_module.valid())
    assert_equal(s_module.lasterr(), '"module" requires one "prefix" substatement but there is none')
end

function test_module_unique_substmt()
    local s_module = syntax('module')
    assert_true(s_module.meet('prefix'))
    -- too much prefix statement
    assert_false(s_module.meet('prefix'))
    assert_equal(s_module.lasterr(), '"module" can only contain one "prefix" substatement')
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
