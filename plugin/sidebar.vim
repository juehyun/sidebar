"********************************************************************************
" COPYRIGHT (C) 2017 Joohyun Lee (juehyun@etri.re.kr)
" 
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
" 
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"********************************************************************************

"--------------------------------------------------------------------------------
" Sidebar = NERDTree + Tagbar
"--------------------------------------------------------------------------------
map <Leader>sb :call<space>SidebarToggle()<CR>

"use only one instance of NERDTree
if !exists('g:sidebar_nerdtree_started')
	let g:sidebar_nerdtree_started=0
	let g:sidebar_with_tagbar=1| "set to 0, sidebar without tagbar
	let g:sidebar_nerdtree_single_buffer=0| "it should be 0
endif

"start sidebar and register 'autocmd BufEnter'
function! SidebarToggle()
	if !g:sidebar_nerdtree_started
		let g:sidebar_nerdtree_started=1
		call SidebarCallback()
		autocmd! BufEnter * call SidebarCallback()
		echo "Sidebar enabled, register autocmd"
	else
		autocmd! BufEnter *
		for w in range(1,bufnr('$'))
			if bufname(bufnr(w)) =~ 'NERD_tree' ||  bufname(bufnr(w)) =~ '__Tagbar__'
				silent exe "bwipeout " . bufnr(w)
			endif
		endfor
		let g:sidebar_nerdtree_started=0
		echo "Sidebar disabled"
	endif
endfunction

"check current buffer is valid for updating sidebar, otherwise return
function! SidebarChkValid()
	if (line('$') == 1 && getline(1) == '') | return 0 | endif "empty buffer (:help command will start with empty buffer)
	"if &readonly | return 0 | endif
	if &filetype=='help' | return 0 | endif
	let l:buf_nm = bufname("%")
	if (l:buf_nm[0:8]=="NERD_tree" || l:buf_nm[0:9]=="__Tagbar__") | return 0 | endif
	return 1
endfunction

"update sidebar (update NERDTree)
function! SidebarUpdateNERDTree()
	
	if(g:sidebar_nerdtree_single_buffer)
		"
		"(issue) Use only one instance of NERDTree : in case of multiple tabs are open, NERDTreeMirror iterates foreach tabs. it cause delay
		"
		if (g:sidebar_nerdtree_started==1 && bufwinnr('NERD_tree')==-1 ) | NERDTreeMirror | endif | "bufwinnr('NERD') : check for current tab
		NERDTreeFind | wincmd p | "NERDTreeFind will create NERD_tree_x buffer if not exist in current tab
	else
		NERDTreeFind | wincmd p | "NERDTreeFind will create NERD_tree_x buffer if not exist in current tab
	endif
	
	
	let g:sidebar_nerdtree_started=1
endfunction

"update sidebar (open Tagbar if not in this tab)
function! SidebarUpdateTagbar()
	if !g:sidebar_with_tagbar | return | endif
	if !tagbar#IsOpen()
		Tagbar
	endif
endfunction

"callback function for 'autocmd BufEnter'
function! SidebarCallback()
	if !SidebarChkValid() | return | endif
	call SidebarUpdateNERDTree()
	call SidebarUpdateTagbar()
endfunction

