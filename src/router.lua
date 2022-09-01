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
    --[[ TODO:
    YANG grammar does not prevent the grouping-stmt and uses-stmt from nesting each other via uses-augment-stmt,
    but the "circular" nesting chain MUST be avoided, cause which would result in loop definition ]]
    local gcount = 0
    local ucount = 0
    local r = {}

    function r.grouping_enter(uid)
        r[#r + 1] = {'grouping@' .. uid, grouping = true, uid = uid}
        gcount = gcount + 1
    end

    function r.grouping_leave()
        local g = r[#r]
        assert(type(g) == 'table' and g.grouping and #g == 1)
        r[#r] = nil
        gcount = gcount - 1
    end

    function r.grouping()
        return gcount > 0
    end

    function r.uses_enter(uid)
        r[#r + 1] = {uses = true, uid = uid}
        ucount = ucount + 1
    end

    function r.uses_leave()
        local u = r[#r]
        assert(type(u) == 'table' and u.uses and #u == 0)
        r[#r] = nil
        ucount = ucount - 1
    end

    function r.uses()
        local cur = r[#r]
        return cur and cur.uses
    end

    function r.push(s)
        local top = r[#r]
        if top and type(top) == 'table' then
            top[#top + 1] = s
        else
            r[#r + 1] = s
        end
    end

    function r.pop()
        local top = r[#r]
        if top and type(top) == 'table' then
            local t = top[#top]
            top[#top] = nil
            return t
        else
            r[#r] = nil
            return top
        end
    end

    function r.concat()
        local s = {''}
        local depth = #r
        local top = r[depth]
        while top ~= nil do
            if top and type(top) == 'table' then
                for i = 1, #top do
                    table.insert(s, 2, top[#top - i + 1])
                end
                if top.grouping then
                    break
                end
            else
                table.insert(s, 2, top)
            end
            depth = depth - 1
            top = r[depth]
        end
        return table.concat(s, '/')
    end

    return r
end
