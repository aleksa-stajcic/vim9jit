-- vim9script
-- # cfilter.vim: Plugin to filter entries from a quickfix/location list
-- # Last Change: Jun 30, 2022
-- # Maintainer: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
-- # Version: 2.0
-- #
-- # Commands to filter the quickfix list:
-- #   :Cfilter[!] /{pat}/
-- #       Create a new quickfix list from entries matching {pat} in the current
-- #       quickfix list. Both the file name and the text of the entries are
-- #       matched against {pat}. If ! is supplied, then entries not matching
-- #       {pat} are used. The pattern can be optionally enclosed using one of
-- #       the following characters: ', ", /. If the pattern is empty, then the
-- #       last used search pattern is used.
-- #   :Lfilter[!] /{pat}/
-- #       Same as :Cfilter but operates on the current location list.
-- #
-- Token(EndOfLine, "\n", (18,0)->(18,0))
local Qf_filter = function(qf, searchpat, bang)
  local Xgetlist = nil
  local Xsetlist = nil
  local cmd = nil
  local firstchar = nil
  local lastchar = nil
  local pat = nil
  local title = nil
  local Cond = nil
  local items = nil
  -- Token(EndOfLine, "\n", (29,0)->(29,0))
  if qf then
    Xgetlist = function(...)
      return vim.fn["getqflist"](...)
    end
    Xsetlist = function(...)
      return vim.fn["setqflist"](...)
    end
    cmd = require("vim9script").ops["StringConcat"](":Cfilter", bang)
  else
    Xgetlist = function(...)
      local copied = vim.deepcopy { 0 }
      for _, val in ipairs { ... } do
        table.insert(copied, val)
      end
      return vim.fn["function"](unpack(copied))
    end
    Xsetlist = function(...)
      local copied = vim.deepcopy { 0 }
      for _, val in ipairs { ... } do
        table.insert(copied, val)
      end
      return vim.fn["function"](unpack(copied))
    end
    cmd = require("vim9script").ops["StringConcat"](":Lfilter", bang)
  end
  -- Token(EndOfLine, "\n", (39,0)->(39,0))
  firstchar = require("vim9script").index(searchpat, 0)
  lastchar = require("vim9script").slice(searchpat, require("vim9script").prefix["Minus"](1), nil)
  if
    require("vim9script").ops["And"](
      require("vim9script").ops["EqualTo"](firstchar, lastchar),
      (
        require("vim9script").ops["Or"](
          require("vim9script").ops["Or"](
            require("vim9script").ops["EqualTo"](firstchar, "/"),
            require("vim9script").ops["EqualTo"](firstchar, '"')
          ),
          require("vim9script").ops["EqualTo"](firstchar, "'")
        )
      )
    )
  then
    pat = require("vim9script").slice(searchpat, 1, require("vim9script").prefix["Minus"](2))
    if require("vim9script").ops["EqualTo"](pat, "") then
      -- # Use the last search pattern
      pat = vim.fn.getreg "/"
    end
  else
    pat = searchpat
  end
  -- Token(EndOfLine, "\n", (52,0)->(52,0))
  if require("vim9script").ops["EqualTo"](pat, "") then
    return
  end
  -- Token(EndOfLine, "\n", (56,0)->(56,0))
  if require("vim9script").ops["EqualTo"](bang, "!") then
    Cond = function(_, val)
      return require("vim9script").ops["And"](
        require("vim9script").ops["NotRegexpMatches"](val["text"], pat),
        require("vim9script").ops["NotRegexpMatches"](vim.fn["bufname"](val["bufnr"]), pat)
      )
    end
  else
    Cond = function(_, val)
      return require("vim9script").ops["Or"](
        require("vim9script").ops["RegexpMatches"](val["text"], pat),
        require("vim9script").ops["RegexpMatches"](vim.fn["bufname"](val["bufnr"]), pat)
      )
    end
  end
  -- Token(EndOfLine, "\n", (62,0)->(62,0))
  items = require("vim9script").fn_mut("filter", { Xgetlist(), Cond }, { replace = 0 })
  title = require("vim9script").ops["StringConcat"](
    require("vim9script").ops["StringConcat"](require("vim9script").ops["StringConcat"](cmd, " /"), pat),
    "/"
  )
  Xsetlist({}, " ", { title = title, items = items })
end
-- Token(EndOfLine, "\n", (67,0)->(67,0))
vim.api.nvim_create_user_command("Cfilter", function(__vim9_arg_1)
  Qf_filter(true, __vim9_arg_1.args, (__vim9_arg_1.bang and "!" or ""))
end, {
  nargs = "+",
  bang = true,
})
vim.api.nvim_create_user_command("Lfilter", function(__vim9_arg_1)
  Qf_filter(false, __vim9_arg_1.args, (__vim9_arg_1.bang and "!" or ""))
end, {
  nargs = "+",
  bang = true,
})
-- Token(EndOfLine, "\n", (70,0)->(70,0))
-- # vim: shiftwidth=2 sts=2 expandtab
