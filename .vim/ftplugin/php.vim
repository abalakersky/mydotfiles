" .vim/ftplugin/php.vim by Tobias Schlitt <toby@php.net>.
" No copyright, feel free to use this, as you like.

" update taglist when you save a php file
autocmd BufWritePost *.php :TlistUpdate

" Including PDV
source ~/.vim/bundle/phpdoc/php-doc.vim

let PHP_autoformatcomment = 1

let g:pdv_cfg_Type = "mixed"
let g:pdv_cfg_Package = ""
let g:pdv_cfg_Version = "$Id$"
let g:pdv_cfg_Author = "John Doe <johndoe@gmail.com>"
let g:pdv_cfg_Copyright = "Copyright (C) 2010-2011 John Doe. All rights reserved."
let g:pdv_cfg_License = "GPL Version 3 {@link http://www.gnu.org/licenses/gpl.html}"
let g:pdv_cfg_Uses = 1

" {{{ Settings

" Auto expand tabs to spaces
setlocal expandtab

" Auto indent after a {
setlocal autoindent
setlocal smartindent

" Linewidth to 79, because of the formatoptions this is only valid for
" comments
setlocal textwidth=79
set formatoptions=qrocb

" Do not wrap lines automatically
setlocal nowrap

" Correct indentation after opening a phpdocblock and automatic * on every
" line
setlocal formatoptions=qroct

" Use php syntax check when doing :make
setlocal makeprg=php\ -l\ %

" Use errorformat for parsing PHP error output
setlocal errorformat=%m\ in\ %f\ on\ line\ %l

" Switch syntax highlighting on, if it was not
syntax on

" Use pman for manual pages
" $ pear install doc.php.net/pman
setlocal keywordprg=pman

" }}} Settings

" {{{ Command mappings

" Map ; to run PHP parser check
" noremap ; :!php5 -l %<CR>

" Map ;; to "add ; to the end of the line, when missing"
" noremap <buffer> ; :s/\([^;]\)$/\1;/<cr>
noremap <buffer> ;; :s/\([^;]\)$/\1;/<cr>

" DEPRECATED in favor of PDV documentation (see below!)
" Map <CTRL>-P to run actual file with PHP CLI
" noremap <C-P> :w!<CR>:!php5 %<CR>

" Map <ctrl>+p to single line mode documentation (in insert and command mode)
" inoremap <buffer> <C-P> :call PhpDocSingle()<CR>i
" nnoremap <buffer> <C-P> :call PhpDocSingle()<CR>
inoremap <leader>d :call PhpDocSingle()<CR>i
nnoremap <leader>d :call PhpDocSingle()<CR>

" Map <ctrl>+p to multi line mode documentation (in visual mode)
" vnoremap <buffer> <C-P> :call PhpDocRange()<CR>
vnoremap <leader>d :call PhpDocRange()<CR>

" Map <CTRL>-H to search phpm for the function name currently under the cursor (insert mode only)
" inoremap <buffer> <C-H> <ESC>:!phpm <C-R>=expand("<cword>")<CR><CR>
inoremap <leader>h <ESC>:!phpm <C-R>=expand("<cword>")<CR><CR>

" Map <CTRL>-a to alignment function
" vnoremap <buffer> <C-a> :call PhpAlign()<CR>
vnoremap <leader>a :call PhpAlign()<CR>

" Map <CTRL>-a to (un-)comment function
" vnoremap <buffer> <C-c> :call PhpUnComment()<CR>
vnoremap <leader>u :call PhpUnComment()<CR>

" }}}

" {{{ Automatic close char mapping

" More common in PEAR coding standard
" inoremap <buffer>  { {<CR>}<C-O>O
" Maybe this way in other coding standards
inoremap  { {<CR>}<C-O>O

inoremap <buffer> [ []<LEFT>

" Standard mapping after PEAR coding standard
" inoremap <buffer> ( ( )<LEFT><LEFT>
inoremap <buffer> ( ()<LEFT>

" Maybe this way in other coding standards
" inoremap ( ( )<LEFT><LEFT> 

inoremap <buffer> " ""<LEFT>
inoremap <buffer> ' ''<LEFT>

" }}} Automatic close char mapping

" {{{ Wrap visual selections with chars

:vnoremap <buffer> ( "zdi(<C-R>z)<ESC>
:vnoremap <buffer> { "zdi{<C-R>z}<ESC>
:vnoremap <buffer> [ "zdi[<C-R>z]<ESC>
:vnoremap <buffer> ' "zdi'<C-R>z'<ESC>
" Removed in favor of register addressing
" :vnoremap " "zdi"<C-R>z"<ESC>

" }}} Wrap visual selections with chars

" {{{ Dictionary completion

" The completion dictionary is provided by Rasmus:
" http://lerdorf.com/funclist.txt
" setlocal dictionary-=/home/dotxp/funclist.txt dictionary+=/home/dotxp/funclist.txt
setlocal dictionary-=~/.vim/bundle/phpdoc/funclist.txt dictionary+=~/.vim/bundle/phpdoc/funclist.txt

" Use the dictionary completion
setlocal complete-=k complete+=k

" }}} Dictionary completion

" {{{ Autocompletion using the TAB key

" This function determines, wether we are on the start of the line text (then tab indents) or
" if we want to try autocompletion
func! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction

" Remap the tab key to select action with InsertTabWrapper
inoremap <buffer> <tab> <c-r>=InsertTabWrapper()<cr>

" }}} Autocompletion using the TAB key

" {{{ Alignment

func! PhpAlign() range
    let l:paste = &g:paste
    let &g:paste = 0

    let l:line        = a:firstline
    let l:endline     = a:lastline
    let l:maxlength = 0
    while l:line <= l:endline
		" Skip comment lines
		if getline (l:line) =~ '^\s*\/\/.*$'
			let l:line = l:line + 1
			continue
		endif
		" \{-\} matches ungreed *
        let l:index = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\S\{0,1}=\S\{0,1\}\s.*$', '\1', "") 
        let l:indexlength = strlen (l:index)
        let l:maxlength = l:indexlength > l:maxlength ? l:indexlength : l:maxlength
        let l:line = l:line + 1
    endwhile
    
	let l:line = a:firstline
	let l:format = "%s%-" . l:maxlength . "s %s %s"
    
	while l:line <= l:endline
		if getline (l:line) =~ '^\s*\/\/.*$'
			let l:line = l:line + 1
			continue
		endif
        let l:linestart = substitute (getline (l:line), '^\(\s*\).*', '\1', "")
        let l:linekey   = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\(\S\{0,1}=\S\{0,1\}\)\s\(.*\)$', '\1', "")
        let l:linesep   = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\(\S\{0,1}=\S\{0,1\}\)\s\(.*\)$', '\2', "")
        let l:linevalue = substitute (getline (l:line), '^\s*\(.\{-\}\)\s*\(\S\{0,1}=\S\{0,1\}\)\s\(.*\)$', '\3', "")

        let l:newline = printf (l:format, l:linestart, l:linekey, l:linesep, l:linevalue)
        call setline (l:line, l:newline)
        let l:line = l:line + 1
    endwhile
    let &g:paste = l:paste
endfunc

" }}}   

" {{{ (Un-)comment

func! PhpUnComment() range
    let l:paste = &g:paste
    let &g:paste = 0

    let l:line        = a:firstline
    let l:endline     = a:lastline

	while l:line <= l:endline
		if getline (l:line) =~ '^\s*\/\/.*$'
			let l:newline = substitute (getline (l:line), '^\(\s*\)\/\/ \(.*\).*$', '\1\2', '')
		else
			let l:newline = substitute (getline (l:line), '^\(\s*\)\(.*\)$', '\1// \2', '')
		endif
		call setline (l:line, l:newline)
		let l:line = l:line + 1
	endwhile

    let &g:paste = l:paste
endfunc

" }}}
