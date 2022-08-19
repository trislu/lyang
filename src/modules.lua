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
local parser = require('parser')

return function()
    local module_t = {}
    local m = {
        add = function(file)
            local p = parser()
            local err, stmt = p.parse(file)
            if err then
                error(err)
            end
            if module_t[stmt.argument] then
                error(
                    file ..
                        ': ' ..
                            stmt.keyword ..
                                ' name "' ..
                                    stmt.argument .. '" conflicts, previously defined in ' .. module_t[stmt.argument][2]
                )
            end
            module_t[stmt.argument] = {stmt, file}
            -- for traverse
            module_t[#module_t + 1] = stmt
        end,
        get = function(name)
            return module_t[name]
        end,
        at = function(index)
            return module_t[index]
        end,
        count = function()
            return #module_t
        end
    }

    function m.extend(extensions)
        for _, e in ipairs(extensions) do
            -- add this extension module
            m.add(e)
            -- check if any extension definition exists
            local s = module_t[#module_t]
            if nil == s.find_child('extension') then
                error(e .. ': ' .. s.keyword .. ' "' .. s.argument .. '" defines none extensions')
            end
        end
    end

    return m
end
