module Crocodilos.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Html.App
import Random
import Array
import Regex
import Http
import Task
import Capitalize
import Json.Decode as Json exposing (Decoder, array, maybe, object2, string, (:=))
import Crocodilos.Dictionary exposing (Dictionary)


-- MODEL

type alias Model = {
    word: Maybe String,
    selectedUrl: String,
    isFetching: Bool,
    dictionaries: List { name: String, url: String },
    dictionary: Maybe Dictionary
}


-- UPDATE

type Msg
    = GetNewWord
    | NewWord Int
    | Fetch
    | FetchSuccess Dictionary
    | FetchFail
    | ToggleDictionary String

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
        (Http.get decoder model.selectedUrl)


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
            let newModel = {model | dictionary = Just dictionary, isFetching = False}
            in (newModel, getNewWordCmd newModel)
        FetchFail ->
            ({model | isFetching = False}, Cmd.none)
        Fetch ->
            let newModel = {model | isFetching = True}
            in (newModel, fetchDictionary newModel)
        ToggleDictionary newUrl ->
            let newModel = {model | selectedUrl = newUrl}
            in (newModel, fetchDictionary newModel)


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

onChange tagger =
  on "change" (Json.map tagger targetValue)

view : Model -> Html Msg
view model =
    let
        getMarkup : String -> Html Msg
        getMarkup givenWord =
            div [] [
                select [onChange ToggleDictionary, class "dictSelect-"]
                    (List.map
                        (\dict -> option [value dict.url] [text dict.name])
                        model.dictionaries),

                div [class "word-"] [
                    div [class "word-body"] [
                        text (Capitalize.toCapital givenWord)
                    ],
                    getHelpLink model.dictionary givenWord
                ],
                div [class "word-buttonContainer"] [
                    button [
                        class "word-button",
                        onClick GetNewWord
                    ] [text "Новое слово!"]
                ]
            ]
    in
        case (model.word, model.isFetching) of
            (Just string, False) -> getMarkup string
            (_, _) -> getMarkup "..."


-- INIT

type alias Flags = {
    dictionaries: List { name: String, url: String }
}

init : Flags -> (Model, Cmd Msg)
init flags =
    let
        model = {
                word = Nothing,
                dictionaries = flags.dictionaries,
                isFetching = False,
                selectedUrl =
                    case (List.head flags.dictionaries) of
                        Just obj -> obj.url
                        Nothing -> "",
                dictionary = Nothing
            }
    in
        (model, (fetchDictionary model))

main = Html.App.programWithFlags {
        init = init,
        view = view,
        subscriptions = \m -> Sub.none,
        update = update
    }
