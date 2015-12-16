module DeliveryPerson (DeliveryPerson, Location(..), initial, render, animate, navigateTo) where

import House exposing (House)
import Warehouse exposing (Warehouse)
import Sprite exposing (Sprite)
import Basics exposing (atan2)
import Pathfinder exposing (find)
import Time exposing (Time)
import AnimationState exposing (animateObject, rotateFrames)
import Debug


onTheWaySprite : Sprite
onTheWaySprite =
  { size = (2, 3)
  , offset = (0, -1)
  , frames = 24
  , src = "img/delivery-person.png"
  }


type Location
  = AtHouse House
  | AtWarehouse Warehouse
  | OnTheWay


type alias DeliveryPerson =
  { location : Location
  , position : (Float, Float)
  , route : List (Int, Int)
  , elapsed: Time
  , frames : List (Int)
  }


animate: Time -> DeliveryPerson -> DeliveryPerson
animate time deliveryPerson =
  let
    updateDeliveryPerson deliveryPerson =
      {deliveryPerson | frames = rotateFrames deliveryPerson.frames}
  in
    animateObject 150 time updateDeliveryPerson deliveryPerson

initial : (Int, Int) -> DeliveryPerson
initial position =
  { location = OnTheWay
  , position = (toFloat (fst position), toFloat (snd position))
  , route = []
  , elapsed = 0
  , frames = [0, 1, 2]
  }


calculateDirection : (Float, Float) -> Int
calculateDirection (x, y) =
  (2 + round (atan2 y x * 4 / pi)) % 8


direction : DeliveryPerson -> Int
direction deliveryPerson =
  case deliveryPerson.route of
    first :: rest -> calculateDirection
      ( toFloat (fst first) - fst deliveryPerson.position
      , toFloat (snd first) - snd deliveryPerson.position
      )
    _ -> 0


render : DeliveryPerson -> List Sprite.Box
render deliveryPerson =
  case deliveryPerson.location of
    OnTheWay ->
      [ { sprite = onTheWaySprite
        , position =
            ( floor (fst deliveryPerson.position)
            , floor (snd deliveryPerson.position)
            )
        , layer = 2
        , frame = (direction deliveryPerson) * 3
        , attributes = []
        }
      ]
    _ -> []


navigationStart : DeliveryPerson -> (Int, Int)
navigationStart deliveryPerson =
  Maybe.withDefault 
    
    (List.head deliveryPerson.route)


appendPath : (Int, Int) -> List (Int, Int) -> List (Int, Int)
appendPath start deliveryPerson
  let
    path = 
  in
    case deliverPerson.route of
      [] ->
        Pathfinder.find
          gridSize
          obstacles
          ( round (fst deliveryPerson.position)
          , round (snd deliveryPerson.position)
          )
          start
          destination
      first :: rest -> first :: path


navigateTo : (Int, Int) -> List (Int, Int) -> (Int, Int) -> DeliveryPerson -> DeliveryPerson
navigateTo gridSize obstacles destination deliveryPerson =
  let
    start = navigationStart deliveryPerson
  in
    { deliveryPerson |
        route = Debug.log "path" 
    }
