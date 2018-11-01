module Main exposing (main)

import Browser
import Html as H exposing (Html)
import Html.Attributes as H
import Html.Events as H


type alias Model =
    { text : String }


initialModel : Model
initialModel =
    { text = "" }


type Msg
    = InputText String


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputText txt ->
            { model | text = txt }


view : Model -> Html Msg
view model =
    H.div [ H.class "container" ]
        [ header
        , textArea model
        ]


header : Html Msg
header =
    H.div [ H.class "header" ]
        [ H.text "Peer Bin"
        ]


textArea : Model -> Html Msg
textArea model =
    H.div [ H.class "code-area" ]
        [ H.textarea
            [ H.placeholder "Enter code here"
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
