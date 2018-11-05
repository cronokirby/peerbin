module Views exposing
    ( langInput
    , wrapCodeArea
    , wrapContainer
    , wrapHeader
    )

import FeatherIcons as Icons exposing (Icon)
import Html as H exposing (Html)
import Html.Attributes as H
import Html.Events as H
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


langInput : (String -> msg) -> msg -> String -> Icon -> Html msg
langInput onInputMsg onClickMsg lang icon =
    H.div [ H.class "language-container" ]
        [ H.div [ H.class "language-input" ]
            [ H.input
                [ H.type_ "text"
                , H.onInput onInputMsg
                , H.value lang
                ]
                []
            ]
        , H.div [ H.class "language-submit" ]
            [ H.button [ H.onClick onClickMsg ]
                [ icon |> Icons.toHtml []
                ]
            ]
        ]
