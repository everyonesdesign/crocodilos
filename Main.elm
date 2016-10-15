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
    dictionaryUrl: String,
    dictionary: Maybe Dictionary
}


-- UPDATE

type Msg
    = GetNewWord
    | NewWord Int
    | Fetch
    | FetchSuccess Dictionary
    | FetchFail

getNewWordCmd : Model -> Cmd Msg
getNewWordCmd model =
    case model.dictionary of
        Just dictionary ->
            let
                wordsLength = (Array.length dictionary.words) - 1
            in
                Random.generate NewWord (Random.int 0 wordsLength)
        Nothing ->
            Cmd.none

fetchDictionary : Model -> Cmd Msg
fetchDictionary model =
    Task.perform
        (\x -> FetchFail)
        (\dictionary -> FetchSuccess dictionary)
        (Http.get decoder model.dictionaryUrl)


decoder : Decoder Dictionary
decoder =
        (object2
            (\a b -> {helpPattern = a, words = b})
            (maybe ("helpPattern" := string))
            ("words" := array string))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetNewWord ->
            (model, getNewWordCmd model)
        NewWord index ->
            case model.dictionary of
                Just dict ->
                    ({model | word = Array.get index dict.words}, Cmd.none)
                Nothing ->
                    ({model | word = Nothing}, Cmd.none)
        FetchSuccess dictionary ->
            let 
                newModel = {model | dictionary = Just dictionary}
            in 
                (newModel, getNewWordCmd newModel)
        FetchFail ->
            (model, Cmd.none)
        Fetch ->
            (model, fetchDictionary model)


-- VIEW

getHelpLink : Maybe Dictionary -> String -> Html Msg
getHelpLink dictionary word =
    case dictionary of
        Just dictionary ->
            case dictionary.helpPattern of 
                Just pattern ->
                    div [class "word-wtfContainer"] [
                        a [
                            href (Regex.replace Regex.All (Regex.regex "%s") (\_ -> word) pattern),
                            target "_blank",
                            class "word-wtf"
                        ] [
                            text "Что это?"
                        ]
                    ]
                Nothing -> Html.text ""

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
                        div [class "word-"] [
                            div [class "word-body"] [
                                text givenWord
                            ],
                            getHelpLink model.dictionary givenWord
                        ]
                    ]
                ],
                div [class "row"] [
                    div [class "word-buttonContainer col-sm-12 col-xs-12"] [
                        button [
                            class "word-button",
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
        dictionaryUrl = "dicts/test.json",
        dictionary = Nothing
    }

main = Html.App.program {
        init = (model, (fetchDictionary model)),
        view = view,
        subscriptions = \m -> Sub.none,
        update = update
    }
