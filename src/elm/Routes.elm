module Routes exposing
    ( Route(..)
    , parseRoute
    , routeUrl
    )

import Url exposing (Url)
import Url.Builder as B
import Url.Parser as P exposing ((</>))


type Route
    = NotFound
    | NewPaste
    | Paste String


route : P.Parser (Route -> a) a
route =
    P.oneOf
        [ P.map Paste (P.s "pastes" </> P.string)
        , P.map NewPaste P.top
        ]


parseRoute : Url -> Route
parseRoute =
    P.parse (P.fragment identity)
        >> Maybe.andThen identity
        >> Maybe.map (\s -> "https://a.com" ++ s)
        >> Maybe.andThen Url.fromString
        >> Maybe.andThen (P.parse route)
        >> Maybe.withDefault NotFound


routeUrl : Route -> String
routeUrl rte =
    case rte of
        NotFound ->
            B.relative [] []

        NewPaste ->
            B.relative [ "#", "" ] []

        Paste id ->
            B.relative [ "#", "pastes", id ] []
