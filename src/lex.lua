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
local token = require('token')
local scanner = require('scanner')

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

local BLOCK = {
    [';'] = 1,
    ['{'] = 1,
    ['}'] = 1
}

CUSTOM_LEX = nil

return function(buffer)
    -- allow user-defined lexer
    if CUSTOM_LEX then
        --[[
        The default lexer depends on nothing but builtin lua.
        But if which performance is considered unacceptable,
        one can be substituted by a high performace version.
        E.g. LPEG or luajit FFI
        ]]
        return CUSTOM_LEX
    end
    -- create internal scanner
    local s = scanner(buffer)
    -- create internal tokenizer
    local tokenizer =
        coroutine.create(
        function()
            --[[ Lexical Tokenization (https://www.rfc-editor.org/rfc/rfc7950.html#section-6.1) ]]
            local state = {}
            -- [void]
            state.void = function()
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
                elseif BLOCK[ch] or '+' == ch then
                    s.next()
                    s.consume()
                    -- make single char token
                    return state.void, s.make_character_token(ch)
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
            state.uqstring = function()
                s.next()
                s.consume()
                while true do
                    local ch = s.peek()
                    if nil == ch then
                        -- reach EOF
                        return nil, s.make_string_token(token.UnquotedString)
                    elseif SEP[ch] or CRLF[ch] or BLOCK[ch] or "'" == ch or '"' == ch then
                        return state.void, s.make_string_token(token.UnquotedString)
                    else
                        s.next()
                    end
                end
            end
            -- [quoted string]
            state.qstring = function()
                -- record head quote
                local quote = s.next()
                -- skip head quote
                s.next()
                s.consume()
                --[[
                TODO: trim whitespace and linebreak
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
                local tk = nil
                while true do
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
                    elseif quote == ch then
                        -- quote back
                        break
                    end
                    s.next()
                end
                if '"' == quote then
                    tk = s.make_string_token(token.DoubleQuotedString)
                else
                    tk = s.make_string_token(token.SingleQuotedString)
                end
                -- skip tail quote
                s.next()
                return state.void, tk
            end
            -- [line comment]
            state.lcomment = function()
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
            state.bcomment = function()
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
            -- tokenizer loop
            local next_state = state.void
            local token = nil
            while true do
                next_state, token = next_state()
                if token then
                    coroutine.yield(token)
                end
                if nil == next_state then
                    break
                end
            end
        end
    )
    -- create lexer
    local l = {
        next_token = function()
            local _, tk = coroutine.resume(tokenizer)
            return tk
        end
    }
    return l
end
