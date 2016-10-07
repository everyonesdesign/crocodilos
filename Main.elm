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
  div [class "container app-container text-center"] [
    div [class "row"] [
      div [class "col-sm-12 col-xs-12"] [
        div [class "word"] [
          div [class "word-body"] [
            text "Hello"
          ],
          div [class "word-wtf"] [
            a [href "#"] [
              text "Что это?"
            ]
          ]
        ]
      ]
    ],
    div [class "row"] [
      div [class "col-sm-12 col-xs-12"] [
        button [class "btn btn-primary"] [text "Новое слово!"]
      ]
    ]
  ]


main = view {}
