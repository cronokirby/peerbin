module Views exposing
    ( wrapCodeArea
    , wrapContainer
    , wrapHeader
    )

import Html as H exposing (Html)
import Html.Attributes as H

import Routes exposing (Route(..), routeUrl)


wrapContainer : List (Html msg) -> Html msg
wrapContainer rest =
    H.div [ H.class "container" ] rest


wrapHeader : List (Html msg) -> Html msg
wrapHeader rest =
    let
        title =
            H.div [ H.class "header-title" ]
                [ H.a [ H.href <| routeUrl NewPaste ]
                    [ H.text "Peer Bin"
                    ] 
                ]
    in
    H.div [ H.class "header" ] <| title :: rest


wrapCodeArea : List (Html msg) -> Html msg
wrapCodeArea rest =
    H.div [ H.class "code-area" ] rest
