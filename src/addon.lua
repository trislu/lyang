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

local addon_list = {}

return {
    init = function()
        local lyang_path = os.getenv('LYANG_PATH')
        if nil == lyang_path then
            error('environment variable "LYANG_PATH" was not set')
        end
        local addon_scan = system.dir(lyang_path .. system.sep() .. 'addons')
        while true do
            -- statements
            local addon = addon_scan()
            if nil == addon then
                break
            end
            local ret = system.path.splitext(addon)
            if '.lua' == ret[2] then
                require(ret[1])
                addon_list[#addon_list + 1] = ret[1]
            end
        end
    end
}
