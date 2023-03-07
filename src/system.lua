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

local package = package
local error = error
local tostring = tostring
local io = io
local os = os
local readonly = require('readonly')

local _ENV = {}
if setfenv then
    setfenv(1, _ENV)
end

local _type = nil

local _WIN = 1
local _UNIX = 2

local _sep = package.config:sub(1, 1)
if '\\' == _sep then
    _type = _WIN
elseif '/' == _sep then
    _type = _UNIX
else
    -- statements
    error('[system] unknown sep character = ' .. tostring(_sep))
end

return readonly {
    WINDOWS = _WIN,
    UNIX = _UNIX,
    type = function()
        return _type
    end,
    sep = function()
        return _sep
    end,
    dir = function(path)
        if lfs then
            -- in case lfs was installed
            return lfs.dir(path)
        end
        local cmd = nil
        if _WIN == _type then
            cmd = ('dir %s /b /A-D'):format(path:gsub('/', '\\'))
        elseif _UNIX == _type then
            cmd = ("find '%s' -mindepth 1 -maxdepth 1 -type f -print"):format(path)
        else
            error('[system] unknown system type =' .. tostring(_type))
        end
        --check https://www.lua.org/manual/5.1/manual.html#pdf-io.popen
        local pret = io.popen(cmd, 'r')
        local f = {}
        for l in pret:lines() do
            f[#f + 1] = l
        end
        local i = 0
        return function()
            i = i + 1
            if i <= #f then
                return f[i]
            end
        end
    end,
    path = {
        basename = function(url)
            return url:match('[^' .. _sep .. ']-$')
        end,
        splitext = function(url)
            return {url:match('[^' .. _sep .. ']-$'):match('[^.]+'), url:match('%.[^.' .. _sep .. ']+$')}
        end
    },
    move = function(oldname, newname)
        assert(oldname and newname)
        return os.execute(('mv %s %s'):format(oldname, newname))
    end
}
