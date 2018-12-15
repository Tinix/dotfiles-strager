function! Test_grep_with_no_files_clears_quickfix_list()
  call s:set_up_project([])
  Grep hello
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal([], l:quickfix_items)
endfunction

function! Test_grep_finds_single_match()
  call s:set_up_project([
    \ ['readme.txt', 'hello there!'],
    \ ['other.txt', 'no match here.'],
  \ ])
  Grep hello
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('readme.txt'), l:quickfix_items[0].bufnr)
endfunction

function! Test_grep_matches_with_location()
  call s:set_up_project([
    \ ['readme.txt', "first line\nsecond line\nthird line\nand the final line\n"],
  \ ])

  Grep third
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('readme.txt'), l:quickfix_items[0].bufnr)
  call assert_equal(3, l:quickfix_items[0].lnum)
  call assert_equal(1, l:quickfix_items[0].col)

  Grep final
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('readme.txt'), l:quickfix_items[0].bufnr)
  call assert_equal(4, l:quickfix_items[0].lnum)
  call assert_equal(len('and the ') + 1, l:quickfix_items[0].col)
endfunction

function! Test_grep_matches_multiple_files()
  call s:set_up_project([
    \ ['dates.txt', "january third\njanuary thirty?\n"],
    \ ['readme.txt', "first line\nsecond line\nthird line\nfourth line\n"],
  \ ])
  Grep third
  let l:readme_quickfix_items = s:get_quickfix_items_for_buffer_name('readme.txt')
  call assert_equal(1, len(l:readme_quickfix_items))
  let l:dates_quickfix_items = s:get_quickfix_items_for_buffer_name('dates.txt')
  call assert_equal(1, len(l:dates_quickfix_items))
endfunction

function! Test_grep_with_explicit_directory_finds_single_match_in_subdirectory()
  call s:set_up_project([
    \ ['readme.txt', 'hello there!'],
    \ ['searcheddir/readme.txt', 'why, hello!'],
  \ ])
  Grep hello searcheddir
  let l:quickfix_items = getqflist({'all': v:true}).items
  call assert_equal(1, len(l:quickfix_items))
  call assert_equal(bufnr('searcheddir/readme.txt'), l:quickfix_items[0].bufnr)
endfunction

function! Test_tab_in_grep_completes_explicit_directory()
  call s:set_up_project(['somedir/'])
  call feedkeys(":Grep pattern somed\<C-L>\<Esc>", 'tx')
  call assert_equal('Grep pattern somedir/', histget('cmd', -1))
endfunction

function! Test_grep_with_match_opens_quickfix_window()
  call s:set_up_project([['readme.txt', 'hello world']])
  call assert_false(strager#window#is_quickfix_window_open_in_current_tab())
  Grep hello
  call assert_true(strager#window#is_quickfix_window_open_in_current_tab())
endfunction

function! Test_grep_without_match_does_not_move_cursor()
  call s:set_up_project([['readme.txt', 'hello world']])
  edit readme.txt
  let l:original_buffer_number = bufnr('%')
  Grep nomatch
  call assert_equal(l:original_buffer_number, bufnr('%'))
endfunction

function! s:set_up_project(files_to_create)
  let l:project_path = strager#file#make_directory_with_files(a:files_to_create)
  exec 'cd '.fnameescape(l:project_path)
  %bwipeout!
endfunction

function! s:get_quickfix_items_for_buffer_name(buffer_name)
  let l:buffer_number = bufnr(a:buffer_name)
  let l:quickfix_items = getqflist({'all': v:true}).items
  call filter(l:quickfix_items, {_, item -> item.bufnr == l:buffer_number})
  return l:quickfix_items
endfunction

call strager#test#run_all_tests()
