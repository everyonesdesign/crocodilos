# Crocodilos
A simple helper for charades game written in beautiful Elm language.

![Crocodilos](http://i.imgur.com/DeWy1le.png)

Demo: http://everyonesdesign.ru/apps/crocodilos/current/

Taskboard: https://trello.com/b/4vKbpXOS/crocodilos

## Concept

The app is written to try [Elm language](http://elm-lang.org/) in action. 

Experimental approach to css structuring is also used: [there's no inheritance in app's CSS](https://github.com/everyonesdesign/crocodilos/blob/master/scss/style.scss#L1).
The idea is inspired by functional programming (clear of surrounding context) and probably will increase the stylesheets maintainability
(hopefully without any noticeable CSS performance issues).

`* {all: initial}` can be used in the future although [it's not supported by IE](http://caniuse.com/#feat=css-all) at the time.

I also found an [article by Bruce Lawson](http://www.brucelawson.co.uk/2014/css-all-initial-to-prevent-widgets-inheriting-css-from-a-host-page/) suggesting a similar idea.

## Requirements

- [Make util](https://en.wikipedia.org/wiki/Make_(software))
- [Sass gem](http://sass-lang.com/install)
- [Elm lang](https://guide.elm-lang.org/get_started.html)

The app is build by running `make`.
`make deploy` is intended to be used with automatic deploy scripts and thus it agrees to all the promts it faces during the build.

## Naming

In russian language [the game](https://en.wikipedia.org/wiki/Charades) is usually called 'crocodile' for some reason. 
