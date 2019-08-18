module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block

import Bootstrap.Grid.Row as Row
import Html exposing (..)
import Html.Attributes exposing (..)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input

import Bootstrap.Grid as Grid
import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Ports exposing (AuthState(..), Sheet, authStateChanged, decodeAuthState, sheetDecoder, sheetIdStorageUpdated, sheetRangeStorageUpdated, signIn, signOut)
import Json.Decode as Decode exposing (Decoder)

main : Program () Model Msg
main =
    Browser.element
        { init = \() -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type PopoverState
    = Open
    | Closed

type alias Model =
    { popoverState: PopoverState
    , authState: AuthState
    , error: Maybe Decode.Error
    , sheet: Maybe Sheet
    , sheetId: String
    , sheetRange: String
    }

type Msg
    = PopoverMsg PopoverState
    | GoAhead
    | AuthStateChanged (Result Decode.Error AuthState)
    | GotSheets (Result Http.Error Sheet)
    | SignInClicked
    | SignOutClicked
    | SheetIdInputChange String
    | SheetRangeInputChange String

getSheet : String -> String -> String -> Cmd Msg
getSheet accessToken sheetId range =
  Http.request
    { method = "GET"
    , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
    , url = String.join "" ["https://content-sheets.googleapis.com/v4/spreadsheets/", sheetId, "/values/", range]
    , expect = Http.expectJson GotSheets sheetDecoder
    , body = Elm.Kernel.Http.emptyBody
    , timeout = Nothing
    , tracker = Nothing
    }

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ authStateChanged (AuthStateChanged << Decode.decodeValue decodeAuthState)
        , sheetIdStorageUpdated SheetIdInputChange
        , sheetRangeStorageUpdated SheetRangeInputChange
        ]

init : ( Model, Cmd Msg )
init =
    ({ popoverState = Closed, sheet = Nothing, authState = Unknown, error = Nothing, sheetId = "", sheetRange = "" }, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        PopoverMsg state ->
            ({ model | popoverState = state }, Cmd.none)
        GoAhead ->
            Debug.log "goahead" (model, Cmd.none)
        AuthStateChanged result ->
            case result of
                Ok authState ->
                    let updModel = { model | authState = authState }
                    in
                    case authState of
                        SignedIn userInfo ->
                            (updModel, getSheet userInfo.accessToken model.sheetId model.sheetRange)
                        SignedOut ->
                            (updModel, Cmd.none)
                        Unknown ->
                            (updModel, Cmd.none)
                Err e ->
                    ( { model | authState = Unknown, error = Just e }, Cmd.none )
        GotSheets sheet ->
            let _ = Debug.log "sheet" sheet
            in
            (model, Cmd.none)
        SignInClicked ->
            (model, signIn ())
        SignOutClicked ->
            (model, signOut ())
        SheetIdInputChange id ->
            ({ model | sheetId = id }, Cmd.none)
        SheetRangeInputChange range ->
            ({ model | sheetRange = range }, Cmd.none)

view : Model -> Html.Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
--        , Grid.row []
--            [ Grid.col []
--                [ Button.button
--                    [ Button.primary
--                    , Button.attrs
--                        [onClick
--                            (case model.popoverState of
--                                Closed -> PopoverMsg Open
--                                Open -> PopoverMsg Closed
--                            )
--                        ]
--                    ]
--                    [ text "test" ]
--                , div
--                    [ style "position" "relative" ]
--                    [ popoverView model.popoverState ]
--                ]
--            ]
        , connectView model
        ]

connectView : Model -> Html.Html Msg
connectView model =
    div []
        [ Grid.row
            [ Row.attrs
                [ class "mt-1"
                , class "mb-3"
                ]
            ]
            [ case model.authState of
                SignedIn _ ->
                    Grid.col []
                        [ Button.button
                            [ Button.secondary
                            , Button.attrs [ onClick SignOutClicked ]
                            ]
                            [ text "Sign Out" ]
                        ]
                _ ->
                    Grid.col []
                        [ Form.form []
                            [ Form.group []
                                [ Form.label [for "sheets-id"] [ text "Sheets id"]
                                , Input.text
                                    [ Input.id "sheets-id"
                                    , Input.value model.sheetId
                                    , Input.onInput SheetIdInputChange
                                    ]
                                , Form.help []
                                    [ text "format: 'https://docs.google.com/spreadsheets/d/"
                                    , span [ class "text-success" ] [ text "{this-is-the-sheets-id-copy-this-part}" ]
                                    , text "/edit'"
                                    ]
                                ]
                            , Form.group []
                                [ Form.label [for "range"] [ text "Range"]
                                , Input.text
                                    [ Input.id "range"
                                    , Input.value model.sheetRange
                                    , Input.onInput SheetRangeInputChange
                                    ]
                                , Form.help []
                                    [ text "format: '"
                                    , span [class "text-primary"] [ text "{Sheetname}" ]
                                    , text "!"
                                    , span [class "text-danger"] [ text "{FromCol}" ]
                                    , span [class "text-success"] [ text "{FromRow}" ]
                                    , text ":"
                                    , span [class "text-warning"] [ text "{ToCol}" ]
                                    , span [class "text-info"] [ text "[{ToRow}]" ]
                                    , text "'. example: '"
                                    , span [class "text-primary"] [ text "Kundregister" ]
                                    , text "!"
                                    , span [class "text-danger"] [ text "A" ]
                                    , span [class "text-success"] [ text "1" ]
                                    , text ":"
                                    , span [class "text-warning"] [ text "E" ]
                                    , text "'"
                                    ]
                                ]
                            , Button.button
                                [ Button.primary
                                , Button.attrs [ onClick SignInClicked ]
                                ]
                                [ text "Sign In" ]
                            ]
                        ]
            ]
        ]


popoverView : PopoverState -> Html.Html Msg
popoverView state =
    div
        [ style "position" "absolute"
        , style "top" "10px"
        , case state of
            Open -> style "display" "block"
            Closed -> style "display" "none"
        ]
        [ Card.config []
            |> Card.header []
                [ h4 [] [ text "Hold up..." ]]
            |> Card.block []
                [ Block.text [] [ text "Body" ]
                , Block.custom <|
                    Grid.row []
                    [ Grid.col []
                        [ Button.button
                            [ Button.success
                            , Button.attrs [ onClick GoAhead ]
                            ]
                            [ text "OK" ]
                        ]
                    , Grid.col []
                        [ Button.button
                            [ Button.secondary
                            , Button.attrs [ onClick <| PopoverMsg Closed ]
                            ]
                            [ text "Cancel" ]
                        ]
                    ]
                ]
            |> Card.view
        ]


