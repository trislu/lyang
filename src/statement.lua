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

local syntax = require('syntax')

CUSTOM_STMT = nil

return function(keyword)
    if CUSTOM_STMT then
        --[[
        NOTICE:
            The statement objects may consume a considerable amount of memory
        due to the complexity of the parsing yang modules.
            If the lyang is expected to run on an embedded system, substitutes
        with a C version 'statement' via luajit FFI could be an option.
        ]]
        return CUSTOM_STMT
    end
    local substmts = {}
    local stmt = {
        keyword = keyword,
        argument = nil,
        parent = nil,
        position = {
            line = nil,
            col = nil
        },
        append_substmt = function(sub)
            substmts[#substmts + 1] = sub
        end,
        substmt = function(id)
            -- zero based for C friendly?
            return substmts[id]
        end,
        substmt_count = function()
            return #substmts
        end,
        find_child = function(k, expect)
            for i = 1, #substmts do
                if substmts[i].keyword == k then
                    if expect then
                        if expect(substmts[i]) then
                            return substmts[i]
                        end
                    else
                        return substmts[i]
                    end
                end
            end
        end,
        syntax = syntax(keyword)
    }
    return stmt
end
