import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App
import Random
import Array
import Regex
import Http
import Task
import Json.Decode as Decode exposing (Decoder, array, maybe, object2, string, (:=))
import Dictionary exposing (Dictionary)


-- MODEL

type alias Model = {
    word: Maybe String,
    dictionary: Dictionary
}


-- UPDATE

type Msg
    = GetNewWord
    | NewWord Int
    | Fetch String
    | FetchSuccess Dictionary
    | FetchFail

getNewWordCmd : Model -> Cmd Msg
getNewWordCmd model =
    let
        wordsLength = (Array.length model.dictionary.words) - 1
    in
        Random.generate NewWord (Random.int 0 wordsLength)

fetchDictionary : String -> Cmd Msg
fetchDictionary url =
    Task.perform
        (\x -> FetchFail)
        (\dictionary -> FetchSuccess dictionary)
        (Http.get decoder url)


decoder : Decoder Dictionary
decoder =
        (object2
            (\a b -> {helpPattern = a, words = b})
            (maybe ("helpPattern" := string))
            ("words" := array string))

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
            FetchSuccess dictionary ->
                ({model | dictionary = dictionary}, getNewWordCmd model)
            FetchFail ->
                (model, Cmd.none)
            Fetch url ->
                (model, fetchDictionary url)


-- VIEW
getHelpLink : Maybe String -> String -> Html Msg
getHelpLink helpPattern word =
    case helpPattern of
        Just pattern ->
            div [class "word-wtf"] [
                a [
                    href (Regex.replace Regex.All (Regex.regex "%s") (\_ -> word) pattern),
                    target "_blank"
                ] [
                    text "Что это?"
                ]
            ]
        Nothing ->
            Html.text ""

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
                            getHelpLink model.dictionary.helpPattern givenWord
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
            helpPattern = Just "",
            words = Array.fromList []
        }
    }

main = Html.App.program {
        init = (model, fetchDictionary "dicts/test.json"),
        view = view,
        subscriptions = \m -> Sub.none,
        update = update
    }
