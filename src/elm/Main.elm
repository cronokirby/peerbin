module Main exposing (main)

import Browser
import Html as H exposing (Html, form)
import Html.Attributes as H
import Html.Events as H


type alias Model =
    { text : String
    , languageInput : String
    , language : String
    }


initialModel : Model
initialModel =
    { text = ""
    , languageInput = "plaintext"
    , language = "plaintext"
    }


type Msg
    = InputText String
    | InputLanguage String
    | SetLanguage


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputText txt ->
            { model | text = txt }

        InputLanguage lang ->
            { model | languageInput = lang }

        SetLanguage ->
            { model | language = model.languageInput }


view : Model -> Html Msg
view model =
    H.div [ H.class "container" ]
        [ header model
        , textArea model
        ]


header : Model -> Html Msg
header model =
    H.div [ H.class "header" ]
        [ H.div [ H.class "header-title" ]
            [ H.text model.language
            ]
        , H.div [ H.class "header-lang" ]
            [ H.input
                [ H.onInput InputLanguage
                , H.value model.languageInput
                , H.onSubmit SetLanguage
                ]
                []
            , H.button [ H.onClick SetLanguage ]
                [ H.text "set"
                ]
            ]
        ]

languageForm : Model -> Html Msg
languageForm model =
    H.div [ H.class "header-lang" ]
        [ form []
            [ H.input 
                [ H.type_ "text" 
                , H.value model.languageInput
                , H.onInput InputLanguage
                ]
                []
            ]
        ]

textArea : Model -> Html Msg
textArea model =
    H.div [ H.class "code-area" ]
        [ H.textarea
            [ H.placeholder "Enter code here"
            , H.spellcheck False
            , H.onInput InputText
            ]
            []
        ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
