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
assert(
    ...,
    [[this is a require only module, don't use it as the main
usage:
    local ro = require('readonly')
    local foo = ro({bar='ok'})
    -- user can read foo.bar
    print(foo.bar) -- print 'ok'
    -- user can't write foo.bar
    foo.bar = 'not ok' -- error raised
]]
)

-- sandboxing
local error = error
local getmetatable = getmetatable
local pairs = pairs
local setmetatable = setmetatable
local tostring = tostring
local type = type

local _ENV = {}
if setfenv then
    setfenv(1, _ENV)
end

local origin = setmetatable({}, {__mode = 'k', __metatable = 'original table records'})

--[[https://lua-users.org/wiki/MetatableEvents]]
local ro = {
    __metatable = 'readonly',
    __call = function(t)
        error('do not attempt to call readonly table ' .. tostring(origin[t]), 2)
    end,
    __index = function(t, k)
        return origin[t][k]
    end,
    __newindex = function(t, k, v)
        local errmsg = 'do not attempt to modify readonly table "' .. tostring(origin[t]) .. '".\tfield: '
        if type(k) == 'string' then
            errmsg = errmsg .. '["%s"] = %s'
        else
            errmsg = errmsg .. '[%s] = %s'
        end
        error(errmsg:format(tostring(k), tostring(v)), 2)
    end
}

--[[https://lua-users.org/wiki/RecursiveReadOnlyTables]]
local function make_ro(t)
    local mt = getmetatable(t)
    if nil ~= mt then
        error('do not attempt to make a readonly table readonly again')
        return t
    end
    -- recursive
    for k, v in pairs(t) do
        if type(v) == 'table' then
            t[k] = make_ro(v)
        end
    end
    local ro_t = {}
    origin[ro_t] = t
    return setmetatable(ro_t, ro)
end

return function(t)
    return make_ro(t)
end
