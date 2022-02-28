
let s:prev_context = {
	\ 'changed_files': [],
	\ 'additions': 0,
	\ 'deletions': 0,
	\ 'rootdir': '',
	\ }

function! diffnotify#reset() abort
	let g:diffnotify_context = get(g:, 'diffnotify_context', {
		\ 'changed_files': [],
		\ 'additions': 0,
		\ 'deletions': 0,
		\ 'rootdir': '',
		\ })
	if !exists('#DiffNotify')
		call diffnotify#styles#echo()
	endif
	if exists('s:timer')
		call timer_stop(s:timer)
	endif
	let s:timer = timer_start(get(g:, 'diffnotify_timespan', 1000 * 60), function('s:main'), { 'repeat': -1 })
endfunction



function! s:main(t) abort
	try
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
			let cmd = ['git', '--no-pager', 'diff', '--numstat'] + get(g:, 'diffnotify_arguments', [])
			let changed_files = []
			let additions = 0
			let deletions = 0
			for line in s:system(cmd, rootdir)
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
				\ 'rootdir': rootdir,
				\ }
			if !s:same_context(s:prev_context, g:diffnotify_context)
				if get(g:, 'diffnotify_threshold', 50) < additions + deletions
					if exists('#User#DiffNotifyThresholdOver')
						doautocmd User DiffNotifyThresholdOver
					endif
				else
					if exists('#User#DiffNotifyThresholdUnder')
						doautocmd User DiffNotifyThresholdUnder
					endif
				endif
				let s:prev_context = deepcopy(g:diffnotify_context)
			endif
		endif
	catch
	endtry
endfunction

function s:same_context(c1, c2) abort
	return (a:c1['changed_files'] == a:c2['changed_files'])
		\ && (a:c1['additions'] == a:c2['additions'])
		\ && (a:c1['deletions'] == a:c2['deletions'])
		\ && (a:c1['rootdir'] == a:c2['rootdir'])
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

function s:system(cmd, cwd) abort
	let lines = []
	if has('nvim')
		let job = jobstart(a:cmd, {
			\ 'cwd': a:cwd,
			\ 'on_stdout': function('s:system_onevent', [{ 'lines': lines, }]),
			\ 'on_stderr': function('s:system_onevent', [{ 'lines': lines, }]),
			\ })
		call jobwait([job])
	else
		let path = tempname()
		try
			if filereadable(path)
				let lines = readfile(path)
			endif
			let job = job_start(a:cmd, {
				\ 'cwd': a:cwd,
				\ 'out_io': 'file',
				\ 'out_name': path,
				\ 'err_io': 'out',
				\ })
			while 'run' == job_status(job)
			endwhile
			if filereadable(path)
				let lines = readfile(path)
			endif
		finally
			if filereadable(path)
				call delete(path)
			endif
		endtry
	endif
	return lines
endfunction

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
endfunction

