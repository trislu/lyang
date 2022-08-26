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

local node = require('node')
local stack = require('stack')

return function()
    local tree_array = {}
    local tree = stack()

    function tree_array:branch_begin(stmt, shorthand)
        local n = node.create(stmt)
        if shorthand then
            n.type = 'case'
        end
        self[#self + 1] = n
        tree.push(#self)
        return n
    end

    function tree_array:add_leave(stmt)
        local n = node.create(stmt)
        self[#self + 1] = n
    end

    function tree_array:branch_end(stmt_)
        local pos = tree.top()
        local branch = self[pos]
        branch.subs = #self - pos
    end

    return tree_array
end
