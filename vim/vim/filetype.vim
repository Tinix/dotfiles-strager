" markdown filetype file

if exists("did\_load\_filetypes")
 finish
endif

augroup markdown
  au!
  au BufRead,BufNewFile *.md setfiletype mkd
  au BufRead *.md  set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END

augroup kitten
  au!
  au BufRead,BufNewFile *.ktn setfiletype kitten
augroup END

augroup objdump
  au!
  au BufRead,BufNewFile *.objdump setfiletype objdump
augroup END
