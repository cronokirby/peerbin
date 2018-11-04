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
import Views


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }



{- Ports -}


port outClient : E.Value -> Cmd msg


port inClient : (D.Value -> msg) -> Sub msg


type alias Id =
    String


type OutInfo
    = Highlight String String
    | Seed String
    | Fetch Id


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

        Fetch id ->
            E.object [ ( "fetch", E.string id ) ]
                |> outClient


type Info
    = TextArrived Id String
    | NoPeers Id


infoDecoder : D.Decoder Info
infoDecoder =
    D.oneOf
        [ D.field "textArrived" <|
            D.map2 TextArrived
                (D.field "id" D.string)
                (D.field "text" D.string)
        , D.field "noPeers" <|
            D.map NoPeers
                (D.field "id" D.string)
        ]


decodeInfo : D.Value -> Maybe Info
decodeInfo =
    D.decodeValue infoDecoder >> Result.toMaybe



{- Model -}


type InnerModel
    = Editing Editing.Model
    | Looking Id Looking.Model
    | ErrorModel String String


noPeersError : Id -> InnerModel
noPeersError id =
    let
        title =
            "No Peers"

        desc =
            "The paste '"
                ++ id
                ++ "' doesn't seem to have any peers."
                ++ "It might still be seeded, but if it isn't"
                ++ " it can no longer be downloaded :("
    in
    ErrorModel title desc


routeModel : Url -> InnerModel
routeModel url =
    case parseRoute url of
        NotFound ->
            ErrorModel "Not Found"
                "This page doesn't seem to exist :("

        NewPaste ->
            Editing <| Editing.initialModel

        Paste id ->
            Looking id <| Looking.initialModel "Loading"


routeCmd : Url -> Cmd msg
routeCmd url =
    case parseRoute url of
        NotFound ->
            Cmd.none

        NewPaste ->
            Cmd.none

        Paste id ->
            sendOut (Fetch id)


diffrouteModel : Url -> InnerModel -> ( InnerModel, Cmd msg )
diffrouteModel url model =
    case ( parseRoute url, model ) of
        ( Paste id1, Looking id2 lmodel ) ->
            if id1 == id2 then
                ( Looking id2 lmodel, Cmd.none )

            else
                ( routeModel url, routeCmd url )

        ( _, _ ) ->
            ( routeModel url, routeCmd url )


type alias Model =
    { key : Nav.Key
    , inner : InnerModel
    }


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key, inner = routeModel url }, routeCmd url )



{- Update -}


type InnerMsg
    = EditingMsg Editing.Msg
    | LookingMsg Looking.Msg


type Msg
    = InnerMsg InnerMsg
    | UrlChange Url
    | Incoming Info
    | UrlRequest Browser.UrlRequest
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
            let
                ( inner, cmd ) =
                    diffrouteModel url model.inner
            in
            ( { model | inner = inner }, cmd )

        ( Incoming (TextArrived id txt), _ ) ->
            ( { model | inner = Looking id <| Looking.initialModel txt }
            , Nav.pushUrl model.key <| routeUrl (Paste id)
            )

        ( Incoming (NoPeers id), _ ) ->
            ( { model | inner = noPeersError id }, Cmd.none )

        ( NoOP, _ ) ->
            ( model, Cmd.none )

        ( UrlRequest req, _ ) ->
            case req of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )


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

        ( _, ErrorModel _ _ ) ->
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

        ErrorModel long short ->
            viewError long short


viewError : String -> String -> Html msg
viewError title desc =
    Views.wrapContainer
        [ Views.wrapHeader []
        , Views.wrapCodeArea
            [ H.div [ H.class "error-title" ]
                [ H.text title
                ]
            , H.div [ H.class "error-desc" ]
                [ H.text desc
                ]
            ]
        ]
