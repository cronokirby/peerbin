port module Main exposing (main)

import Browser
import Editing
import Html as H exposing (Html, form, map)
import Html.Attributes as H
import Html.Events as H
import Json.Encode as E
import Looking


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



{- Ports -}


port client : E.Value -> Cmd msg


makeHighlight : String -> String -> E.Value
makeHighlight style text =
    let
        highlight =
            E.object
                [ ( "style", E.string style )
                , ( "text", E.string text )
                ]
    in
    E.object
        [ ( "highlight", highlight )
        ]



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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( EditingMsg Editing.Share, Editing mod ) ->
            ( Looking (Looking.initialModel mod.text)
            , Cmd.none
            )

        ( EditingMsg msg1, Editing model1 ) ->
            ( Editing <| Editing.update msg1 model1, Cmd.none )

        ( LookingMsg msg1, Looking model1 ) ->
            case Looking.update msg1 model1 of
                ( newModel, Looking.RedoHighlighting style txt ) ->
                    ( Looking newModel
                    , client <| makeHighlight style txt
                    )

                ( newModel, _ ) ->
                    ( Looking newModel, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



{- Subscriptions -}


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



{- View -}


view : Model -> Html Msg
view model =
    case model of
        Editing m ->
            map EditingMsg <| Editing.view m

        Looking m ->
            map LookingMsg <| Looking.view m
