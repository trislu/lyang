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

-- the lua require mechanism ensure the search is performed only once
local files = {}
local lyang_path = os.getenv('LYANG_PATH')
if nil == lyang_path then
    error('environment variable "LYANG_PATH" was not set')
end
for file in system.dir(lyang_path .. system.sep() .. 'addons') do
    local ret = system.path.splitext(file)
    if '.lua' == ret[2] then
        files[#files + 1] = ret[1]
    end
end
-- addon table
local addon_t = {}
-- formatter table
local formatter_t = {}

return {
    --- create the abstract 'addon' base object
    create = function()
        local base = {}
        -- base functions to be overwritten
        -- luacheck: ignore self
        function base:init()
        end
        function base:add_formatter()
            --print('base:add_formatter')
        end
        function base:add_option(argparse_)
            --print('base:add_option')
        end
        function base:setup_context(ctx_)
            --print('base:setup_context')
        end
        function base:convert(ctx_)
            --print('base:do_convert')
        end
        return base
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
    load = function(name, addon)
        addon_t[name] = addon
        addon_t[#addon_t + 1] = addon
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
    end,
    find = function(name)
        return addon_t[name]
    end,
    add_formatter = function(name, fmt)
        formatter_t[name] = fmt
        formatter_t[#formatter_t + 1] = fmt
    end,
    list_formatter = function()
        local i = 0
        local s = #formatter_t
        return function()
            i = i + 1
            if i <= s then
                return formatter_t[i]
            end
        end
    end,
    get_formatter = function(name)
        return formatter_t[name]
    end
}
