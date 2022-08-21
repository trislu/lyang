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

return function()
    local module_t = {}
    local namespace_t = {}
    local extended = false
    local m = {
        add = function(mod, source, meta)
            module_t[mod.argument] = {mod, source, meta}
            -- for traverse
            module_t[#module_t + 1] = mod
        end,
        get = function(name)
            if module_t[name] then
                return module_t[name][1]
            end
            return nil
        end,
        add_namespace = function(ns, source)
            namespace_t[ns.argument] = {ns, source}
        end,
        get_namespace = function(ns)
            return namespace_t[ns]
        end,
        get_source = function(name)
            if module_t[name] then
                return module_t[name][2]
            end
            return nil
        end,
        get_meta = function(name)
            if module_t[name] then
                return module_t[name][3]
            end
            return nil
        end,
        at = function(index)
            return module_t[index]
        end,
        count = function()
            return #module_t
        end,
        extended = function()
            return extended
        end
    }

    function m.do_extend()
        -- check all extended keywords for loaded modules
        for _, mod in ipairs(module_t) do
            -- must define some extension
            local meta = m.get_meta(mod.argument)
            if 0 == #(meta.extensions) then
                error(
                    m.get_source(mod.argument) ..
                        ': ' .. mod.keyword .. ' "' .. mod.argument .. '" defines none extensions'
                )
            end
            -- handle pending extended keywords
            if meta.pending_extended_keywords then
                for _, ext in ipairs(meta.pending_extended_keywords) do
                    local keyword_stmt, import_modname = ext[1], ext[2]
                    if nil == module_t[import_modname] then
                        local source = m.get_source(mod.argument)
                        error(
                            ('%s:%d:%d: can not find import module "%s" of keyword "%s"'):format(
                                source,
                                keyword_stmt.position.line,
                                keyword_stmt.position.col,
                                import_modname,
                                keyword_stmt.argument
                            )
                        )
                    end
                    -- import module does exist
                    local def_meta = m.get_meta(import_modname)
                    assert(nil ~= def_meta)
                    local _, _, ident = utils.decouple_nodeid(keyword_stmt.argument)
                    local def_extension = def_meta.extensions[ident]
                    if nil == def_extension then
                        local source = m.get_source(mod.argument)
                        error(
                            ('%s:%d:%d: can not find extension "%s" from module "%s" for keyword "%s"'):format(
                                source,
                                keyword_stmt.position.line,
                                keyword_stmt.position.col,
                                ident,
                                import_modname,
                                keyword_stmt.argument
                            )
                        )
                    end
                end
                -- clear for GC
                meta.pending_extended_keywords = nil
            end
        end
        -- mark the whole module repository as "extended"
        extended = true
    end

    return m
end
