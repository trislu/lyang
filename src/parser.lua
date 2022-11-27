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

local stack = require('stack')
local token = require('token')
local buffer = require('buffer')
local lex = require('lex')
local statement = require('statement')
local pass = require('pass')

local function create_nfa(ctx)
    -- Non-Deterministic Finite Automata
    local nfa = {
        -- inputs
        filename = '',
        lexer = nil,
        -- internal
        argument_string = {},
        stmt_stack = stack(),
        root_stmt = nil,
        -- token record
        cur_token = nil,
        -- extension tree mark
        extension_root = nil,
        -- error record
        lasterr = nil,
        -- context
        context = ctx
    }

    local trace = function(...)
        -- TODO: debug level
        if ctx.args and 'debug' == ctx.args.mode then
            return print(...)
        end
    end

    function nfa:load(f)
        local buf = buffer()
        buf.load(f)
        self.filename = f
        self.lexer = lex(buf)
    end

    function nfa:loadstring(s)
        local buf = buffer()
        buf.loadstring(s)
        self.lexer = lex(buf)
    end

    function nfa:abort_on_token(msg)
        self.lasterr = self.filename .. ':' .. self.cur_token.line .. ':' .. self.cur_token.col .. ': ' .. msg
        return nil
    end

    function nfa:abort_on_stmt(msg)
        -- make sure there exist statements on stack
        self.lasterr =
            self.filename ..
            ':' .. self.stmt_stack.top().position.line .. ':' .. self.stmt_stack.top().position.col .. ': ' .. msg
        return nil
    end

    function nfa:init()
        trace('nfa:init()')
        assert(nil == self.cur_token)
        self.cur_token = self.lexer.next_token()
        if nil == self.cur_token then
            self.lasterr = self.filename .. ':0:0:token not found'
            return nil
        elseif token.UQSTR ~= self.cur_token.type then -- luacheck:ignore
            --[[ (https://www.rfc-editor.org/rfc/rfc7950.html#section-6.1.3)
            "Note that any keyword can legally appear as an unquoted string."]]
            return self:abort_on_token(
                'expected unquoted string token but was "' .. token.typename(self.cur_token.type) .. '"'
            )
        end
        return self.meet_keyword
    end

    --[[meet keyword]]
    function nfa:meet_keyword()
        trace('nfa:meet_keyword()')
        -- clear argument string cache
        self.argument_string = {}
        -- already in extension tree
        if nil ~= self.extension_root then
            -- being substatments of a extension statment
            return self.meet_extension
        elseif self.cur_token.content:find(':') then
            -- only one colon?
            if self.cur_token.content:match('[^:]*:[^:]*:[^:]*') then
                return self:abort_on_token('more than one ":" found')
            end
            -- meet extension root
            self.extension_root = self.stmt_stack.size() + 1
            return self.meet_extension
        else
            -- create statement
            local stmt = statement(self.cur_token.content)
            if nil == stmt.syntax then
                -- TODO: make suggestions?
                return self:abort_on_token('unknown keyword "' .. self.cur_token.content .. '"')
            end
            stmt.position.line = self.cur_token.line
            stmt.position.col = self.cur_token.col
            -- link with parent
            local parent = self.stmt_stack.top()
            if parent then
                stmt.parent = parent
                -- is a valid substatemnt of parent?
                if parent.syntax.meet(stmt.keyword) then
                    parent.append_substmt(stmt)
                else
                    return self:abort_on_stmt(parent.syntax.lasterr())
                end
            else
                self.root_stmt = stmt
            end
            self.stmt_stack.push(stmt)
            -- read next token
            self.cur_token = self.lexer.next_token()
            -- check if the statment needs argument string
            if stmt.syntax.arg() then
                -- argument string is required
                if token.UQSTR == self.cur_token.type then
                    return self.meet_unquoted_argument
                elseif token.SQSTR == self.cur_token.type or token.DQSTR == self.cur_token.type then
                    return self.meet_quoted_argument
                else
                    return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
                end
            else
                -- argument string is not required: e.g. "input"/"output"
                if token.LBRACE == self.cur_token.type then
                    return self.begin_substatement
                elseif token.SCOLON == self.cur_token.type then
                    -- is it legal?
                    return self.end_statement
                else
                    return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
                end
            end
        end
    end

    --[[meet extension]]
    function nfa:meet_extension()
        trace('nfa:meet_extension()')
        -- create statement
        local stmt = statement(self.cur_token.content)
        stmt.position.line = self.cur_token.line
        stmt.position.col = self.cur_token.col
        -- link with parent
        local parent = self.stmt_stack.top()
        if parent then
            stmt.parent = parent
            parent.append_substmt(stmt)
        else
            self.root_stmt = stmt
        end
        self.stmt_stack.push(stmt)
        -- read next token
        self.cur_token = self.lexer.next_token()
        if token.UQSTR == self.cur_token.type then
            -- unquoted argument string
            return self.meet_unquoted_argument
        elseif token.SQSTR == self.cur_token.type or token.DQSTR == self.cur_token.type then
            -- quoted argument string
            return self.meet_quoted_argument
        elseif token.LBRACE == self.cur_token.type then
            -- begin substatement
            return self.begin_substatement
        elseif token.SCOLON == self.cur_token.type then
            -- end statement
            return self.end_statement
        else
            return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
        end
    end

    --[[meet unquoted argument]]
    function nfa:meet_unquoted_argument()
        trace('nfa:meet_unquoted_argument()')
        -- assign argument string
        local stmt = self.stmt_stack.top()
        stmt.argument = self.cur_token.content
        -- read next token
        self.cur_token = self.lexer.next_token()
        if token.LBRACE == self.cur_token.type then
            -- begin substatement
            return self.begin_substatement
        elseif token.SCOLON == self.cur_token.type then
            -- end statement
            return self.end_statement
        else
            return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
        end
    end

    --[[meet quoted argument]]
    function nfa:meet_quoted_argument()
        trace('nfa:meet_quoted_argument()')
        -- argument of which stmt
        local stmt = self.stmt_stack.top()
        -- cache argument string
        self.argument_string[#self.argument_string + 1] = self.cur_token.content
        -- read next token
        self.cur_token = self.lexer.next_token()
        if token.LBRACE == self.cur_token.type then
            -- concat argument strings
            stmt.argument = table.concat(self.argument_string)
            -- begin substatement
            return self.begin_substatement
        elseif token.SCOLON == self.cur_token.type then
            -- concat argument strings
            stmt.argument = table.concat(self.argument_string)
            -- end statement
            return self.end_statement
        elseif token.PLUS == self.cur_token.type then
            -- "+"
            return self.concat_quoted_argument
        else
            return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
        end
    end

    --[[concat quoted argument]]
    function nfa:concat_quoted_argument()
        trace('nfa:concat_quoted_argument()')
        -- read next token
        self.cur_token = self.lexer.next_token()
        -- luacheck: ignore
        if token.SQSTR == self.cur_token.type or token.DQSTR == self.cur_token.type then
            -- concat next argument string
            return self.meet_quoted_argument
        else
            return self:abort_on_token('expected quoted string but was "' .. token.typename(self.cur_token.type) .. '"')
        end
    end

    --[[begin substatement]]
    function nfa:begin_substatement()
        trace('nfa:begin_substatement()')
        -- run syntatic pass for this statement
        pass.run_syntactic_pass(self.stmt_stack.top(), self.stmt_stack.bottom(), self.context, self.filename)
        -- read next token
        self.cur_token = self.lexer.next_token()
        -- exntension subtree?
        if self.extension_root then
            -- read next token
            if token.UQSTR == self.cur_token.type then
                return self.meet_keyword
            elseif token.RBRACE == self.cur_token.type then
                return self.end_substatement
            else
                return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
            end
        end
        -- standard
        if token.UQSTR == self.cur_token.type then
            return self.meet_keyword
        elseif token.RBRACE == self.cur_token.type then
            return self.end_substatement
        else
            return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
        end
    end
    -- [[end substatement]]
    function nfa:end_substatement()
        trace('nfa:end_substatement()')
        if self.extension_root then
            --[[TOOD:verify extension syntax?]]
            if self.extension_root == self.stmt_stack.size() then
                -- leave the extension context
                self.extension_root = nil
            end
        else
            -- get syntax rule of this statement
            local stmt = self.stmt_stack.top()
            if not stmt.syntax.valid() then
                -- if the syntax rule of this statement was valid
                return self:abort_on_stmt(stmt.syntax.lasterr())
            end
        end
        -- pop statment
        self.stmt_stack.pop()
        -- read next token
        self.cur_token = self.lexer.next_token()
        if nil == self.cur_token then
            return nil
        elseif token.UQSTR == self.cur_token.type then
            return self.meet_keyword
        elseif token.RBRACE == self.cur_token.type then
            return self.end_substatement
        else
            return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
        end
    end

    -- [[end statement]]
    function nfa:end_statement()
        trace('nfa:end_statement()')
        -- run syntatic pass for this statement
        pass.run_syntactic_pass(self.stmt_stack.top(), self.stmt_stack.bottom(), self.context, self.filename)
        if self.extension_root then
            --[[TOOD:verify extension syntax?]]
            if self.extension_root == self.stmt_stack.size() then
                -- leave the extension context
                self.extension_root = nil
            end
        else
            -- get syntax rule of this statement
            local stmt = self.stmt_stack.top()
            if not stmt.syntax.valid() then
                -- if the syntax rule of this statement was valid
                return self:abort_on_stmt(stmt.syntax.lasterr())
            end
        end
        -- pop statment
        self.stmt_stack.pop()
        -- read next token
        self.cur_token = self.lexer.next_token()
        if token.UQSTR == self.cur_token.type then
            return self.meet_keyword
        elseif token.RBRACE == self.cur_token.type then
            return self.end_substatement
        else
            return self:abort_on_token('unexpected token "' .. token.typename(self.cur_token.type) .. '"')
        end
    end

    function nfa:run()
        local transition = self.init
        while transition do
            transition = transition(self)
        end
        return self.lasterr, self.root_stmt
    end

    return nfa
end

return function(ctx)
    local p = {
        parse = function(f)
            local nfa = create_nfa(ctx)
            nfa:load(f)
            return nfa:run()
        end,
        parse_string = function(s)
            local nfa = create_nfa(ctx)
            nfa:loadstring(s)
            return nfa:run()
        end
    }
    return p
end
