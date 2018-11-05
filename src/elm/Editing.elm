module Editing exposing
    ( Model
    , Msg(..)
    , initialModel
    , update
    , view
    )

import FeatherIcons as Icons
import Html as H exposing (Html)
import Html.Attributes as H
import Html.Events as H
import Views



{- Model -}


type alias Model =
    { text : String
    , lang : String
    }


initialModel : Model
initialModel =
    { text = "", lang = "plaintext" }



{- Update -}


type Msg
    = InputText String
    | InputLang String
    | Share


update : Msg -> Model -> Model
update msg model =
    case msg of
        InputText txt ->
            { model | text = txt }

        InputLang txt ->
            { model | lang = txt }

        -- This is handled by the parent component
        Share ->
            model



{- View -}


view : Model -> Html Msg
view model =
    Views.wrapContainer
        [ header model
        , textArea model
        ]


header : Model -> Html Msg
header model =
    Views.wrapHeader
        [ Views.langInput InputLang Share model.lang Icons.share
        ]


textArea : Model -> Html Msg
textArea model =
    Views.wrapCodeArea <|
        [ H.textarea
            [ H.class "text"
            , H.placeholder "Enter your code here"
            , H.spellcheck False
            , H.onInput InputText
            ]
            []
        ]
