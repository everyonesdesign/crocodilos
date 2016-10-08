import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App
import Random
import Array
import Dictionary exposing (..)


-- MODEL

type alias Model = {
    word: Maybe String,
    dictionary: Dictionary
}


-- UPDATE

type Msg = GetNewWord | NewWord Int

getNewWordCmd : Model -> Cmd Msg
getNewWordCmd model =
    let
        wordsLength = (Array.length model.dictionary.words) - 1
        in
            Random.generate NewWord (Random.int 0 wordsLength)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    let
        wordsLength = (Array.length model.dictionary.words) - 1
    in
        case msg of
            GetNewWord ->
                (model, getNewWordCmd model)
            NewWord index ->
                ({model | word = Array.get index model.dictionary.words}, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
  let
    word : Maybe String
    word = model.word

    getMarkup : String -> Html Msg
    getMarkup givenWord =
        div [class "container app-container text-center"] [
            div [class "row"] [
                div [class "col-sm-12 col-xs-12"] [
                    div [class "word"] [
                        div [class "word-body"] [
                            text givenWord
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
                    button [
                        class "btn btn-primary",
                        onClick GetNewWord
                    ] [text "Новое слово!"]
                ]
            ]
        ]
  in
    case word of
      Just string -> getMarkup string
      Nothing -> getMarkup ""


-- INIT

model = {
        word = Nothing,
        dictionary = {
            helpPattern = Nothing,
            words = Array.fromList ["hello", "cat", "dog"]
        }
    }

main =
    Html.App.program
        {
            init = (model, getNewWordCmd model),
            view = view,
            subscriptions = \m -> Sub.none,
            update = update
        }
