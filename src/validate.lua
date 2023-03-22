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

local utils = require('utils')

local feature_rsv_tokens = {
    ['('] = 1,
    [')'] = 1,
    ['and'] = 1,
    ['or'] = 1,
    ['not'] = 1
}

local syntactic_pass = {
    action = {},
    anydata = {},
    anyxml = {},
    argument = {},
    augment = {
        function(stmt, mod, ctx, source)
            local argument = stmt.argument
            local errmsg = nil
            local start_char = argument:sub(1, 1)
            if 'uses' == stmt.parent.keyword then
                -- 'uses-augment-stmt'
                if '/' == start_char then
                    errmsg = 'argument of the uses-augment statement must be a "descendant-schema-nodeid"'
                else
                    local slice = argument:split('/')
                    for i = 1, #slice do
                        local ok, prefix, _ = utils.decouple_nodeid(slice[i])
                        if not ok then
                            errmsg = ('invalid argument descendant-schema-nodeid[%d]"%s"'):format(i - 1, slice[i])
                            break
                        end
                        local meta = ctx.modules.get_meta(mod.argument)
                        if prefix and nil == meta.prefixes[prefix] then
                            errmsg =
                                ('undefined prefix "%s" in descendant-schema-nodeid[%d]"%s"'):format(
                                prefix,
                                i - 1,
                                slice[i]
                            )
                            break
                        end
                    end
                end
            else
                -- 'augment-stmt'
                if '/' ~= start_char then
                    errmsg = 'argument of the augment statement must be an "absolute-schema-nodeid"'
                else
                    local slice = argument:split('/')
                    -- "" == slice[1]
                    for i = 2, #slice do
                        local ok, prefix, _ = utils.decouple_nodeid(slice[i])
                        if not ok then
                            errmsg = ('invalid argument absolute-schema-nodeid[%d]"%s"'):format(i - 1, slice[i])
                            break
                        end
                        local meta = ctx.modules.get_meta(mod.argument)
                        if prefix and nil == meta.prefixes[prefix] then
                            errmsg =
                                ('undefined prefix "%s" in absolute-schema-nodeid[%d]"%s"'):format(
                                prefix,
                                i - 1,
                                slice[i]
                            )
                            break
                        end
                    end
                end
            end
            if errmsg then
                error(source .. ':' .. stmt.position.line .. ':' .. stmt.position.col .. ': ' .. errmsg)
            end
        end
    },
    base = {},
    ['belongs-to'] = {},
    bit = {},
    case = {},
    choice = {},
    config = {},
    contact = {},
    container = {},
    default = {},
    description = {},
    deviate = {},
    deviation = {},
    enum = {},
    ['error-app-tag'] = {},
    ['error-message'] = {},
    extension = {
        function(stmt, mod, ctx, source)
            -- module's meta info
            local meta = ctx.modules.get_meta(mod.argument)
            -- update 'extensions' field
            local previous = meta.extensions[stmt.argument]
            if previous then
                -- extension redefinition
                error(
                    ('%s:%d:%d: extension "%s" conflict, previously defined in :%d:%d'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument,
                        previous.position.line,
                        previous.position.line
                    )
                )
            end
            -- record extension stmt
            meta.extensions[stmt.argument] = stmt
            meta.extensions[#meta.extensions + 1] = stmt
        end
    },
    feature = {},
    ['fraction-digits'] = {},
    grouping = {},
    identity = {},
    ['if-feature'] = {
        function(stmt, mod, ctx, source)
            local tokens = utils.tokenize_feature_expr(stmt.argument)
            for _, tk in ipairs(tokens) do
                -- not a reserve token
                if not feature_rsv_tokens[tk] then
                    local ok, prefix, _ = utils.decouple_nodeid(tk)
                    if not ok then
                        error(
                            ('%s:%d:%d: invalid if-feature argument "%s"'):format(
                                source,
                                stmt.position.line,
                                stmt.position.col,
                                stmt.argument
                            )
                        )
                    end
                    local meta = ctx.modules.get_meta(mod.argument)
                    if prefix and nil == meta.prefixes[prefix] then
                        error(
                            ('%s:%d:%d: undefined prefix "%s" in if-feature argument "%s"'):format(
                                source,
                                stmt.position.line,
                                stmt.position.col,
                                prefix,
                                stmt.argument
                            )
                        )
                    end
                end
            end
        end
    },
    import = {
        function(stmt, mod, ctx, source)
            -- module's meta info
            local meta = ctx.modules.get_meta(mod.argument)
            -- check 'imports' field
            local previous = meta.imports[stmt.argument]
            if previous then
                -- import conflict
                error(
                    ('%s:%d:%d: import "%s" conflict, previously defined in :%d:%d'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument,
                        previous.position.line,
                        previous.position.line
                    )
                )
            end
            -- record import stmt
            meta.imports[stmt.argument] = stmt
        end
    },
    include = {
        function(stmt, mod, ctx, source)
            -- module's meta info
            local meta = ctx.modules.get_meta(mod.argument)
            -- check 'includes' field
            local previous = meta.includes[stmt.argument]
            if previous then
                -- include conflict
                error(
                    ('%s:%d:%d: include "%s" conflict, previously defined in :%d:%d'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument,
                        previous.position.line,
                        previous.position.line
                    )
                )
            end
            -- record include stmt
            meta.includes[stmt.argument] = stmt
        end
    },
    input = {},
    key = {},
    leaf = {},
    ['leaf-list'] = {},
    length = {},
    list = {},
    mandatory = {},
    ['max-elements'] = {
        function(stmt, mod_, ctx_, source)
            if not utils.is_postive_integer(stmt.argument) and 'unbounded' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "max-elements", must be positive integer or "unbounded"'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    ['min-elements'] = {
        function(stmt, mod_, ctx_, source)
            if not utils.is_postive_integer(stmt.argument) and '0' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "min-elements", must be none negative integer'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    modifier = {},
    module = {
        function(stmt, mod, ctx, source)
            -- check conflict
            local conflict = ctx.modules.get_source(mod.argument)
            if conflict then
                error(
                    ('%s:%d:%d: %s name "%s" conflicts, previously defined in %s'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        mod.keyword,
                        mod.argument,
                        conflict
                    )
                )
            end
            -- create meta fields
            local meta = {
                imports = {},
                prefixes = {},
                includes = {},
                extensions = {}
            }
            -- add to modules
            ctx.modules.add(mod, source, meta)
        end
    },
    must = {},
    namespace = {
        function(stmt, mod_, ctx, source)
            local conflict = ctx.modules.get_namespace(stmt.argument)
            if conflict then
                local previous = conflict[2]
                error(
                    ('%s:%d:%d: conflict %s "%s", previously defined in %s'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.keyword,
                        stmt.argument,
                        previous
                    )
                )
            end
            -- add to modules
            ctx.modules.add_namespace(stmt, source)
        end
    },
    notification = {},
    ['ordered-by'] = {
        function(stmt, mod_, ctx_, source)
            if 'user' ~= stmt.argument and 'system' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "ordered-by", must be "user" or "system"'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    organization = {},
    output = {},
    path = {
        function(stmt, mod, ctx, source)
            local argument = stmt.argument
            -- todo: implement an xpath tokenizer
            --[[
            local slice = argument:split('/')
            local errmsg = nil
            for i = 1, #slice do
                local nodeid = slice[i]
                if '' ~= nodeid and '.' ~= nodeid and '..' ~= nodeid then
                    local ok, prefix, _ = utils.decouple_nodeid(slice[i])
                    if not ok then
                        errmsg = ('invalid argument of path[%d]"%s"'):format(i - 1, slice[i])
                        break
                    end
                    local meta = ctx.modules.get_meta(mod.argument)
                    if prefix and nil == meta.prefixes[prefix] then
                        errmsg = ('undefined prefix "%s" in path[%d]"%s"'):format(prefix, i - 1, slice[i])
                        break
                    end
                end
            end
            if errmsg then
                error(('%s:%d:%d: %s'):format(source, stmt.position.line, stmt.position.col, errmsg))
            end
            ]]
        end
    },
    pattern = {},
    position = {
        function(stmt, mod_, ctx_, source)
            if not utils.is_postive_integer(stmt.argument) and '0' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "position", must be none negative integer'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    prefix = {
        function(stmt, mod, ctx, source)
            -- module's meta info
            local meta = ctx.modules.get_meta(mod.argument)
            -- update 'prefixes' field
            if nil == meta.prefixes then
                meta.prefixes = {}
            end
            if meta.prefixes[stmt.argument] then
                -- prefix conflict
                local previous = meta.prefixes[stmt.argument]
                error(
                    ('%s:%d:%d: prefix "%s" conflict, previously defined in :%d:%d'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument,
                        previous.position.line,
                        previous.position.line
                    )
                )
            end
            -- record prefix stmt
            meta.prefixes[stmt.argument] = stmt
        end
    },
    presence = {},
    range = {},
    reference = {},
    refine = {
        function(stmt, mod, ctx, source)
            local argument = stmt.argument
            local start_char = argument:sub(1,1)
            local errmsg = nil
            -- 'uses-augment-stmt'
            if '/' == start_char then
                errmsg = 'argument of the uses-augment statement must be a "descendant-schema-nodeid"'
            else
                local slice = argument:split('/')
                -- "" == slice[1]
                for i = 1, #slice do
                    local ok, prefix, _ = utils.decouple_nodeid(slice[i])
                    if not ok then
                        errmsg = ('invalid argument descendant-schema-nodeid[%d]"%s"'):format(i - 1, slice[i])
                        break
                    end
                    local meta = ctx.modules.get_meta(mod.argument)
                    if prefix and nil == meta.prefixes[prefix] then
                        errmsg =
                            ('undefined prefix "%s" in descendant-schema-nodeid[%d]"%s"'):format(
                            prefix,
                            i - 1,
                            slice[i]
                        )
                        break
                    end
                end
            end
            if errmsg then
                error(('%s:%d:%d: %s'):format(source, stmt.position.line, stmt.position.col, errmsg))
            end
        end
    },
    ['require-instance'] = {
        function(stmt, mod_, ctx_, source)
            if 'true' ~= stmt.argument and 'false' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "require-instance", must be "true" or "false"'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    revision = {},
    ['revision-date'] = {},
    rpc = {},
    status = {
        function(stmt, mod_, ctx_, source)
            --[[ status-arg = current-keyword /
                              obsolete-keyword /
                              deprecated-keyword ]]
            if 'current' ~= stmt.argument and 'obsolete' ~= stmt.argument and 'deprecated' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "status", must be "current", "obsolete" or "deprecated"'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    submodule = {
        function(stmt, mod, ctx, source)
            -- check conflict
            local conflict = ctx.modules.get_source(mod.argument)
            if conflict then
                error(
                    ('%s:%d:%d: %s name "%s" conflicts, previously defined in %s'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        mod.keyword,
                        mod.argument,
                        conflict
                    )
                )
            end
            -- create meta fields
            local meta = {
                imports = {},
                prefixes = {},
                includes = {},
                extensions = {}
            }
            -- add to modules
            ctx.modules.add(mod, source, meta)
        end
    },
    type = {},
    typedef = {},
    unique = {},
    units = {},
    uses = {},
    value = {},
    when = {},
    ['yang-version'] = {
        function(stmt, mod_, ctx_, source)
            --[[yang-version-stmt    = yang-version-keyword sep yang-version-arg-str
                                       stmtend
                yang-version-arg-str = < a string that matches the rule >
                                       < yang-version-arg >
                yang-version-arg     = "1.1" ]]
            if '1.1' ~= stmt.argument then
                error(
                    ('%s:%d:%d: invalid argument of "yang-version", must be "1.1"'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col
                    )
                )
            end
        end
    },
    ['yin-element'] = {}
}

local semantic_pass = {
    action = {},
    anydata = {},
    anyxml = {},
    argument = {},
    augment = {},
    base = {},
    ['belongs-to'] = {
        function(stmt, mod_, ctx, source)
            if nil == ctx.modules.get(stmt.argument) then
                error(
                    ('%s:%d:%d: belongs-to module "%s" not found'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument
                    )
                )
            end
        end
    },
    bit = {},
    case = {},
    choice = {},
    config = {},
    contact = {},
    container = {},
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
    import = {
        function(stmt, mod_, ctx, source)
            if nil == ctx.modules.get(stmt.argument) then
                error(
                    ('%s:%d:%d: import module "%s" not found'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument
                    )
                )
            end
        end
    },
    include = {
        function(stmt, mod_, ctx, source)
            if nil == ctx.modules.get(stmt.argument) then
                error(
                    ('%s:%d:%d: include module "%s" not found'):format(
                        source,
                        stmt.position.line,
                        stmt.position.col,
                        stmt.argument
                    )
                )
            end
        end
    },
    input = {},
    key = {},
    leaf = {},
    ['leaf-list'] = {},
    length = {},
    list = {},
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

return {
    syntactic_passes = function()
        return syntactic_pass
    end,
    semantic_passes = function()
        return semantic_pass
    end
}
