module Looking exposing
    ( Model
    , Msg
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


initialModel : String -> Model
initialModel txt =
    { text = txt }



{- Update -}


type Msg
    = NOP


update : Msg -> Model -> Model
update NOP model =
    model



{- View -}


view : Model -> Html Msg
view model =
    Views.wrapContainer
        [ Views.wrapHeader []
        , viewCode model
        ]


viewCode : Model -> Html Msg
viewCode model =
    Views.wrapCodeArea
        [ H.div [ H.class "text" ]
            [ H.pre []
                [ H.code [ H.class "python" ]
                    [ H.text model.text
                    ]
                ]
            ]
        ]
