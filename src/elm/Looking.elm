module Looking exposing
    ( Model
    , Msg
    , ParentMsg(..)
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


initialModel : String -> String -> Model
initialModel txt lang =
    { text = txt
    , lang = lang
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
        [ Views.wrapHeader
            [ Views.langInput ChangeLang SubmitLang model.lang Icons.edit
            ]
        , viewCode model
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
