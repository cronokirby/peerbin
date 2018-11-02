module Editing exposing
    ( Model
    , Msg
    , initialModel
    , update
    , view
    )

import Html as H exposing (Html, form)
import Html.Attributes as H
import Html.Events as H



{- Model -}


type alias Model =
    { text : String
    }


initialModel : Model
initialModel =
    { text = "" }



{- Update -}


type Msg
    = InputText String


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputText txt ->
            { model | text = txt }



{- View -}


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
            [ H.text "Peer Bin"
            ]
        , H.div [ H.class "share" ]
            [ H.button [] [ H.text "share" ]
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
