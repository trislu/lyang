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

local symbol_table = {}

local function common_data_node_pass(stmt, mod, ctx)
    local meta = ctx.modules.get_meta(mod.argument)
    local router = meta.router
    if stmt.parent.keyword == 'module' then
        router.push(mod.argument .. ':' .. stmt.argument)
    elseif stmt.parent.keyword == 'submodule' then
        local belongsto = mod.find_child('belongs-to')
        router.push(belongsto.argument .. ':' .. stmt.argument)
    else
        router.push(stmt.argument)
    end
    -- store the node with its symbol
    symbol_table[table.concat(router, '/')] = node(stmt)
end

local shorthand_stmts = {
    --[[ https://www.rfc-editor.org/rfc/rfc7950.html#section-7.9.2
    As a shorthand, the "case" statement can be omitted if the branch
contains a single "anydata", "anyxml", "choice", "container", "leaf",
"list", or "leaf-list" statement.  In this case, the case node still
exists in the schema tree, and its identifier is the same as the
identifier of the child node.  Schema node identifiers (Section 6.5)
MUST always explicitly include case node identifiers. ]]
    anydata = 1,
    anyxml = 1,
    choice = 1,
    container = 1,
    leaf = 1,
    list = 1,
    ['leaf-list'] = 1
}

local function short_hand_case_pass(stmt, mod, ctx)
    if stmt.parent.keyword == 'choice' then
        if shorthand_stmts[stmt.keyword] then
            local meta = ctx.modules.get_meta(mod.argument)
            local router = meta.router
            router.push(stmt.argument)
            -- create shorthand case
            local n = node(stmt)
            n.keyword = 'case'
            symbol_table[table.concat(router, '/')] = n
        end
    end
end

local syntactic_pass = {
    action = {
        common_data_node_pass
    },
    anydata = {
        short_hand_case_pass,
        common_data_node_pass
    },
    anyxml = {
        short_hand_case_pass,
        common_data_node_pass
    },
    argument = {},
    augment = {
        function(stmt, mod, ctx)
            local argument = stmt.argument
            if 'uses' == stmt.parent.keyword then
                -- 'uses-augment-stmt'
                local meta = ctx.modules.get_meta(mod.argument)
                local router = meta.router
                router.push('a@' .. stmt.argument)
            else
                -- 'augment-stmt'
            end
        end
    },
    base = {},
    ['belongs-to'] = {},
    bit = {},
    case = {
        common_data_node_pass
    },
    choice = {
        short_hand_case_pass,
        common_data_node_pass
    },
    config = {},
    contact = {},
    container = {
        short_hand_case_pass,
        common_data_node_pass
    },
    default = {},
    description = {},
    deviate = {},
    deviation = {},
    enum = {},
    ['error-app-tag'] = {},
    ['error-message'] = {},
    extension = {},
    feature = {},
    ['fraction-digits'] = {},
    grouping = {},
    identity = {},
    ['if-feature'] = {},
    import = {},
    include = {},
    input = {},
    key = {},
    leaf = {
        short_hand_case_pass,
        common_data_node_pass
    },
    ['leaf-list'] = {
        short_hand_case_pass,
        common_data_node_pass
    },
    length = {},
    list = {
        short_hand_case_pass,
        common_data_node_pass
    },
    mandatory = {},
    ['max-elements'] = {},
    ['min-elements'] = {},
    modifier = {},
    module = {},
    must = {},
    namespace = {},
    notification = {},
    ['ordered-by'] = {},
    organization = {},
    output = {},
    path = {},
    pattern = {},
    position = {},
    prefix = {},
    presence = {},
    range = {},
    reference = {},
    refine = {},
    ['require-instance'] = {},
    revision = {},
    ['revision-date'] = {},
    rpc = {},
    status = {},
    submodule = {},
    type = {},
    typedef = {},
    unique = {},
    units = {},
    uses = {},
    value = {},
    when = {},
    ['yang-version'] = {},
    ['yin-element'] = {}
}

local semantic_pass = {}

return {
    syntactic_passes = function()
        return syntactic_pass
    end,
    semantic_passes = function()
        return semantic_pass
    end,
    search_node = function(symbol)
        return symbol_table[symbol]
    end,
    insert_node = function(s, n)
        local conflict = symbol_table[s]
        if conflict then
            error(
                ('[internal] duplicated insert node "%s" with symbol "%s", previous is "%s"'):format(
                    n.type .. ':' .. n.name,
                    s,
                    conflict.type .. ':' .. conflict.name
                )
            )
        end
        symbol_table[s] = n
    end
}
