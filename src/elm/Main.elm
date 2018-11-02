module Main exposing (main)

import Browser
import Editing
import Looking
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
    | Looking Looking.Model


initialModel : Model
initialModel =
    Editing Editing.initialModel



{- Update -}


type Msg
    = EditingMsg Editing.Msg
    | LookingMsg Looking.Msg


update : Msg -> Model -> Model
update msg model =
    case ( msg, model ) of
        ( EditingMsg Editing.Share, Editing mod) ->
            Looking (Looking.initialModel mod.text)
        ( EditingMsg msg1, Editing model1 ) ->
            Editing <| Editing.update msg1 model1
        ( LookingMsg msg1, Looking model1 ) ->
            Looking <| Looking.update msg1 model1
        ( _, _) ->
            model



{- View -}


view : Model -> Html Msg
view model =
    case model of
        Editing m ->
            map EditingMsg <| Editing.view m
        Looking m ->
            map LookingMsg <| Looking.view m
