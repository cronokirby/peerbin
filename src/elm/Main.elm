port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Editing
import Html as H exposing (Html, form, map)
import Html.Attributes as H
import Html.Events as H
import Json.Encode as E
import Looking
import Routes exposing (Route(..), parseRoute)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> NoOP
        , onUrlChange = \_ -> NoOP
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


type InnerModel
    = Editing Editing.Model
    | Looking Looking.Model


type alias Model =
    { key : Nav.Key
    , inner : InnerModel
    }


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        inner =
            case parseRoute url of
                NotFound ->
                    Looking <| Looking.initialModel "Not Found"

                NewPaste ->
                    Editing Editing.initialModel

                Paste id ->
                    Looking <| Looking.initialModel id
    in
    ( { key = key, inner = inner }, Cmd.none )



{- Update -}


type InnerMsg
    = EditingMsg Editing.Msg
    | LookingMsg Looking.Msg


type Msg
    = InnerMsg InnerMsg
    | NoOP


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( InnerMsg m, _ ) ->
            let
                ( newInner, cmd ) =
                    updateInner m model.inner
            in
            ( { model | inner = newInner }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )


updateInner : InnerMsg -> InnerModel -> ( InnerModel, Cmd Msg )
updateInner msg model =
    case ( msg, model ) of
        ( EditingMsg Editing.Share, Editing mod ) ->
            ( Looking <| Looking.initialModel mod.text
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

        ( EditingMsg _, Looking _ ) ->
            ( model, Cmd.none )

        ( LookingMsg _, Editing _ ) ->
            ( model, Cmd.none )



{- Subscriptions -}


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



{- View -}


view : Model -> Browser.Document Msg
view model =
    { title = "Peer Bin", body = [ map InnerMsg <| viewInner model.inner ] }


viewInner : InnerModel -> Html InnerMsg
viewInner model =
    case model of
        Editing m ->
            map EditingMsg <| Editing.view m

        Looking m ->
            map LookingMsg <| Looking.view m
