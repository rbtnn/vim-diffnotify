
function! diffnotify#styles#echo() abort
	augroup DiffNotify
		autocmd!
		autocmd User DiffNotifyThresholdOver
			\ :echo '[diffnotify] There is a difference('
			\ |echohl DiffAdd
			\ |echon '+' .. g:diffnotify_context['additions']
			\ |echohl None
			\ |echon ', '
			\ |echohl DiffDelete
			\ |echon '-' .. g:diffnotify_context['deletions']
			\ |echohl None
			\ |echon printf(') in the directory "%s". ', g:diffnotify_context['rootdir']),
			\ )
	augroup END
endfunction

function! diffnotify#styles#tabline() abort
	augroup DiffNotify
		autocmd!
		autocmd User DiffNotifyThresholdUnder
			\ :let &showtabline = 0
		autocmd User DiffNotifyThresholdOver
			\ :let &showtabline = 2
			\ |let &tabline =
			\   printf('%%#TabLine#%d changed files with %d additions and %d deletions.',
			\   len(g:diffnotify_context['changed_files']),
			\   g:diffnotify_context['additions'],
			\   g:diffnotify_context['deletions'])
	augroup END
endfunction

