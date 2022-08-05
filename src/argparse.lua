#!/usr/bin/env lua

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

local parse_nargs = function(arg_list, start_pos, nargs_spec, option_name)
    local argval_list = {}
    if nargs_spec then
    else
        -- attempt to parse 1 value by default
        if start_pos + 1 > #arg_list then
            error('missing value for option "'..option_name..'"')
        end
    end
end

local m = {
--[[light weight python-like ArgumentParser]]
    create = function ()
        local option_list = {}
        local option_search_table = {}
        local parser = {
            add_argument = function(a)
                --[[
                    the input 'arg' be like:
                    {
                        [1] & [2]: short/long form of the option name, e.g. '-h' , e.g. '--help'
                        action : The basic type of action to be taken when this argument is encountered at the command line.
                        dest : The name of the attribute to be added to the object returned by parse_args().
                        nargs : The number of command-line arguments that should be consumed.
                        help: A brief description of what the argument does.
                    }
                ]]
                option_list[#option_list+1] = a
                -- iterate [1] [2] ... to store argument with its option name
                for _, option_name in ipairs(a) do
                    -- create option table for option-key-searching
                    option_search_table[option_name] = a
                end
            end,
            print_usage = function()
                print('Usage: lyang [options] file...')
                print('Available options:')
                for _, option in ipairs(option_list) do
                    local names = option[1]..(option[2] and (', '..option[2]) or '')
                    print('  '..names..'\t'..option.help)
                end
            end,
            parse_args = function()
                local result = {}
                local arglist = arg
                local index = 1
                while index < #arglist do
                    local _arg = option_list[index]
                    -- search if '_arg' is an option
                    local option = option_search_table[_arg]
                    if option then
                        -- option does exists
                        local action = option.action
                        if action == 'store_true' then
                            -- store true to the result with option.dest as key
                            result[option.dest] = true
                        elseif action == 'store_false' then
                            -- store false to the result with option.dest as key
                            result[option.dest] = false
                        elseif action == 'store' then
                        end
                    else
                        if string.match(_arg, '^(%-%-?)[^%-]+') then
                            -- '_arg' seem to be an option
                            error('invalid option: '.._arg)
                        end
                        -- push '_arg' as positional arguments
                        result[#result + 1] = _arg
                    end
                end
            end
        }
        -- add default options
        parser.add_argument{
            '-h', '--help',
            action='store_true',
            dest='help',
            help='Display this information'
        }
        return parser
    end
}

return m