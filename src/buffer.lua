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

--local addon = require('addon')

return function ()
    local buf = {}
    local b = {
        load = function(filename)
            local fd = io.open(filename, 'r')
            local text = fd:read('*a')
            local len = string.len(text)
            for i = 1, len do
                table.insert(buf, string.sub(text, i, i))
            end
        end,
        at = function (pos)
            -- statements
            return buf[pos + 1]
        end,
        sub = function(start_pos, end_pos)
            return table.concat(buf, nil, start_pos + 1, end_pos + 1)
        end,
        len = function()
            return #buf
        end
    }
    --[[ the buffer should be fast enough
    if addon.custom_buffer then
        -- if custom_buffer is implemented via addon
        return addon.custom_buffer
    end
    ]]
    return b
end