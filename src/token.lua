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
local ts = {
    'unquoted string', -- 1
    'single quoted string', -- 2
    'double quoted string', -- 3
    '+', -- 4
    ';', -- 5
    '{', -- 6
    '}' -- 7
}

TK_UQSTR = 1
TK_SQSTR = 2
TK_DQSTR = 3
TK_PLUS = 4
TK_SCOLON = 5
TK_LBRACE = 6
TK_RBRACE = 7

return {
    new = function(typ, content, line, col)
        local t = {
            type = typ,
            content = content,
            line = line,
            col = col
        }
        return t
    end,
    typename = function(t)
        return ts[t]
    end
}
