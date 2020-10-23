" Specify a directory for plugins
let plugins = '~/.config/nvim'

if has('win32')
"  plugins = 'some other location'
endif


call plug#begin('~/.config/nvim')

Plug 'preservim/nerdtree'
"Plug 'tsony-tsonev/nerdtree-git-plugin'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/glyph-palette.vim'
" Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
" Plug 'ctrlpvim/ctrlp.vim' " fuzzy find files
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
"Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'HerringtonDarkholme/yats.vim' " TS Syntax
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Customized vim status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Icons
Plug 'ryanoasis/vim-devicons'
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Plug 'leafoftree/vim-vue-plugin'
Plug 'posva/vim-vue'
Plug 'https://github.com/adelarsq/vim-matchit'
Plug 'sickill/vim-pasta'
Plug 'unblevable/quick-scope'
Plug 'justinmk/vim-sneak'
Plug 'ap/vim-css-color'
Plug 'haya14busa/is.vim'
Plug 'PawkyPenguin/vim-select-indent'

" Colorschemes
Plug 'doums/darcula'
Plug 'chriskempson/tomorrow-theme'
Plug 'flazz/vim-colorschemes'

" Initialize plugin system
call plug#end()

" Main vim settings 
source $HOME/.config/nvim/general/settings.vim
" Autocomplete settings
" source $HOME/.config/nvim/general/settings.vim
" Airline theme settings
source $HOME/.config/nvim/themes/airline.vim

colorscheme darcula
hi Normal guibg=NONE ctermbg=NONE

nnoremap <SPACE> <Nop>
let mapleader=" "

" Auto save on focus lost or buffer change.
:au FocusLost * :wa
:set autowriteall

" Move the rest of the line 2 lines down and edit inbetween
inoremap <C-j> <Esc>a<Enter><Esc>O
nnoremap <C-j> <Esc>a<Enter><Esc>O

set termguicolors     " enable true colors support
"let ayucolor="light"  " for light version of theme
" let ayucolor="mirage" " for mirage version of theme

"let ayucolor="dark"   " for dark version of theme
" colorscheme ayu

let g:vim_vue_plugin_load_full_syntax = 1

set clipboard=unnamedplus
:nmap cp :let @+ = expand("%")<cr>
inoremap hj <ESC>

nnoremap <C-s> :w<Enter>

let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'
nnoremap <silent> <C-p> :Files<CR>

let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
set ignorecase " Do case insensitive matching
set smartcase " Do smart case matching

" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

nmap <silent> <C-n> :Fern . -reveal=% -drawer -toggle -width=40<CR>
let g:fern#renderer = "nerdfont"

" Add correct colors to nertree and fern icons
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END

" nmap <C-n> :NERDTreeToggle<CR>

"vmap ++ <plug>NERDCommenterToggle
"nmap ++ <plug>NERDCommenterToggle

map <Enter> o<ESC>
map <S-Enter> O<ESC>
noremap <leader>y "+y
" Delete without adding to clipboard
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

" open NERDTree automatically
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * NERDTree

" let g:NERDTreeGitStatusWithFlags = 1
" let g:WebDevIconsUnicodeDecorateFolderNodes = 1
" let g:NERDTreeGitStatusNodeColorization = 1

"let g:NERDTreeColorMapCustom = {
    "\ "Staged"    : "#0ee375",  
    "\ "Modified"  : "#d9bf91",  
    "\ "Renamed"   : "#51C9FC",  
    "\ "Untracked" : "#FCE77C",  
    "\ "Unmerged"  : "#FC51E6",  
    "\ "Dirty"     : "#FFBD61",  
    "\ "Clean"     : "#87939A",   
    "\ "Ignored"   : "#808080"   
    "\ }                         


" let g:NERDTreeIgnore = ['^node_modules$']

" vim-prettier
"let g:prettier#quickfix_enabled = 0
"let g:prettier#quickfix_auto_focus = 0
" prettier command for coc
command! -nargs=0 Prettier :CocCommand prettier.formatFile
" run prettier on save
"let g:prettier#autoformat = 0
"autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync


" ctrlp
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" j/k will move virtual lines (lines that wrap)
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Split switch
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" nmap <silent> <C-h> :wincmd h<CR>
" nmap <silent> <C-j> :wincmd j<CR>
" nmap <silent> <C-k> :wincmd k<CR>
" nmap <silent> <C-l> :wincmd l<CR>
" Split move
" nmap <silent> <C-H> :wincmd H<CR>
" nmap <silent> <C-J> :wincmd J<CR>
" nmap <silent> <C-K> :wincmd K<CR>
" nmap <silent> <C-L> :wincmd L<CR>
" Split resize
noremap <silent> <C-Left> :vertical resize +3<CR>
noremap <silent> <C-Right> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>
" Removes pipes | that act as seperators on splits
set fillchars+=vert:\ 

" 
let g:fzf_layout = { 'window': { 'width': 1, 'height': 0.9 } }
"let $FZF_DEFAULT_OPTS="--ansi --preview-window --margin=0,4 --preview 'bat --color=always --style=header,grid --line-range :300 {}'"


" sync open file with NERDTree
" " Check if NERDTree is open or active
"function! IsNERDTreeOpen()        
"  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
" endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
"function! SyncTree()
"  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
"    NERDTreeFind
"    wincmd p
"  endif
" endfunction

" Highlight currently open buffer in NERDTree
"autocmd BufEnter * call SyncTree()

" coc config
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json', 
  \ ]
" from readme
" if hidden is not set, TextEdit might fail.
set hidden " Some servers have issues with backup files, see #649 set nobackup set nowritebackup " Better display for messages set cmdheight=2 " You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
" nmap <silent> <C-d> <Plug>(coc-range-select)
" xmap <silent> <C-d> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Select indents
if exists(':SelectIndentVersion')

	" Use indents as text objects
	onoremap ii :call selectindent#select_inner_indent()<CR>
	onoremap ai :call selectindent#select_outer_indent()<CR>

	" Select whole indents
	vnoremap ii :<c-u>call selectindent#select_inner_indent()<CR>
	vnoremap ai :<c-u>call selectindent#select_outer_indent()<CR>
endif

