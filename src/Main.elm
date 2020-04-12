port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as E
import Time


port makeLogin : E.Value -> Cmd msg


type alias UserHash =
    String


type alias UserLogin =
    { username : String
    , password : String
    }


type alias Post =
    { id : String
    , content : String
    , timestamp : Time.Posix
    }


type NextId
    = NoId
    | NextId String


type Posts
    = Loading
    | NoPosts
    | Posts (List Post) NextId


type Msg
    = NoOp
    | SetUserLogin String String
    | Login
    | ClearFlash


type FlashMsg
    = NoFlash
    | Info String
    | Error String


type alias Model =
    { user : Maybe UserHash
    , login : UserLogin
    , posts : Posts
    , postInput : String
    , flashMsg : FlashMsg
    }


setFlash : String -> String -> Model -> Model
setFlash type_ msg model =
    let
        msgs =
            case type_ of
                "info" ->
                    Info msg

                "error" ->
                    Error msg

                _ ->
                    NoFlash
    in
    { model | flashMsg = msgs }


clearFlash : Model -> Model
clearFlash model =
    { model | flashMsg = NoFlash }


baseModel : Model
baseModel =
    Model Nothing (UserLogin "" "") NoPosts "" NoFlash


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( baseModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ showFlash model.flashMsg
        , case model.user of
            Nothing ->
                loginForm model.login

            Just _ ->
                text "Hi!"
        ]


loginForm : UserLogin -> Html Msg
loginForm login =
    div []
        [ label []
            [ text "User"
            , input
                [ value login.username
                , onInput (SetUserLogin "username")
                ]
                []
            ]
        , label []
            [ text "Password"
            , input
                [ value login.password
                , onInput (SetUserLogin "password")
                , type_ "password"
                ]
                []
            ]
        , button [ onClick Login ] [ text "Login" ]
        ]


showFlash : FlashMsg -> Html Msg
showFlash flash =
    let
        template class_ msg =
            div
                [ class class_ ]
                [ button [ onClick ClearFlash ] [ text "x" ]
                , div [] [ text msg ]
                ]
    in
    case flash of
        NoFlash ->
            text ""

        Info m ->
            template "info" m

        Error m ->
            template "error" m


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ login } as model) =
    let
        done m =
            ( m, Cmd.none )
    in
    case msg of
        SetUserLogin field value ->
            case field of
                "username" ->
                    ( { model | login = { login | username = value } }, Cmd.none )

                "password" ->
                    ( { model | login = { login | password = value } }, Cmd.none )

                _ ->
                    done model

        Login ->
            case ( login.username, login.password ) of
                ( "", "" ) ->
                    model
                        |> setFlash "error" "You must provide a username and password to login."
                        |> done

                ( _, _ ) ->
                    ( model, makeLogin <| userLoginEncode login )

        ClearFlash ->
            model
                |> clearFlash
                |> done

        NoOp ->
            done model


userLoginEncode : UserLogin -> E.Value
userLoginEncode login =
    E.object
        [ ( "username", E.string login.username )
        , ( "password", E.string login.password )
        ]
