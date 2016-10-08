module Dictionary exposing (..)

import Array exposing (Array)

type alias Dictionary = {
    helpPattern: Maybe String,
    words: Array String
}
