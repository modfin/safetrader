port module Ports exposing (Sheet, sheetDecoder, signIn, signOut, authStateChanged, AuthState(..), UserInfo, AccessToken, decodeAuthState, sheetIdStorageUpdated, sheetRangeStorageUpdated, storeSheetId, storeSheetRange)

import Json.Decode as Decode exposing (Decoder, Value, field, list, string)
import Json.Decode.Pipeline exposing (required)

port authStateChanged : (Value -> msg) -> Sub msg

port signIn : () -> Cmd msg
port signOut : () -> Cmd msg

port sheetIdStorageUpdated : (String -> msg) -> Sub msg
port sheetRangeStorageUpdated : (String -> msg) -> Sub msg
port storeSheetId : String -> Cmd msg
port storeSheetRange : String -> Cmd msg

type alias AccessToken = String

type alias UserInfo =
    { userId : String
    , fullName : String
    , email : String
    , accessToken : String
    }

type AuthState
    = Unknown
    | SignedIn UserInfo
    | SignedOut


decodeSignedIn : Decoder AuthState
decodeSignedIn =
     Decode.succeed UserInfo
        |> required "userId" string
        |> required "fullName" string
        |> required "email" string
        |> required "accessToken" string
        |> Decode.map SignedIn

decodeSignedOut : Decoder AuthState
decodeSignedOut =
    Decode.succeed SignedOut

decodeAuthState : Decoder AuthState
decodeAuthState =
    Decode.oneOf
        [ decodeSignedIn
        , decodeSignedOut
        ]

type alias Sheet =
    { cells: List (List String) }

sheetDecoder : Decoder Sheet
sheetDecoder =
    Decode.map
    (\cells -> { cells = cells })
    (field "values"
        (list (list string))
    )
