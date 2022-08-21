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

local token = require('token')

local _single_char_token = {
    [';'] = token.SCOLON,
    ['+'] = token.PLUS,
    ['{'] = token.LBRACE,
    ['}'] = token.RBRACE
}

return function(buf)
    local cur = nil
    local con = nil
    local line = 1
    local column = 0
    local buffer = buf
    local s = {
        next = function()
            if nil == cur then
                cur = 0
                return buffer.at(0)
            elseif cur >= buffer.len() then
                return nil
            end
            cur = cur + 1
            local n = buffer.at(cur)
            if '\r' == n then
                -- windows?
                cur = cur + 1
                n = buffer.at(cur)
            end
            if '\n' == n then
                column = 0
                line = line + 1
            end
            return n
        end,
        peek = function()
            if nil == cur then
                return buffer.at(0)
            elseif cur >= buffer.len() then
                return nil
            end
            return buffer.at(cur + 1)
        end,
        peek2 = function()
            if buffer.len() < 2 then
                return nil
            elseif nil == cur then
                return buffer.sub(0, 1)
            elseif cur + 2 >= buffer.len() then
                return nil
            end
            return buffer.sub(cur + 1, cur + 2)
        end,
        consume = function()
            con = cur
        end,
        make_string_token = function(t)
            return token.new(t, buffer.sub(con, cur), line, column)
        end,
        make_character_token = function(c)
            return token.new(_single_char_token[c], c, line, column)
        end
    }
    return s
end
