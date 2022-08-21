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
assert(..., [[this is a require only module, don't use it as the main]])

local readonly = require('readonly')

local m = {
    UQSTR = 1,
    SQSTR = 2,
    DQSTR = 3,
    PLUS = 4,
    SCOLON = 5,
    LBRACE = 6,
    RBRACE = 7,
    new = function(typ, content, line, col)
        local t = {
            type = typ,
            content = content,
            line = line,
            col = col
        }
        return t
    end
}

local ts = {
    [m.UQSTR] = 'unquoted string', -- 1
    [m.SQSTR] = 'single quoted string', -- 2
    [m.DQSTR] = 'double quoted string', -- 3
    [m.PLUS] = '+', -- 4
    [m.SCOLON] = ';', -- 5
    [m.LBRACE] = '{', -- 6
    [m.RBRACE] = '}' -- 7
}

function m.typename(t)
    return ts[t]
end

return readonly(m)
