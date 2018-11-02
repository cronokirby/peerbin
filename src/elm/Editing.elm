module Editing exposing
    ( Model
    , Msg(..)
    , initialModel
    , update
    , view
    )

import Html as H exposing (Html)
import Html.Attributes as H
import Html.Events as H
import Views



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
    | Share


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputText txt ->
            { model | text = txt }

        -- This is handled by the parent component
        Share ->
            model



{- View -}


view : Model -> Html Msg
view model =
    Views.wrapContainer
        [ header
        , textArea model
        ]


header : Html Msg
header =
    Views.wrapHeader <|
        [ H.div [ H.class "share" ]
            [ H.button [ H.onClick Share ]
                [ H.text "share"
                ]
            ]
        ]


textArea : Model -> Html Msg
textArea model =
    Views.wrapCodeArea <|
        [ H.textarea
            [ H.class "text"
            , H.placeholder "Enter code here"
            , H.spellcheck False
            , H.onInput InputText
            ]
            []
        ]
