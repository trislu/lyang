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

--\[0-9].*1..n[ ]+\
--\[0-9].*0..n[ ]+\
--\[0-9].*0..1[ ]+\

local substmt_syntax = {
    module = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            augment = {'*'},
            choice = {'*'},
            contact = {'?'},
            container = {'*'},
            description = {'?'},
            deviation = {'*'},
            extension = {'*'},
            feature = {'*'},
            grouping = {'*'},
            identity = {'*'},
            import = {'*'},
            include = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            namespace = {1},
            notification = {'*'},
            organization = {'?'},
            prefix = {1},
            reference = {'?'},
            revision = {'*'},
            rpc = {'*'},
            typedef = {'*'},
            uses = {'*'},
            ['yang-version'] = {1}
        }
    end,
    import = function()
        return {
            description = {'?'},
            prefix = {1},
            reference = {'?'},
            ['revision-date'] = {'?'}
        }
    end,
    include = function()
        return {
            description = {'?'},
            reference = {'?'},
            ['revision-date'] = {'?'}
        }
    end,
    revision = function()
        return {
            description = {'?'},
            reference = {'?'}
        }
    end,
    submodule = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            augment = {'*'},
            ['belongs-to'] = {1},
            choice = {'*'},
            contact = {'?'},
            container = {'*'},
            description = {'?'},
            deviation = {'*'},
            extension = {'*'},
            feature = {'*'},
            grouping = {'*'},
            identity = {'*'},
            import = {'*'},
            include = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            notification = {'*'},
            organization = {'?'},
            reference = {'?'},
            revision = {'*'},
            rpc = {'*'},
            typedef = {'*'},
            uses = {'*'},
            ['yang-version'] = {1}
        }
    end,
    ['belongs-to'] = function()
        return {
            prefix = {1}
        }
    end,
    typedef = function()
        return {
            default = {'?'},
            description = {'?'},
            reference = {'?'},
            status = {'?'},
            type = {1},
            units = {'?'}
        }
    end,
    type = function()
        return {
            base = {'*'},
            bit = {'*'},
            enum = {'*'},
            ['fraction-digits'] = {'?'},
            length = {'?'},
            path = {'?'},
            pattern = {'*'},
            range = {'?'},
            ['require-instance'] = {'?'},
            type = {'*'}
        }
    end,
    container = function()
        return {
            action = {'*'},
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            config = {'?'},
            container = {'*'},
            description = {'?'},
            grouping = {'*'},
            ['if-feature'] = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            must = {'*'},
            notification = {'*'},
            presence = {'?'},
            reference = {'?'},
            status = {'?'},
            typedef = {'*'},
            uses = {'*'},
            when = {'?'}
        }
    end,
    must = function()
        return {
            description = {'?'},
            ['error-app-tag'] = {'?'},
            ['error-message'] = {'?'},
            reference = {'?'}
        }
    end,
    leaf = function()
        return {
            config = {'?'},
            default = {'?'},
            description = {'?'},
            ['if-feature'] = {'*'},
            mandatory = {'?'},
            must = {'*'},
            reference = {'?'},
            status = {'?'},
            type = {1},
            units = {'?'},
            when = {'?'}
        }
    end,
    ['leaf-list'] = function()
        return {
            config = {'?'},
            default = {'*'},
            description = {'?'},
            ['if-feature'] = {'*'},
            ['max-elements'] = {'?'},
            ['min-elements'] = {'?'},
            must = {'*'},
            ['ordered-by'] = {'?'},
            reference = {'?'},
            status = {'?'},
            type = {1},
            units = {'?'},
            when = {'?'}
        }
    end,
    list = function()
        return {
            action = {'*'},
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            config = {'?'},
            container = {'*'},
            description = {'?'},
            grouping = {'*'},
            ['if-feature'] = {'*'},
            key = {'?'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            ['max-elements'] = {'?'},
            ['min-elements'] = {'?'},
            must = {'*'},
            notification = {'*'},
            ['ordered-by'] = {'?'},
            reference = {'?'},
            status = {'?'},
            typedef = {'*'},
            unique = {'*'},
            uses = {'*'},
            when = {'?'}
        }
    end,
    choice = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            case = {'*'},
            choice = {'*'},
            config = {'?'},
            container = {'*'},
            default = {'?'},
            description = {'?'},
            ['if-feature'] = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            mandatory = {'?'},
            reference = {'?'},
            status = {'?'},
            when = {'?'}
        }
    end,
    case = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            container = {'*'},
            description = {'?'},
            ['if-feature'] = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            reference = {'?'},
            status = {'?'},
            uses = {'*'},
            when = {'?'}
        }
    end,
    anydata = function()
        return {
            config = {'?'},
            description = {'?'},
            ['if-feature'] = {'*'},
            mandatory = {'?'},
            must = {'*'},
            reference = {'?'},
            status = {'?'},
            when = {'?'}
        }
    end,
    anyxml = function()
        return {
            config = {'?'},
            description = {'?'},
            ['if-feature'] = {'*'},
            mandatory = {'?'},
            must = {'*'},
            reference = {'?'},
            status = {'?'},
            when = {'?'}
        }
    end,
    grouping = function()
        return {
            action = {'*'},
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            container = {'*'},
            description = {'?'},
            grouping = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            notification = {'*'},
            reference = {'?'},
            status = {'?'},
            typedef = {'*'},
            uses = {'*'}
        }
    end,
    uses = function()
        return {
            augment = {'*'},
            description = {'?'},
            ['if-feature'] = {'*'},
            reference = {'?'},
            refine = {'*'},
            status = {'?'},
            when = {'?'}
        }
    end,
    rpc = function()
        return {
            description = {'?'},
            grouping = {'*'},
            ['if-feature'] = {'*'},
            input = {'?'},
            output = {'?'},
            reference = {'?'},
            status = {'?'},
            typedef = {'*'}
        }
    end,
    input = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            container = {'*'},
            grouping = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            must = {'*'},
            typedef = {'*'},
            uses = {'*'}
        }
    end,
    output = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            container = {'*'},
            grouping = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            must = {'*'},
            typedef = {'*'},
            uses = {'*'}
        }
    end,
    action = function()
        return {
            description = {'?'},
            grouping = {'*'},
            ['if-feature'] = {'*'},
            input = {'?'},
            output = {'?'},
            reference = {'?'},
            status = {'?'},
            typedef = {'*'}
        }
    end,
    notification = function()
        return {
            anydata = {'*'},
            anyxml = {'*'},
            choice = {'*'},
            container = {'*'},
            description = {'?'},
            grouping = {'*'},
            ['if-feature'] = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            must = {'*'},
            reference = {'?'},
            status = {'?'},
            typedef = {'*'},
            uses = {'*'}
        }
    end,
    augment = function()
        return {
            action = {'*'},
            anydata = {'*'},
            anyxml = {'*'},
            case = {'*'},
            choice = {'*'},
            container = {'*'},
            description = {'?'},
            ['if-feature'] = {'*'},
            leaf = {'*'},
            ['leaf-list'] = {'*'},
            list = {'*'},
            notification = {'*'},
            reference = {'?'},
            status = {'?'},
            uses = {'*'},
            when = {'?'}
        }
    end,
    identity = function()
        return {
            base = {'*'},
            description = {'?'},
            ['if-feature'] = {'*'},
            reference = {'?'},
            status = {'?'}
        }
    end,
    extension = function()
        return {
            argument = {'?'},
            description = {'?'},
            reference = {'?'},
            status = {'?'}
        }
    end,
    argument = function()
        return {
            ['yin-element'] = {'?'}
        }
    end,
    feature = function()
        return {
            description = {'?'},
            ['if-feature'] = {'*'},
            reference = {'?'},
            status = {'?'}
        }
    end,
    deviation = function()
        return {
            description = {'?'},
            deviate = {'+'},
            reference = {'?'}
        }
    end,
    deviate = function()
        return {
            config = {'?'},
            default = {'*'},
            mandatory = {'?'},
            ['max-elements'] = {'?'},
            ['min-elements'] = {'?'},
            must = {'*'},
            type = {'?'},
            unique = {'*'},
            units = {'?'}
        }
    end,
    range = function()
        return {
            description = {'?'},
            ['error-app-tag'] = {'?'},
            ['error-message'] = {'?'},
            reference = {'?'}
        }
    end,
    length = function()
        return {
            description = {'?'},
            ['error-app-tag'] = {'?'},
            ['error-message'] = {'?'},
            reference = {'?'}
        }
    end,
    pattern = function()
        return {
            description = {'?'},
            ['error-app-tag'] = {'?'},
            ['error-message'] = {'?'},
            modifier = {'?'},
            reference = {'?'}
        }
    end,
    enum = function()
        return {
            description = {'?'},
            ['if-feature'] = {'*'},
            reference = {'?'},
            status = {'?'},
            value = {'?'}
        }
    end,
    bit = function()
        return {
            description = {'?'},
            ['if-feature'] = {'*'},
            position = {'?'},
            reference = {'?'},
            status = {'?'}
        }
    end,
    when = function()
        return {
            description = {'?'},
            reference = {'?'}
        }
    end,
    refine = function()
        return {
            ['if-feature'] = {'*'},
            must = {'*'},
            presence = {'?'},
            default = {'*'},
            config = {'?'},
            mandatory = {'?'},
            ['max-elements'] = {'?'},
            ['min-elements'] = {'?'},
            description = {'?'},
            reference = {'?'}
        }
    end,
}

local yinstmt_syntax = {
    action = {'name', false},
    anydata = {'name', false},
    anyxml = {'name', false},
    argument = {'name', false},
    augment = {'target-node', false},
    base = {'name', false},
    ['belongs-to'] = {'module', false},
    bit = {'name', false},
    case = {'name', false},
    choice = {'name', false},
    config = {'value', false},
    contact = {'text', true},
    container = {'name', false},
    default = {'value', false},
    description = {'text', true},
    deviate = {'value', false},
    deviation = {'target-node', false},
    enum = {'name', false},
    ['error-app-tag'] = {'value', false},
    ['error-message'] = {'value', true},
    extension = {'name', false},
    feature = {'name', false},
    ['fraction-digits'] = {'value', false},
    grouping = {'name', false},
    identity = {'name', false},
    ['if-feature'] = {'name', false},
    import = {'module', false},
    include = {'module', false},
    input = {nil, nil},
    key = {'value', false},
    leaf = {'name', false},
    ['leaf-list'] = {'name', false},
    length = {'value', false},
    list = {'name', false},
    mandatory = {'value', false},
    ['max-elements'] = {'value', false},
    ['min-elements'] = {'value', false},
    modifier = {'value', false},
    module = {'name', false},
    must = {'condition', false},
    namespace = {'uri', false},
    notification = {'name', false},
    ['ordered-by'] = {'value', false},
    organization = {'text', true},
    output = {nil, nil},
    path = {'value', false},
    pattern = {'value', false},
    position = {'value', false},
    prefix = {'value', false},
    presence = {'value', false},
    range = {'value', false},
    reference = {'text', true},
    refine = {'target-node', false},
    ['require-instance'] = {'value', false},
    revision = {'date', false},
    ['revision-date'] = {'date', false},
    rpc = {'name', false},
    status = {'value', false},
    submodule = {'name', false},
    type = {'name', false},
    typedef = {'name', false},
    unique = {'tag', false},
    units = {'name', false},
    uses = {'name', false},
    value = {'value', false},
    when = {'condition', false},
    ['yang-version'] = {'value', false},
    ['yin-element'] = {'value', false}
}

return function(stmt)
    if nil == yinstmt_syntax[stmt] then
        return nil
    end
    local s = stmt
    local vmap = nil
    if substmt_syntax[s] then
        vmap = substmt_syntax[s]()
    end
    local lasterr = nil
    return {
        arg = function()
            return yinstmt_syntax[s][1]
        end,
        yinarg = function()
            return unpack(yinstmt_syntax[s])
        end,
        meet = function(substmt)
            if nil == vmap then
                lasterr = 'not allowed to define substatements for "' .. s .. '"'
                return false
            elseif nil == vmap[substmt] then
                lasterr = '"' .. substmt .. '" is not a valid substatement of "' .. s .. '"'
                return false
            else
                if '?' == vmap[substmt][1] then
                    if vmap[substmt][2] then
                        lasterr = '"' .. s .. '" can only contain one "' .. substmt .. '" substatement'
                        return false
                    else
                        vmap[substmt][2] = 1
                    end
                elseif 1 == vmap[substmt][1] then
                    if vmap[substmt][2] then
                        lasterr = '"' .. s .. '" can only contain one "' .. substmt .. '" substatement'
                        return false
                    else
                        vmap[substmt][2] = 1
                    end
                end
            end
            return true
        end,
        valid = function()
            if lasterr then
                -- there exists errors already
                return false
            end
            if vmap then
                for ss, rec in pairs(vmap) do
                    if 1 == rec[1] then
                        if nil == rec[2] then
                            lasterr = '"' .. s .. '" requires one "' .. ss .. '" substatement but there is none'
                            return false
                        end
                    elseif '+' == rec[1] then
                        if nil == rec[2] then
                            lasterr = '"' .. s .. '" requires one or more "' .. ss .. '" substatement but there is none'
                            return false
                        end
                    end
                end
            end
            return true
        end,
        lasterr = function()
            return lasterr
        end
    }
end
