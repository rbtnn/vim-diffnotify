

# vim-diffnotify

This plugin notifies if there is a difference in the current directory is a git repository.


## Variables

### g:diffnotify_disabled (default: `v:false`)
Disable this plugin if this value is `v:true`.

### g:diffnotify_threshold (default: `50`)
The threshold for judgement of a difference.

### g:diffnotify_timespan (default: `1000 * 60`)
The checking timespan(millisecond).

### g:diffnotify_arguments (default: `''`)
The arguments of the git-diff command.



## Build-in Styles

The following is the styles contained this plugin.  
If You want to the style, please you put it in your .vimrc.

### Echo (default)

```
call diffnotify#styles#echo()
```
![](https://raw.githubusercontent.com/rbtnn/vim-diffnotify/master/diffnotify_echo.png)



### Tabline

```
call diffnotify#styles#tabline()
```
![](https://raw.githubusercontent.com/rbtnn/vim-diffnotify/master/diffnotify_tabline.png)

