```
 █████╗ ███╗   ██╗██╗███╗   ███╗ █████╗ ████████╗███████╗  ██╗   ██╗██╗███╗   ███╗
██╔══██╗████╗  ██║██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝  ██║   ██║██║████╗ ████║
███████║██╔██╗ ██║██║██╔████╔██║███████║   ██║   █████╗    ██║   ██║██║██╔████╔██║
██╔══██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝    ╚██╗ ██╔╝██║██║╚██╔╝██║
██║  ██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗██╗╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝ ╚═══╝  ╚═╝╚═╝     ╚═╝
```

# Animate.vim

A Vim Window Animation Library

`Animate.vim` is a general window animation library for Vim, it provides the ability
to animate window height and width via:

- `delta` from current size
- `percent` of screen
- `absolute` size

![](https://i.ibb.co/2dkt3cC/Animate2-opt.gif)

## Installation

To install `Animate.vim`, use your plugin manager of choice, e.g:

```
Plug 'camspiers/animate.vim'
```

## Usage

Given the general purpose nature of resizing windows `Animate.vim` can be used in many contexts.

The following gives and example of using animate to more smoothly change window size using the directional keys:

### Example: Animated Directional Keys

```
nnoremap <silent> <Up>    :call animate#window_delta_height(10)<CR>
nnoremap <silent> <Down>  :call animate#window_delta_height(-10)<CR>
nnoremap <silent> <Left>  :call animate#window_delta_width(10)<CR>
nnoremap <silent> <Right> :call animate#window_delta_width(-10)<CR>
```

### Example: Animated FZF Bottom Drawer

Here is an example that integrates `Animate.vim` with Fuzzy Finder (FZF) to animate its opening:

```
let g:fzf_layout = {
 \ 'window': 'new | wincmd J | resize 1 | call animate#window_percent_height(0.5)'
\ }
```

### Example: Animated Neovim Terminal Drawer

```
function! OpenAnimatedHtop() abort
  " Open a htop in terminal
  new term://htop
  " Send window to bottom and start with small height
  wincmd J | resize 1
  " Animate height to 66%
  call animate#window_percent_height(0.66)
endfunction
```

## Options

### Duration

Animation duration in milliseconds can be controlled via a global flag:

```
let g:animate#duration = 300.0
```

### Easing

Animation easing can be controlled via a global flag:

```
let g:animate#easing_func = 'animate#ease_linear'
```

#### Easing Options

Currently there are 3 easing options available:

- `animate#ease_linear`
- `animate#ease_out_quad`
- `animate#ease_out_cubic`

To set a custom easing function:

```
let g:animate#easing_func = 'animate#ease_out_cubic'
```

You can also set your own easing function using the following signature:

```
function! MyEasingFunction(elapsed, initial, delta, duration) abort
  " return value
endfunction

let g:animate#easing_func = 'MyEasingFunction'
```

## API

### Delta Functions

Animate current window by delta:

```
animate#window_delta(width_delta, height_delta)
```

Animate current window by width delta:

```
animate#window_delta_width(delta)
```

Animate current window by height delta:

```
animate#window_delta_height(delta)
```

### Percent Functions

Animate current window by percent of screen:

```
animate#window_percent(width_percent, height_percent)
```

Animate current window by percent of screen width:

```
animate#window_percent_width(percent)
```

Animate current window by percent of screen height:

```
animate#window_percent_height(percent)
```

### Absolute Functions

Animate current window to absolute size:

```
animate#window_absolute(width, height)
```

Animate current window by absolute width:

```
animate#window_absolute_width(width)
```

Animate current window by absolute height:

```
animate#window_absolute_height(height)
```

### Helper Functions

Get the current time as a float in milliseconds:

```
animate#time()
```

Get the available height factoring in cmdheight and status line:

```
animate#get_available_height()
```

Linear easing function:

```
animate#ease_linear(elapsed, initial, delta, duration)
```

Out quad easing function:

```
animate#ease_out_quad(elapsed, initial, delta, duration)
```

Out cubic easing function:

```
animate#ease_out_cubic(elapsed, initial, delta, duration)
```
