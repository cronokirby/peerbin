module Looking exposing
    ( Model
    , Msg
    , ParentMsg(..)
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
    , lang : String
    }


initialModel : String -> Model
initialModel txt =
    { text = txt
    , lang = "plaintext"
    }



{- Update -}


type Msg
    = ChangeLang String
    | SubmitLang


type ParentMsg
    = RedoHighlighting String String
    | NoParentMsg


update : Msg -> Model -> ( Model, ParentMsg )
update msg model =
    case msg of
        ChangeLang newLang ->
            ( { model | lang = newLang }, NoParentMsg )

        SubmitLang ->
            ( model, RedoHighlighting model.lang model.text )



{- View -}


view : Model -> Html Msg
view model =
    Views.wrapContainer
        [ Views.wrapHeader [ langInput model ]
        , viewCode model
        ]


langInput : Model -> Html Msg
langInput model =
    H.div [ H.class "language-input" ]
        [ H.input
            [ H.type_ "text"
            , H.onInput ChangeLang
            , H.value model.lang
            ]
            []
        , H.button
            [ H.onClick SubmitLang
            ]
            [ H.text "Submit"
            ]
        ]


viewCode : Model -> Html Msg
viewCode model =
    Views.wrapCodeArea
        [ H.div [ H.class "text" ]
            [ H.pre []
                [ H.code [ H.id "code-view" ]
                    [ H.text model.text
                    ]
                ]
            ]
        ]
