
if !executable('git')
	finish
endif

let g:loaded_diffnotify = 1

function! s:main(t) abort
	try
		if get(g:, 'diffnotify_disabled', v:false)
			return
		endif
		let rootdir = s:get_gitrootdir('.')
		if !empty(rootdir)
			let cmd = ['git', '--no-pager', 'diff', '--numstat']
			let additions = 0
			let deletions = 0
			for line in s:system(cmd, rootdir)
				let m = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+')
				if !empty(m)
					let additions += str2nr(m[1])
					let deletions += str2nr(m[2])
				endif
			endfor
			call s:notify(additions, deletions, rootdir)
		endif
	catch
	endtry
endfunction

function! s:notify(additions, deletions, rootdir) abort
	if get(g:, 'diffnotify_threshold', 50) < a:additions + a:deletions
		echomsg printf(
			\ '[diffnotify] There is a big difference(+%d, -%d) in the directory "%s". ',
			\ a:additions, a:deletions, a:rootdir)
	endif
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

if exists('s:timer')
	call timer_stop(s:timer)
endif
let s:timer = timer_start(get(g:, 'diffnotify_spantime', 1000 * 60), function('s:main'), { 'repeat' : -1 })

