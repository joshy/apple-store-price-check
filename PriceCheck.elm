import Signal
import Graphics.Element exposing (Element, show)
import Task exposing (Task, andThen)
import Http exposing (..)
import Json.Decode as Json exposing (Decoder, (:=))
import Html exposing (..)

-- Models

appIds : List Int
appIds = [ 881270303 -- xcom
         , 911006986 -- banner saga
         , 980307863 -- tales from deep space
         , 978524071 -- grim fandango
         , 680366065 -- device 6
         , 895869909 -- the sailor's dream
         , 555916407 --year walk
         , 395680819 -- av player
         ]


type alias Result =
  { apps : List App
  }


type alias App =
  { name  : String
  , price : String
  }



-- Update

contentMailbox : Signal.Mailbox (List String)
contentMailbox =
  Signal.mailbox [""]


sendToMailbox : List String -> Task x ()
sendToMailbox content =
  Signal.send contentMailbox.address content


-- get the readme *and then* send the result to our mailbox
port fetchItem : Task Http.Error ()
port fetchItem =
  Http.get app itemUrl `andThen` sendToMailbox


itemStoreUrl : Int -> String
itemStoreUrl appId =
  "https://itunes.apple.com/lookup?country=ch&id=" ++ (toString appId)


itemUrl : String
itemUrl =
  "https://itunes.apple.com/lookup?country=ch&id=881270303"


appDecoder : Decoder App
appDecoder =
  Json.object2 App
    ("trackName" := Json.string)
    ("formattedPrice" := Json.string)


resultDecoder : Decoder Result
resultDecoder =
  Json.object1 Result
    ("results" := Json.list appDecoder)


app : Decoder (List String)
app =
  let place =
        Json.object2 (\name price -> name ++ ": " ++ price)
          ("trackName" := Json.string)
          ("formattedPrice" := Json.string)
  in
      "results" := Json.list place


-- View

view : App -> Html
view model = div [ ]
    [ text ("App: " ++ model.name ++ ", Price" ++ model.price)
    ]


-- Run entry

main : Signal Element
main =
  Signal.map show contentMailbox.signal
