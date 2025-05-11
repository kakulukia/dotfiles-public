" ===========================================================================
" File: lastcursor.vim
" Description: Always restore cursor to last known position on file open
" Location: ~/.SpaceVim.d/plugin/lastcursor.vim
" DEBUG: ensure this plugin file is actually sourced on startup
  
augroup lastcursor
  autocmd!
  " After reading a buffer, jump to the last known cursor position
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
  " Also restore position on window enter
  autocmd BufWinEnter * if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END
