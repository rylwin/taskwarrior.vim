let s:history_file  = g:task_log_directory.'/.vim_tw.history'
let s:bookmark_file = g:task_log_directory.'/.vim_tw.bookmark'

function! taskwarrior#log#history(action)
    if findfile(s:history_file) == ''
        call system('touch '.s:history_file)
    endif
    if a:action == 'write' && filewritable(s:history_file) && b:hist == 1
        let last = system('tail -n 1 '.s:history_file)
        let numb = str2nr(system('wc -l '.s:history_file))
        if last == b:command.'|||'.b:filter.'|||'.b:rc
            return
        endif
        if numb > g:task_log_max
            call system('sed -i -e "1d" '.s:history_file)
        endif
        execute 'redir >> '.s:history_file
            silent! echo b:command.'|||'.b:filter.'|||'.b:rc
        redir END
    elseif a:action == 'read' && filereadable(s:history_file)
        return = split(system('tail -n '.b:hist.' '.s:history_file.' | head -n 1'), '|||')
    elseif a:action == 'clear'
        call system('rm -f '.s:history_file)
    elseif a:action == 'previous'
        let hlist = split(substitute(system('tail -n '.(b:hist+1).' '.s:history_file.' | head -n 1'), '\v($|\n)', ' ', ''), '|||')
        if len(hlist) != 3
            return
        endif
        let b:hist    += 1
        let [b:command, b:filter, b:rc] = hlist
        call taskwarrior#list()
    elseif a:action == 'next'
        let b:hist     = b:hist > 1 ? b:hist-1 : 1
        let [b:command, b:filter, b:rc] = split(substitute(system('tail -n '.b:hist.' '.s:history_file.' | head -n 1'), '\v($|\n)', ' ', ''), '|||')
        call taskwarrior#list()
    endif
endfunction
