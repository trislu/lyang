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
local validate = require('validate')

local syntactic_pipeline = {validate.syntactic_pass()}
local semantic_pipeline = {validate.semantic_pass()}

return {
    run_syntactic_pass = function(stmt, mod, ctx, source)
        for _, passes in ipairs(syntactic_pipeline) do
            local pass = passes[stmt.keyword]
            if pass then
                pass(stmt, mod, ctx, source)
            else
                -- extended-stmt pass
                local ok, prefix, ident = utils.decouple_nodeid(stmt.keyword)
                if ok and prefix then
                    -- seems to be a valid extended-stmt
                    local meta = ctx.modules.get_meta(mod.argument)
                    if not meta.prefixes or nil == meta.prefixes[prefix] then
                        error(
                            ('%s:%d:%d: undefined prefix "%s" of keyword "%s"'):format(
                                source,
                                stmt.position.line,
                                stmt.position.col,
                                prefix,
                                stmt.argument
                            )
                        )
                    end
                    -- well defined 'prefix'
                    local import_stmt = meta.prefixes[prefix].parent
                    -- parent of the prefix-stmt must be import-stmt
                    assert('import' == import_stmt.keyword)
                    -- have all extension modules been parsed?
                    if not ctx.modules.extended() then
                        -- nope, record this keyword in pending list
                        if nil == meta.pending_extended_keywords then
                            meta.pending_extended_keywords = {}
                        end
                        meta.pending_extended_keywords[#meta.pending_extended_keywords + 1] = {
                            stmt,
                            import_stmt.argument
                        }
                    else
                        -- all the modules that had defined extension statements has been parse
                        local def_mod = ctx.modules.get(import_stmt.argument)
                        if nil == def_mod then
                            -- report errors that import module does not exist
                            error(
                                ('%s:%d:%d: can not find import module "%s" for extended keyword "%s"'):format(
                                    source,
                                    stmt.position.line,
                                    stmt.position.col,
                                    import_stmt.argument,
                                    stmt.argument
                                )
                            )
                        end
                        -- check the extension definitions in the import module
                        local def_meta = ctx.modules.get_meta(import_stmt.argument)
                        if nil == def_meta.extensions[ident] then
                            error(
                                ('%s:%d:%d: undefined extension "%s" from module "%s" for keyword "%s"'):format(
                                    source,
                                    stmt.position.line,
                                    stmt.position.col,
                                    ident,
                                    import_stmt.argument,
                                    stmt.argument
                                )
                            )
                        end
                    end
                else
                    -- very unlikely
                    error(
                        ('[internal]%s:%d:%d: invalid keyword "%s"'):format(
                            source,
                            stmt.position.line,
                            stmt.position.col,
                            stmt.keyword
                        )
                    )
                end
            end
        end
    end,
    run_semantic_pass = function(stmt, mod, ctx, source)
        for _, passes in ipairs(semantic_pipeline) do
            local pass = passes[stmt.keyword]
            if pass then
                pass(stmt, mod, ctx, source)
            end
            -- custom extended keywords?
        end
    end
}
