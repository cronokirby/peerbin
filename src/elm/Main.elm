port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Editing
import Html as H exposing (Html, form, map)
import Html.Attributes as H
import Html.Events as H
import Json.Decode as D
import Json.Encode as E
import Looking
import Routes exposing (Route(..), parseRoute, routeUrl)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> NoOP
        , onUrlChange = UrlChange
        }



{- Ports -}


port outClient : E.Value -> Cmd msg


port inClient : (D.Value -> msg) -> Sub msg


type OutInfo
    = Highlight String String
    | Seed String


sendOut : OutInfo -> Cmd msg
sendOut info =
    case info of
        Highlight style text ->
            let
                highlight =
                    E.object
                        [ ( "style", E.string style )
                        , ( "text", E.string text )
                        ]
            in
            E.object [ ( "highlight", highlight ) ]
                |> outClient

        Seed txt ->
            E.object [ ( "seed", E.string txt ) ]
                |> outClient


type alias Id =
    String


type Info
    = TextArrived Id String


infoDecoder : D.Decoder Info
infoDecoder =
    D.field "textArrived" <|
        D.map2 TextArrived
            (D.field "id" D.string)
            (D.field "text" D.string)


decodeInfo : D.Value -> Maybe Info
decodeInfo =
    D.decodeValue infoDecoder >> Result.toMaybe



{- Model -}


type InnerModel
    = Editing Editing.Model
    | Looking Id Looking.Model


routeModel : Url -> InnerModel
routeModel url =
    case parseRoute url of
        NotFound ->
            Looking "" <| Looking.initialModel "Not Found"

        NewPaste ->
            Editing <| Editing.initialModel

        Paste id ->
            Looking id <| Looking.initialModel "Loading"

diffrouteModel : Url -> InnerModel -> InnerModel
diffrouteModel url model =
    case (parseRoute url, model) of
        (Paste id1, Looking id2 lmodel) ->
            if id1 == id2 
                then Looking id2 lmodel 
                else routeModel url
        (_, _) ->
            routeModel url


type alias Model =
    { key : Nav.Key
    , inner : InnerModel
    }


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key, inner = routeModel url }, Cmd.none )



{- Update -}


type InnerMsg
    = EditingMsg Editing.Msg
    | LookingMsg Looking.Msg


type Msg
    = InnerMsg InnerMsg
    | UrlChange Url
    | Incoming Info
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

        ( UrlChange url, _ ) ->
            ( { model | inner = diffrouteModel url model.inner }, Cmd.none )

        ( Incoming (TextArrived id txt), _ ) ->
            ( { model | inner = Looking id <| Looking.initialModel txt }
            , Nav.pushUrl model.key <| routeUrl (Paste id)
            )

        ( NoOP, _ ) ->
            ( model, Cmd.none )


updateInner : InnerMsg -> InnerModel -> ( InnerModel, Cmd Msg )
updateInner msg model =
    case ( msg, model ) of
        ( EditingMsg Editing.Share, Editing mod ) ->
            ( model, sendOut (Seed mod.text) )

        ( EditingMsg msg1, Editing model1 ) ->
            ( Editing <| Editing.update msg1 model1, Cmd.none )

        ( LookingMsg msg1, Looking id model1 ) ->
            case Looking.update msg1 model1 of
                ( newModel, Looking.RedoHighlighting style txt ) ->
                    ( Looking id newModel
                    , sendOut (Highlight style txt)
                    )

                ( newModel, _ ) ->
                    ( Looking id newModel, Cmd.none )

        ( EditingMsg _, Looking _ _ ) ->
            ( model, Cmd.none )

        ( LookingMsg _, Editing _ ) ->
            ( model, Cmd.none )



{- Subscriptions -}


subscriptions : Model -> Sub Msg
subscriptions _ =
    inClient <|
        \val ->
            case decodeInfo val of
                Nothing ->
                    NoOP

                Just info ->
                    Incoming info



{- View -}


view : Model -> Browser.Document Msg
view model =
    { title = "Peer Bin", body = [ map InnerMsg <| viewInner model.inner ] }


viewInner : InnerModel -> Html InnerMsg
viewInner model =
    case model of
        Editing m ->
            map EditingMsg <| Editing.view m

        Looking _ m ->
            map LookingMsg <| Looking.view m
