" KEY REMAPS
" Shortcomings in macOS below
" ---------------------------

let mapleader = ","

" help
map <F1> :help<CR>

" save file
map <F10> :w<CR>

" Autoformat file
map <F2> :Autoformat<CR>

" resize horizontal splits
nnoremap <F3>  :resize +2<CR>
nnoremap <F4> :resize -2<CR>

" resize vertical splits
nnoremap <F7> :vertical resize -2<CR>
nnoremap <F8> :vertical resize +2<CR>

" navigate vertical splits
nnoremap <F5> <C-w>h
nnoremap <F6> <C-w>l

" top/bottom of document/screen
nnoremap <Home> ggk<CR>
nnoremap <End> G<CR>
nnoremap <PageUp> <C-B><CR>
nnoremap <PageDown> <C-F><CR>

" scroll the viewport faster
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" move selected blocks in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" visual mode indent, keeping selection
vnoremap > >gv
vnoremap < <gv

" spell checking
map <F12> :setlocal spell! spelllang=en_gb<CR>

" remove search highlight
map <leader><ESC> :nohls<CR>

" toggle invisible characters
function! ToggleInvisiblChars()
  set list!
endfunction
nnoremap <leader>i :call ToggleInvisiblChars()<CR>

" Don't use Ex mode
nnoremap Q <nop> 

" NerdTree
map <leader>m :NERDTreeToggle<CR>
nnoremap <silent> <leader>s :NERDTreeFind<CR>

" Open files in horizontal split
map <silent> <leader>f :call fzf#run({
\   'down': '30%',
\   'sink': 'vertical split' })<CR>

" Display the buffer list and invoke the ':buffer' command. 
" You can enter the desired buffer number and hit <Enter> to edit the buffer
nnoremap <leader>b :ls<CR>:buffer<Space>
" Same but invoking ':vertical sb' command. 
nnoremap <leader>bv :ls<CR>:vertical sb<Space>

" Close all buffers except the one being edited
" We also also close all possible remaining splits
" Finally, open NERDTree
nnoremap <leader>bc :bufdo bd<CR>:only<CR>:NERDTree<CR>

" git blame current line
nnoremap <leader>gb :<C-u>call gitblame#echo()<CR>

" source vim settings
nnoremap <leader>sv :source ~/.config/nvim/init.vim<CR>

" ----------- shortcomings
" mac os doesnt expose the Alt or Ctrl combinations properly to vim
" To determine whether Vim receives a key sequence, do the following: 
" in INSERT mode press <CTRL-V> followed by the key sequence
" Alternatively, we can use this in the terminal
" then type the desired combination
" sed -n l
" In out case, Alt + arrows are: 
" Right ^[[C 
" Up ^[[A 
" Left ^[[D 
" Down ^[[B
" Shift + arrows are:
" Left  ^[[1;2D 
" Right ^[[1;2C
" In theory adding these to mappings should work, replacing ^[ by <Esc>
" BUT THEY DONT WORK 
"
" Best option for this to work on a Mac using the normal A- or M- modifiers  
" WOULD BE to (check) Use Option as Meta Key in Terminal->Preferences->Keyboard
" BUT PROBLEM with this, it stops allowing special chars in terminal (ie AltGr + 1 for |)
"
" Also can review the keyboard mappings in Terminal->Preferences->Keyboard. In my case:
" Alt + arrows are: 
" Left \033b
" Right \033f
" So I also removed these
" 
" So, apparently, there is no way to make arrows work as remaps using a modifier
" Final solution is to map it to Function keys

