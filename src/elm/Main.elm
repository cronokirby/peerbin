module Main exposing (main)

import Browser
import Editing
import Html as H exposing (Html, form, map)
import Html.Attributes as H
import Html.Events as H


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }



{- Model -}


type Model
    = Editing Editing.Model


initialModel : Model
initialModel =
    Editing Editing.initialModel



{- Update -}


type Msg
    = EditingMsg Editing.Msg


update : Msg -> Model -> Model
update msg model =
    case ( msg, model ) of
        ( EditingMsg msg1, Editing model1 ) ->
            Editing <| Editing.update msg1 model1



{- View -}


view : Model -> Html Msg
view model =
    case model of
        Editing m ->
            map EditingMsg <| Editing.view m
