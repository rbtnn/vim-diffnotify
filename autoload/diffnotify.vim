
function! diffnotify#reset() abort
	let g:diffnotify_context = get(g:, 'diffnotify_context', s:new_context())
	if !exists('#DiffNotify')
		call diffnotify#styles#echo()
	endif
	if exists('s:timer')
		call timer_stop(s:timer)
	endif
	let s:timer = timer_start(get(g:, 'diffnotify_timespan', 1000 * 60), function('s:main'), { 'repeat': -1 })
endfunction



function! s:main(t) abort
	if get(g:, 'diffnotify_disabled', v:false)
		return
	endif
	if !executable('git')
		return
	endif
	if 'n' != mode()
		return
	endif
	let rootdir = s:get_gitrootdir('.')
	if !empty(rootdir)
		let params = [{ 'lines': [], 'rootdir': rootdir, }]
		let cmd = ['git', '--no-pager', 'diff', '--numstat'] + get(g:, 'diffnotify_arguments', [])
		if has('nvim')
			call jobstart(cmd, {
				\ 'cwd': rootdir,
				\ 'on_stdout': function('s:system_onevent', params),
				\ 'on_exit': function('s:system_exit_nvim', params),
				\ })
		else
			call job_start(cmd, {
				\ 'cwd': rootdir,
				\ 'out_cb': function('s:system_onevent', params),
				\ 'exit_cb': function('s:system_exit_vim', params),
				\ })
		endif
	endif
endfunction

function! s:new_context() abort
	return {
		\ 'changed_files': [],
		\ 'additions': 0,
		\ 'deletions': 0,
		\ 'rootdir': '',
		\ }
endfunction

function! s:get_gitrootdir(path) abort
	let xs = split(fnamemodify(a:path, ':p'), '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		let path = prefix .. join(xs + ['.git'], '/')
		if isdirectory(path) || filereadable(path)
			return prefix .. join(xs, '/')
		endif
		call remove(xs, -1)
	endwhile
	return ''
endfunction

if has('nvim')
	function s:system_onevent(d, job, data, event) abort
		let a:d['lines'] += a:data
		sleep 10m
	endfunction

	function s:system_exit_nvim(d, job, data, event) abort
		call s:system_exit_vim(a:d, '', '')
	endfunction
else
	function s:system_onevent(d, data, event) abort
		let a:d['lines'] += [a:event]
		sleep 10m
	endfunction
endif

function s:system_exit_vim(d, job, status) abort
	try
		let changed_files = []
		let additions = 0
		let deletions = 0
		for line in a:d['lines']
			let m = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(.\+\)$')
			if !empty(m)
				let changed_files += [m[3]]
				let additions += str2nr(m[1])
				let deletions += str2nr(m[2])
			endif
		endfor
		let g:diffnotify_context = {
			\ 'changed_files': changed_files,
			\ 'additions': additions,
			\ 'deletions': deletions,
			\ 'rootdir': a:d['rootdir'],
			\ }
		if get(g:, 'diffnotify_threshold', 50) < additions + deletions
			if exists('#User#DiffNotifyThresholdOver')
				doautocmd User DiffNotifyThresholdOver
			endif
		else
			if exists('#User#DiffNotifyThresholdUnder')
				doautocmd User DiffNotifyThresholdUnder
			endif
		endif
	catch
	endtry
endfunction

