" Copyright (c) 2020 Spiers, Cam <camspiers@gmail.com>
" Licensed under the terms of the MIT license.

""
"  █████╗ ███╗   ██╗██╗███╗   ███╗ █████╗ ████████╗███████╗  ██╗   ██╗██╗███╗   ███╗
" ██╔══██╗████╗  ██║██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝  ██║   ██║██║████╗ ████║
" ███████║██╔██╗ ██║██║██╔████╔██║███████║   ██║   █████╗    ██║   ██║██║██╔████╔██║
" ██╔══██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝    ╚██╗ ██╔╝██║██║╚██╔╝██║
" ██║  ██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗██╗╚████╔╝ ██║██║ ╚═╝ ██║
" ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝ ╚═══╝  ╚═╝╚═╝     ╚═╝
"
" A Vim Window Animation Library
"
" # Intro
"
" `Animate.vim` is a general window animation library for Vim, it provides the ability
" to animate window height and width via:
" 
" - `delta` from current size
" - `percent` of screen
" - `absolute` size

if exists('g:animate#loaded')
  finish
endif

let g:animate#loaded = 1

if ! exists('g:animate#duration')
  let g:animate#duration = 300.0
endif

if ! exists('g:animate#distribute_space')
  let g:animate#distribute_space = 1
endif

if exists('g:animate#easing_func')
  let g:Animate#Ease = function(g:animate#easing_func)
else
  let g:Animate#Ease = function('animate#ease_in_out_sine')
endif

let g:animate#timer_ids = {}

" Delta Functions {{{
""
" @usage width_delta height_delta
" Animates current window by delta
function! animate#window_delta(width_delta, height_delta) abort
  let target_window = winnr()

  " If the window is already animating then we are receiving another animation
  " request, stop the original timer first
  if animate#window_is_animating(target_window)
    call timer_stop(get(g:animate#timer_ids, target_window, 0))
    let g:animate#timer_ids[target_window] = 0
  endif

  " Store state so that we can access it in the step function
  let animation = {
    \ 'width_initial': winwidth(0),
    \ 'height_initial': winheight(0),
    \ 'width_delta': a:width_delta,
    \ 'height_delta': a:height_delta,
    \ 'start_time': animate#time(),
    \ 'target_window': target_window,
  \}

  " The main animation step function that is called on each interval
  function! animation.step(timer)
    " Store the target window so we can preserve the current window
    let current_window = winnr()

    " If the current window is different from the target window then we want
    " to focus the current window
    if self.target_window != current_window
      if ! animate#window_focus(self.target_window)
        call timer_stop(get(g:animate#timer_ids, self.target_window, 0))
        let g:animate#timer_ids[self.target_window] = 0
        return
      endif
    endif

    " Calculate the time elapsed
    let elapsed = min([float2nr(g:animate#duration), float2nr(animate#time() - self.start_time)])

    " Calculate the appropriate width for this amount of elapsed time
    let width = float2nr(g:Animate#Ease(elapsed, self.width_initial, self.width_delta, g:animate#duration))

    " Calculate the appropriate height for this amount of elapsed time
    let height = float2nr(g:Animate#Ease(elapsed, self.height_initial, self.height_delta, g:animate#duration))

    " Store old winfix states
    let winfixheight = &winfixheight
    let winfixwidth = &winfixwidth

    " Store old fixity states
    let nowinfixheights = {}
    let nowinfixwidths = {}

    " Perform the animation if the heights are different
    if height != winheight(0)
      " Perform the resize
      execute 'resize ' . string(height)

      " Distribute space and clean up our changes to windows
      if g:animate#distribute_space
        " Store the widths
        noautocmd silent! windo if ! &winfixwidth | let nowinfixwidths[winnr()] = 1 | set winfixwidth | endif
        " Restore focus
        call animate#window_focus(self.target_window)
        if winfixheight
          noautocmd wincmd =
        else
          set winfixheight
          noautocmd wincmd =
          set nowinfixheight
        endif
        " Restore the widths
        noautocmd silent! windo if has_key(nowinfixwidths, winnr()) | set nowinfixwidth | endif
       
        " Restore focus
        call animate#window_focus(self.target_window)
      endif
    endif

    " Perform the animation if the widths are different
    if width != winwidth(0)
      " Perform the resize
      execute 'vertical resize ' . string(width)

      " Distribute space and clean up our changes to windows
      if g:animate#distribute_space
        " Store the heights
        noautocmd windo if ! &winfixheight | let nowinfixheights[winnr()] = 1 | set winfixheight | endif
        " Restore focus
        call animate#window_focus(self.target_window)
        if winfixwidth
          wincmd =
        else
          set winfixwidth
          noautocmd wincmd =
          set nowinfixwidth
        endif
        " Restore the heights
        noautocmd windo if has_key(nowinfixheights, winnr()) | set nowinfixheight | endif
        " Restore focus
        call animate#window_focus(self.target_window)
      endif
    endif

    " If the time elapsed is less than the animation duration then schedule
    " anoanother step, otherwise remove the timer id
    if elapsed < g:animate#duration
      let g:animate#timer_ids[self.target_window] = timer_start(16, self.step)
    else
      let g:animate#timer_ids[self.target_window] = 0
    endif
  endfunction

  " Run the first step
  call animation.step(0)
endfunction

""
" @usage delta
" Animates current window by width delta
function! animate#window_delta_width(delta) abort
  call animate#window_delta(a:delta, 0)
endfunction

""
" @usage delta
" Animates current window by height delta
function! animate#window_delta_height(delta) abort
  call animate#window_delta(0, a:delta)
endfunction
" }}}

" Percent Functions {{{
""
" @usage width_percent height_percent
" Animates current window by percent of screen
function! animate#window_percent(width_percent, height_percent) abort
  call animate#window_absolute(
    \ &columns * a:width_percent,
    \ animate#get_available_height() * a:height_percent,
  \ )
endfunction

""
" @usage percent
" Animates current window by percent of screen width
function! animate#window_percent_width(percent) abort
  call animate#window_absolute(
    \ &columns * a:percent,
    \ winheight(0),
  \ )
endfunction

""
" @usage percent
" Animates current window by percent of screen height
function! animate#window_percent_height(percent) abort
  call animate#window_absolute(
    \ winwidth(0),
    \ animate#get_available_height() * a:percent,
  \ )
endfunction
" }}}

" Absolute Functions {{{
""
" @usage width height
" Animates current window to absolute size
function! animate#window_absolute(width, height) abort
  call animate#window_delta(
    \ float2nr(a:width - winwidth(0)),
    \ float2nr(a:height - winheight(0)),
  \ )
endfunction

""
" @usage width
" Animates current window by absolute width
function! animate#window_absolute_width(width) abort
  call animate#window_delta(
    \ float2nr(a:width - winwidth(0)),
    \ 0
  \ )
endfunction

""
" @usage height
" Animates current window by absolute height
function! animate#window_absolute_height(height) abort
  call animate#window_delta(
    \ 0,
    \ float2nr(a:height - winheight(0)),
  \ )
endfunction
" }}}

" Helper Functions {{{
""
" @usage
" Focuses window
function! animate#window_focus(target_window) abort
  if win_getid(a:target_window) == 0
    return v:false
  else
    execute 'noautocmd silent! '. a:target_window.'wincmd w'
    return v:true
  endif
endfunction

""
" @usage
" Determines with target window is animating
function! animate#window_is_animating(target_window) abort
  let timer_id = get(g:animate#timer_ids, a:target_window, 0)
  return timer_id != 0
endfunction

""
" @usage
" Gets the current time as a float in milliseconds
function! animate#time()
  return str2float(reltimestr(reltime())) * 1000.0
endfunction

""
" @usage
" Gets the available height factoring in cmdheight and status line
function! animate#get_available_height() abort
  return &lines - &cmdheight - (&laststatus == 0 ? 0 : 1)
endfunction

""
" @usage elapsed initial delta duration
" Linear easing function
function! animate#ease_linear(elapsed, initial, delta, duration) abort
  return a:delta * (a:elapsed / a:duration) + a:initial
endfunction

""
" @usage elapsed initial delta duration
" Out quad easing function
function! animate#ease_out_quad(elapsed, initial, delta, duration) abort
  let percent = a:elapsed / a:duration
  return -a:delta * percent * (percent - 2) + a:initial
endfunction

""
" @usage elapsed initial delta duration
" Out cubic easing function
function! animate#ease_out_cubic(elapsed, initial, delta, duration) abort
  let new_elapsed = a:elapsed / a:duration - 1
  return a:delta * (new_elapsed * new_elapsed * new_elapsed + 1) + a:initial
endfunction

""
" @usage elapsed initial delta duration
" In out sine easing function
function! animate#ease_in_out_sine(elapsed, initial, delta, duration) abort
  let percent = a:elapsed / a:duration
  let pi = 3.14159265359
  return a:delta * 0.5 * (1 - cos(pi * percent)) + a:initial
endfunction
" }}}

" vim:fdm=marker
