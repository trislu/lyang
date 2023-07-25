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

local chunk = require('chunk')

local CRLF = {
    ['\r'] = 1,
    ['\n'] = 1
}

local SEP = {
    [' '] = 1,
    ['\t'] = 1,
    ['\v'] = 1,
    ['\f'] = 1
}

--[[ Lexical Tokenization (https://www.rfc-editor.org/rfc/rfc7950.html#section-6.1) ]]
local token = {
    -- unquoted string
    UQSTR = 1,
    -- single quoted string
    SQSTR = 2,
    -- double quoted string
    DQSTR = 3,
    -- semi colon
    SCOLON = 4,
    -- left brace
    LBRACE = 5,
    -- right brace
    RBRACE = 6,
    -- plus
    PLUS = 7
}

local RSVCHARS = {
    [';'] = token[SCOLON],
    ['{'] = token[LBRACE],
    ['}'] = token[RBRACE],
    ['+'] = token[PLUS]
}

local scanner = function(str)
    -- current offset
    local cur = nil
    -- consumed offset
    local con = nil
    local row = 1
    local col = 0
    local chk = chunk(str)
    local s = {
        next = function()
            if nil == cur then
                cur = 0
                return chk.at(0)
            elseif cur >= chk.len() then
                return nil
            end
            cur = cur + 1
            local n = chk.at(cur)
            if '\r' == n then
                -- windows?
                cur = cur + 1
                n = chk.at(cur)
            end
            col = col + 1
            if '\n' == n then
                col = 0
                row = row + 1
            end
            return n
        end,
        peek = function()
            if nil == cur then
                return chk.at(0)
            elseif cur >= chk.len() then
                return nil
            end
            return chk.at(cur + 1)
        end,
        peek2 = function()
            if chk.len() < 2 then
                return nil
            elseif nil == cur then
                return chk.sub(0, 1)
            elseif cur + 2 >= chk.len() then
                return nil
            end
            return chk.sub(cur + 1, cur + 2)
        end,
        consume = function()
            con = cur
        end,
        -- emit tokens
        emit_unquoted_string = function()
            return {token[UQSTR], chk.sub(con, cur), row, col}
        end,
        emit_single_quoted_string = function()
            return {token[SQSTR], chk.sub(con + 1, cur - 1), row, col}
        end,
        emit_double_quoted_string = function()
            return {token[DQSTR], chk.sub(con + 1, cur - 1), row, col}
        end,
        emit_character = function(c)
            return {RSVCHARS[c], c, row, col}
        end
    }
    return s
end

-- [lexer state]
local state = {}

-- [void]
state.void = function(s)
    local ch = s.peek()
    if nil == ch then
        -- EOS
        return nil
    elseif CRLF[ch] then
        s.next()
        return state.void
    elseif SEP[ch] then
        -- statements
        s.next()
        return state.void
    elseif RSVCHARS[ch] then
        s.next()
        s.consume()
        -- make single char token
        return state.void, s.emit_character(ch)
    elseif "'" == ch or '"' == ch then
        -- encounter quoted string
        return state.qstring
    elseif '/' == ch then
        local p2 = s.peek2()
        if '//' == p2 then
            return state.lcomment
        elseif '/*' == p2 then
            return state.bcomment
        else
            return state.uqstring
        end
    else
        return state.uqstring
    end
end

-- [unquoted string]
state.uqstring = function(s)
    s.next()
    s.consume()
    local ch
    while true do
        ch = s.peek()
        if nil == ch then
            -- reach EOF
            return nil, s.emit_unquoted_string()
        elseif SEP[ch] or CRLF[ch] or RSVCHARS[ch] or "'" == ch or '"' == ch then
            return state.void, s.emit_unquoted_string()
        else
            s.next()
        end
    end
end

-- [quoted string]
state.qstring = function(s)
    -- record head quote
    local quote = s.next()
    -- consume to head quote
    s.consume()
    --[[ TODO: trim whitespace and linebreak
        Ch6.1.3 of [rfc7950](https://www.rfc-editor.org/rfc/rfc7950.html)

        If a double-quoted string contains a line break followed by space or
        tab characters that are used to indent the text according to the
        layout in the YANG file, this leading whitespace is stripped from the
        string, up to and including the column of the starting double quote
        character, or to the first non-whitespace character, whichever occurs
        first.  Any tab character in a succeeding line that must be examined
        for stripping is first converted into 8 space characters.
        If a double-quoted string contains space or tab characters before a
        line break, this trailing whitespace is stripped from the string.

        A single-quoted string (enclosed within ' ') preserves each character
        within the quotes.  A single quote character cannot occur in a
        single-quoted string, even when preceded by a backslash.

        Within a double-quoted string (enclosed within " "), a backslash
        character introduces a representation of a special character, which
        depends on the character that immediately follows the backslash:

            \n      newline
            \t      a tab character
            \"      a double quote
            \\      a single backslash

        The backslash MUST NOT be followed by any other character.
    ]]
    local next_state = state.void
    local current = s.next()
    while current ~= quote do
        local ch = s.peek()
        if nil == ch then
            -- reach EOF
            next_state = nil
        elseif '\\' == ch then
            -- skip backslash
            s.next()
            -- skip escape charater
            if s.peek() then
                s.next()
            end
        end
        current = s.next()
    end
    local tk = ('"' == quote) and s.emit_double_quoted_string() or s.emit_single_quoted_string()
    return next_state, tk
end

-- [line comment]
state.lcomment = function(s)
    local ch = s.next()
    while ch do
        if CRLF[ch] then
            return state.void
        end
        ch = s.next()
    end
    return nil
end

-- [block comment]
state.bcomment = function(s)
    -- eats '/*'
    s.next()
    s.next()
    local p2 = s.peek2()
    while p2 do
        if '*/' == p2 then
            -- eats */
            s.next()
            s.next()
            return state.void
        end
        s.next()
        p2 = s.peek2()
    end
    -- tailing garbage
    return nil
end

return {
    token = token,
    emit_tokens = function(str)
        -- create internal scanner
        local s = scanner(str)
        -- emit tokens
        local results = {}
        local next_state = state.void
        local token
        while next_state do
            next_state, token = next_state(s)
            if token ~= nil then
                results[#results + 1] = token
            end
        end
        return results
    end
}
