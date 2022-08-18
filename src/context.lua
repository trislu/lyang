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
local modules = require('modules')

return function()
    local cov_t = {}
    local ctx = {
        converters = {
            add = function(name, cov)
                if type(name) ~= 'string' then
                    error "converter's name must be a string"
                end
                if not (cov and cov.convert and type(cov.convert) == 'function') then
                    error 'converter must implement a ":convert()" function'
                end
                cov_t[name] = cov
                cov_t[#cov_t + 1] = {cov, name}
            end,
            list = function()
                local i = 0
                local s = #cov_t
                return function()
                    i = i + 1
                    if i <= s then
                        return cov_t[i][2]
                    end
                end
            end,
            get = function(name)
                return cov_t[name]
            end
        },
        dependent_modules = {},
        modules = modules()
    }
    return ctx
end
