

# vim-diffnotify

This plugin notifies if there is a big difference in the current directory is a git repository.

![](https://raw.githubusercontent.com/rbtnn/vim-diffnotify/master/diffnotify.png)

## Variables

### g:diffnotify_disabled (default: `v:false`)
Disable this plugin if this value is `v:true`.

### g:diffnotify_threshold (default: `50`)
The threshold for judgement of a big difference.

### g:diffnotify_timespan (default: `1000 * 60`)
The checking timespan(millisecond).

## My Recommended Settings

The following is the recommended settings in my .vimrc.

```
augroup DiffNotify
	autocmd!
	autocmd User DiffNotify
		\ :let &showtabline = 2
		\ |let &tabline =
		\   printf('%%#TabLine#%d changed files with %d additions and %d deletions.',
		\   len(g:diffnotify_context['changed_files']),
		\   g:diffnotify_context['additions'],
		\   g:diffnotify_context['deletions'])
augroup END
let g:diffnotify_threshold = 0
let g:diffnotify_timespan = 1000
```

![](https://raw.githubusercontent.com/rbtnn/vim-diffnotify/master/diffnotify_recommended.png)

