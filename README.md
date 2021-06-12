# telescope-snippets
This is extensions of [Telescope](https://github.com/nvim-telescope/telescope.nvim) that use [snippets.nvim](https://github.com/norcalli/snippets.nvim)
![Peek 2021-06-12 00-18](https://user-images.githubusercontent.com/17103748/121764707-e57e2a00-cb13-11eb-890e-78a7ec93e79b.gif)

# Installations
```lua

--install telescope
use 'nvim-lua/popup.nvim'
use 'nvim-lua/plenary.nvim'
use 'nvim-telescope/telescope.nvim'

--install this integration
use 'Maverun/telescope-snippets'
```

# Setup

Can done setup by 

```lua
require('telescope').load_extension('snippets')
```

and to run it

```viml
:Telescope snippets
```

# Inspire

I got inspire by [telescope-ultisnips.nvim](https://github.com/fhill2/telescope-ultisnips.nvim)
Although it may not be much but I figure I should create similar one with currently snippets I am using while learning how to make plugins and lua for a first time.
