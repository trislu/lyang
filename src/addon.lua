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
local system = require('system')

local addon_t = {}

--
local files = {}
local lyang_path = os.getenv('LYANG_PATH')
if nil == lyang_path then
    error('environment variable "LYANG_PATH" was not set')
end
for file in system.dir(lyang_path .. system.sep() .. 'addons') do
    local ret = system.path.splitext(file)
    if '.lua' == ret[2] then
        print('scan ', ret[1])
        files[#files + 1] = ret[1]
    end
end

return {
    new = function()
        local a = {}
        -- base functions to be overwritten
        function a:init()
            print('a:init')
        end
        function a:add_option(argparse)
            print('a:add_option')
        end
        function a:setup_context(ctx)
            print('a:setup_context')
        end
        function a:add_formatter(ctx)
            print('a:add_formatter')
        end
        function a:generate(ctx)
            print('a:generate')
        end
        return a
    end,
    scan = function()
        local i = 0
        local s = #files
        return function()
            i = i + 1
            if i <= s then
                return files[i]
            end
        end
    end,
    add = function(a)
        addon_t[#addon_t+1] = a
    end,
    list = function()
        local i = 0
        local s = #addon_t
        return function()
            i = i + 1
            if i <= s then
                return addon_t[i]
            end
        end
    end
}
