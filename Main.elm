import Html exposing (..)
import Html.Attributes exposing (..)


-- MODEL

type alias Model = {}


-- UPDATE

type Msg = Reset
--
--update : Msg -> Model -> Model
--update msg model =
--  case msg of
--    Reset -> ...
--    ...


-- VIEW

view : Model -> Html Msg
view model =
  div [class "container"] [
    div [class "row"] [
      select [] [
        option [] [text "Русский"]
      ],
      button [class "btn btn-default"] [text "Играть"]
    ],
    div [class "task"] [
      text "Hello"
    ]
  ]


main = view {}
