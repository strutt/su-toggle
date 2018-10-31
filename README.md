# su-toggle

Quickly toggle between editing the currently visited buffer as the super user.

Emacs can edit files as the super user with tramp.
e.g. to edit `/etc/hosts` which requires you to be root, you can do

``` elisp
(find-file "/sudo:root@localhost:/etc/hosts")
```

I use this feature all the time, but writing /sudo:root@localhost: repeatedly is a pain.

Enter su-toggle.

## Useage

`M-x su-toggle`

## Setup

### init.el
With [use-package](https://github.com/jwiegley/use-package) add the following to your init.el


``` elisp
(use-package su-toggle
	:bind ("C-c s t" . su-toggle) ;; or whatever keys you like
	)
```

### Customizing the tramp prefix
`su-toggle-tramp-prefix` is a string variable that gets inserted in front of (or removed from) the current buffer file name.
By default it is `"/sudo:root@localhost:"`.
It can be customized.
