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

return function()
    --[[ YANG grammar does not prevent the grouping-stmt and uses-stmt from nesting each other via uses-augment-stmt,
    but the "circular" nesting chain MUST be avoided, cause which would result in loop definition ]]
    local gcount = 0
    local ucount = 0
    local r = {}

    function r.grouping_enter(uid)
        r[#r+1] = {grouping = true, uid = uid}
        gcount = gcount + 1
    end

    function r.grouping_leave()
        local g = r[#r]

        r[#r] = nil
        gcount = gcount - 1
    end

    function r.grouping()
        return gcount > 0
    end

    function r.uses_enter()
        r[#r + 1] = { uses = true }
        ucount = ucount + 1
    end

    function r.uses_leave()
        r[#r] = nil
        ucount = ucount - 1
    end

    function r.uses()
        local cur = r[#r]
        return cur.uses
    end

    function r.push(s)
        if nested.size() > 0 then
            local g = nested.top()
            g.push(s)
        else
            r[#r + 1] = s
        end
    end

    function r.pop()
        if gstack.size() > 0 then
            local g = gstack.top()
            return g.pop()
        end
        local s = r[#r]
        r[#r] = nil
        return s
    end

    return r
end
