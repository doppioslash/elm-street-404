module Request (Request(..), isInReturn, inHouse, isOrdered, hasOrder, animate, inTime, house, orders, orderedCategories, returnArticles) where

import House exposing (House)
import Article exposing (Article)
import Category exposing (Category)
import Time exposing (Time)
import IHopeItWorks
import Random

initialMaxWaitingTime : Time
initialMaxWaitingTime = 60000


type alias RequestData =
  { timeout : Time
  , elapsed : Time
  , blinkHidden : Bool
  }


type Request
  = Order House Category RequestData
  | Return House Article RequestData


initData : RequestData
initData =
  { timeout = initialMaxWaitingTime
  , elapsed = 0
  , blinkHidden = False
  }


orderedCategories : List Request -> List Category
orderedCategories requests =
  case requests of
    request :: rest ->
      case request of
        Order _ category _ ->
          category :: orderedCategories rest
        _ ->
          orderedCategories rest
    [] -> []


returnArticles : List Article -> List Request
returnArticles articles =
  case articles of
    [] -> []
    article :: restArticles ->
      case Article.house article of
        Just house ->
          Return house article initData :: returnArticles restArticles
        Nothing ->
          returnArticles restArticles


orders : Int -> List House -> List Category -> Random.Generator (List Request)
orders number houses categories =
  if number <= 0 then
    Random.map (always []) (Random.int 0 0)
  else
    Random.pair (IHopeItWorks.pickRandom houses) (IHopeItWorks.pickRandom categories)
    `Random.andThen`
    (\pair ->
      case pair of
        (Just house, Just category) ->
          Random.map
            ((::) (Order house category initData))
            ( orders
                (number - 1)
                (IHopeItWorks.remove ((==) house) houses)
                (IHopeItWorks.remove ((==) category) categories)
            )
        _ ->
          Random.map (always []) (Random.int 0 0)
    )


inHouse : House -> Request -> Bool
inHouse house request =
  case request of
    Order house' _ _ -> house' == house
    Return house' _ _ -> house' == house


isInReturn : House -> Article -> Request -> Bool
isInReturn house article request =
  case request of
    Return house' article' _ ->
      house' == house && article' == article
    _ ->
      False


isOrdered : House -> Category -> Request -> Bool
isOrdered house category request =
  case request of
    Order house' category' _ ->
      house' == house && category' == category
    _ -> False


hasOrder : House -> Category -> List Request -> Bool
hasOrder house category requests =
  List.any (isOrdered house category) requests


-- time while it doesn't blink
z : Float
z = 30000


-- acceleration of blinking speed
a : Float
a = 0.00000024


-- initial blinking speed
b : Float
b = 0.003


-- constant time shift (positive to make sure it starts with not blinking)
c : Float
c = 0


-- max speed
m : Float
m = 0.015


flash : Time -> Bool
flash elapsed =
  if elapsed < z then
    False
  else
    let
      x = elapsed - z
      s = if a * x + b > m then m else a * x + b
    in
     0 < sin (s * x + c) -- ((a * x * x) + (b * x) + c)


animateRequestData : Time -> RequestData -> RequestData
animateRequestData time request =
  { request
  | elapsed = request.elapsed + time
  , blinkHidden = flash request.elapsed
  }


animate : Time -> Request -> Request
animate time request =
  case request of
    Order house category data -> Order house category (animateRequestData time data)
    Return house article data -> Return house article (animateRequestData time data)


inTime : Request -> Bool
inTime request =
  case request of
    Order _ _ data -> data.elapsed < data.timeout
    Return _ _ data -> data.elapsed < data.timeout


house : Request -> House
house request =
  case request of
    Order house _ _ -> house
    Return house _ _ -> house


data : Request -> RequestData
data request =
  case request of
    Order _ _ data -> data
    Return _ _ data -> data


updateData : RequestData -> Request -> Request
updateData data request =
  case request of
    Order house category _ -> Order house category data
    Return house article _ -> Return house article data