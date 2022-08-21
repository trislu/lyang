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

--[[python-like split() from http://lua-users.org/wiki/SplitJoin]]
function string:split(sSeparator, nMax, bRegexp) -- luacheck: ignore
    assert(sSeparator ~= '')
    assert(nMax == nil or nMax >= 1)

    local aRecord = {}

    if self:len() > 0 then
        local bPlain = not bRegexp
        nMax = nMax or -1

        local nField, nStart = 1, 1
        local nFirst, nLast = self:find(sSeparator, nStart, bPlain)
        while nFirst and nMax ~= 0 do
            aRecord[nField] = self:sub(nStart, nFirst - 1)
            nField = nField + 1
            nStart = nLast + 1
            nFirst, nLast = self:find(sSeparator, nStart, bPlain)
            nMax = nMax - 1
        end
        aRecord[nField] = self:sub(nStart)
    end

    return aRecord
end

local m = {}

function m.escape(s)
    local e = s
    e = e:gsub('&', '&amp;')
    e = e:gsub('>', '&gt;')
    e = e:gsub('<', '&lt;')
    return e
end

function m.quotedattr(s)
    local q = m.escape(s)
    if q:find('"') then
        if q:find("'") then
            q = q:gsub('"', '&quot;')
            q = '"' .. q .. '"'
        else
            q = "'" .. q .. "'"
        end
    else
        q = '"' .. q .. '"'
    end
    return q
end

function m.decouple_nodeid(id)
    local s = id:split(':')
    if 1 == #s then
        return true, nil, id
    elseif 2 == #s then
        if #(s[1]) > 0 then
            return true, s[1], s[2]
        end
    end
    return false
end

local CRLF = {
    ['\r'] = 1,
    ['\n'] = 1
}

local SEP = {
    [' '] = 1,
    ['\t'] = 1,
    ['\v'] = 1,
    ['\f'] = 1
}

function m.tokenize_feature_expr(exp)
    local buf = {}
    for i = 1, string.len(exp) do
        table.insert(buf, string.sub(exp, i, i))
    end
    -- trick : add " " as EOF
    buf[#buf + 1] = ' '
    local consume = 0
    local tokens = {}
    local state = nil
    for j = 1, #buf do
        if '(' == buf[j] or ')' == buf[j] then
            if 'str' == state then
                local str = table.concat(buf, nil, consume, j - 1)
                tokens[#tokens + 1] = str
            end
            tokens[#tokens + 1] = buf[j]
            consume = j
            state = nil
        elseif SEP[buf[j]] or CRLF[buf[j]] then
            if 'str' == state then
                local str = table.concat(buf, nil, consume, j - 1)
                tokens[#tokens + 1] = str
            end
            consume = j
            state = nil
        else
            if nil == state then
                state = 'str'
                consume = j
            end
        end
    end
    return tokens
end

function m.is_postive_integer(str)
    return str == str:match('[1-9]%d*')
end

return m
