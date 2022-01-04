" KEY REMAPS

" ---------------------------
" General
" ---------------------------

let mapleader = " "

" Don't use Ex mode
nnoremap Q <nop>

" save file
map <F1> :w<CR>

" resize vertical splits
nnoremap <F2> :vertical resize -2<CR>
nnoremap <F3> :vertical resize +2<CR>

" navigate vertical splits
nnoremap <F4> <C-w>h
nnoremap <F5> <C-w>l

" spell checking
map <F8> :setlocal spell! spelllang=en_gb<CR>

" Autoformat file / visually selected block
nnoremap <F9> gg=G
vnoremap <F9> =

" remove search highlight
map <leader>h :nohls<CR>

" toggle NerdTree visibility
map <leader>m :NERDTreeToggle<CR>
" show file in enclosing folder
nnoremap <silent> <leader>sf :NERDTreeFind<CR>

" Make current file executable
nnoremap <leader>x :!chmod +x %<CR>

" Display the buffer list and invoke the ':buffer' command. 
" You can enter the desired buffer number and hit <Enter> to edit the buffer
nnoremap <leader>b :ls<CR>:vertical sb<Space>

" Close all buffers except the one being edited
" We also also close all possible remaining splits
" Finally, open NERDTree but focus on the file
nnoremap <leader>bc :%bd<CR>:e#<CR>:bd#<CR>:NERDTree<CR><C-w>l

" git blame current line
nnoremap <leader>gb :<C-u>call gitblame#echo()<CR>

" source vim settings
nnoremap <leader>sv :source ~/.config/vim/init.vim<CR>
"
" Fuzzy find files, then open in horizontal split
map <silent> <leader>f :Files<CR>

" ---------------------------
" Special c / d / x mappings
" ---------------------------
" Allows to copy text outside vim, delete in vim, paste copied text
" If we want to paste deleted text we just add the leader before p/P

nnoremap d "1d
vnoremap d "1d
nnoremap c "1c
vnoremap c "1c
nnoremap x "1x
vnoremap x "1x

nnoremap <leader>p "1p
nnoremap <leader>P "1P

" ---------------------------
" Move / indent mappings
" ---------------------------

" move line up/down when in normal mode
nnoremap <leader>k :m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==

" move line up/down when in insert mode
inoremap <c-k> <esc>:m .-2<CR>==gi
inoremap <c-j> <esc>:m .+1<CR>==gi

" move selected block up/down in visual mode and reselect
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" visual mode indent, keeping selection
vnoremap > >gv
vnoremap < <gv

" ---------------------------
" Add undo break points
" --------------------------- 
inoremap . .<c-g>u
inoremap , ,<c-g>u
inoremap [ [<c-g>u
inoremap { {<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" ---------------------------
" coc/tabnine mappings
" ---------------------------
" <CR> auto-select the first completion item and notify coc.nvim to format on enter
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" ---------------------------
" Replacement mappings
" ---------------------------
" (2x leader being a destructive command)

" Replace in file
nnoremap <leader><leader>rf :%s/a/b/g

" Replace in all open buffers
nnoremap <leader><leader>rb :bufdo %s/a/b/ge | update

" Replace in all project
" Requires a quickfix buffer with results from a global search like :rg whatever
nnoremap <leader><leader>rp :cdo %s/a/b/g


