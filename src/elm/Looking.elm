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
    H.div []
        [ H.text model.text
        ]
