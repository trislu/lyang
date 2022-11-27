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
module('test_log', lunit.testcase, package.seeall)

local log = require('log')

function test_debug()
    log.set_level(log.DEBUG)
    log.debug('test_debug: debug = %d', log.DEBUG)
end

function test_info()
    log.set_level(log.INFO)
    log.debug('test_info: debug = %d', log.DEBUG)
    log.info('test_info: info = %d', log.INFO)
end

function test_warning()
    log.set_level(log.WARNING)
    log.debug('test_warning: debug = %d', log.DEBUG)
    log.info('test_warning: info = %d', log.INFO)
    log.warning('test_warning: warning = %d', log.WARNING)
end

function test_error()
    log.set_level(log.ERROR)
    log.debug('test_error: debug = %d', log.DEBUG)
    log.info('test_error: info = %d', log.INFO)
    log.warning('test_error: warning = %d', log.WARNING)
    log.error('test_error: error = %d', log.ERROR)
end

pcall(
    function(r)
        os.exit(r.failed + r.errors)
    end,
    lunit.main(...)
)
