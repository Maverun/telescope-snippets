-- Copyright (C) Maverun 2021
local has_telescope, telescope = pcall(require, "telescope")
local has_snippet, snippet = pcall(require,"snippets")
if not has_telescope then
    error("This plugins requires nvim-telescope/telescope.nvim")
elseif not has_snippet then
    error("This plugin requires norcalli/snippets.nvim")
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values


local function print_table(tb)
    for k,v in pairs(tb) do
        print(k,'---',v,type(v))
    end
end

local function get_snippet_list()

    local snip_list = {}
    local function loopcreate(obj,ft)
        for k,v in pairs(snippet.snippets[ft]) do
            table.insert(obj,{
                filetype = ft:gsub('_',''),
                name = k,
            })
        end
    end
    --making sure filetype is there or else error
    if vim.bo.filetype ~= '' and snippet.snippets[vim.bo.filetype] ~= nil then
        loopcreate(snip_list,vim.bo.filetype)
    end
    loopcreate(snip_list,'_global')
    return snip_list
end

local function show_preview(entry,buf)
    vim.api.nvim_buf_set_option(buf, "filetype", entry.value.filetype)
    local snip = snippet.lookup_snippet(entry.value.filetype,entry.value.name)
    local ux = require'snippets/inserters/vim_input'


    local s = ux(snip)
    --First we will remove any previously lines so it dont overlap with previous snip in case...
    local max_line  = vim.api.nvim_buf_line_count(0)
    for i = max_line,0,-1 do
        vim.api.nvim_buf_set_lines(0,i,-1,false,{''})
    end

    --Once we done, we set offset max number, so we can skip all placeholder...
    s.advance(math.pow(2,1024))
    --since snippet will save to current screen but not to preview so we need to get all of that lines and paste to preview buffers
    local complete = vim.api.nvim_buf_get_lines(0,0,999,false)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, complete)

end

local function make_entry(entry)
    --Create Display Area of telescope 
    local displayer = entry_display.create({
        separator = "▏",
        items = { { width = 20 }, { width = 20 }, { remaining = true } },
    })

    local make_display = function(entry_)
        return displayer({ entry_.value.filetype, entry_.value.name})
    end
    return {
        value = entry,
        display = make_display,
        ordinal = entry.filetype .. ' ' .. entry.name .. ' ',
        preview_command = show_preview
    }
end

local snippets = function(opts)
    opts = opts or {}
    local snip_list = get_snippet_list()

    pickers.new(opts, {
        prompt_title = "Snippets",
        finder = finders.new_table({
            results = snip_list,
            entry_maker = make_entry
        }),

        previewer = previewers.display_content.new(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function()
            actions.select_default:replace(function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.api.nvim_put({selection.value.name }, "", true, true)
                vim.cmd([[lua require('snippets').expand_at_cursor()]])
                vim.fn.feedkeys("i")
            end)
            return true
        end,
    }):find()
end -- end custom function


return telescope.register_extension({ exports = { snippets = snippets } })
