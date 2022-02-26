

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
