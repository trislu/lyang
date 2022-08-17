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
local validate_option = function(option)
    if 'table' == type(option) then
        if #option == 0 then
            error('invalid option : missing option name : short form or long form is needed')
        elseif #option > 2 then
            error('too much option names : short form or long form is needed')
        else
            local valid_acition = {
                store = 1,
                store_true = 2,
                store_false = 3
            }
            if not (option.action and valid_acition[option.action]) then
                error('invalid option : action must be one of "store"|"store_true"|"store_false"')
            end
            local valid_nargs = {
                ['*'] = 1,
                ['+'] = 2,
                ['?'] = 3
            }
            if option.nargs and not (('number' == type(option.nargs)) or valid_nargs[option.nargs]) then
                error('invalid option : nargs must be one of number|"?"|"*"|"+"')
            end
        end
    else
        error('invalid option : must be a table')
    end
end

return function()
    local option_list = {}
    local option_search_table = {}
    local parser = {
        add_argument = function(o)
            --[[
                the input option 'o' must be table like:
                {
                    [1] & [2]: short/long form of the option name, e.g. '-h' , e.g. '--help'
                    action : The basic type of action to be taken when this argument is encountered at the command line.
                    dest : The name of the attribute to be added to the object returned by parse_args().
                    nargs : The number of command-line arguments that should be consumed.
                    help: A brief description of what the argument does.
                }
            ]]
            validate_option(o)
            option_list[#option_list + 1] = o
            -- iterate [1] [2] ... to store argument with its option name
            for _, option_name in ipairs(o) do
                if not string.match(option_name, '^(%-%-?)[^%-]+') then
                    error('invalid option name: "' .. option_name .. '", must start with "-" or "--"')
                end
                -- create option table for option-key-searching
                option_search_table[option_name] = o
            end
        end,
        print_usage = function()
            print('Usage: lyang [file] [options]')
            print('Available options:')
            for _, option in ipairs(option_list) do
                local names = option[1] .. (option[2] and (', ' .. option[2]) or '')
                print('  ' .. names .. '\t' .. option.help)
            end
        end,
        parse_args = function(arglist)
            local result = {}
            local index = 1
            while index <= #arglist do
                local _arg = arglist[index]
                -- search if '_arg' is a valid option name
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
                    elseif action == 'store' or action == nil then
                        -- parse nargs
                        local nargs = {}
                        -- repeat parse next arguments
                        while (index + 1 <= #arglist) and (not string.match(arglist[index + 1], '^(%-%-?)[^%-]+')) do
                            nargs[#nargs + 1] = arglist[index + 1]
                            index = index + 1
                        end
                        -- check if nargs is valid
                        if option.nargs then
                            if 'number' == type(option.nargs) then
                                if #nargs ~= option.nargs then
                                    error(
                                        'option "' ..
                                            _arg ..
                                                '" expect ' ..
                                                    tostring(option.nargs) .. ' arguments while ' .. #nargs .. ' given'
                                    )
                                end
                            elseif '?' == option.nargs then
                                if #nargs > 1 then
                                    error('option "' .. _arg .. '" expect 0 or 1 argument while ' .. #nargs .. ' given')
                                end
                            elseif '+' == option.nargs then
                                if #nargs < 1 then
                                    error('option "' .. _arg .. '" expect 1 or more argument while 0 given')
                                end
                            elseif '*' == option.nargs then -- luacheck: ignore
                                -- good
                            else
                                error('option "' .. _arg .. '" invalid nargs ' .. option.nargs)
                            end
                        else
                            error('option "' .. _arg .. '" claims store without nargs')
                        end
                        result[option.dest] = nargs
                    end
                else
                    if string.match(_arg, '^(%-%-?)[^%-]+') then
                        -- '_arg' seem to fit the option format
                        error('invalid option: ' .. _arg)
                    end
                    -- push '_arg' as positional arguments
                    result[#result + 1] = _arg
                end
                -- move index
                index = index + 1
            end
            -- return parsed result
            return result
        end
    }
    -- add default options
    parser.add_argument {
        '-h',
        '--help',
        action = 'store_true',
        dest = 'help',
        help = 'Display this information'
    }
    parser.add_argument {
        '-o',
        '--output',
        action = 'store',
        nargs = 1,
        dest = 'output',
        help = 'Save output to file'
    }
    parser.add_argument {
        '-c',
        '--convert',
        action = 'store',
        nargs = 1,
        dest = 'cov',
        help = 'Choose a converter'
    }
    parser.add_argument {
        '-l',
        '--link',
        action = 'store_true',
        dest = 'link',
        help = 'Enable the linker mode'
    }
    return parser
end
