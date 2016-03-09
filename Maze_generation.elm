import Matrix 
import Random exposing (Seed)
import Matrix.Random
import Set exposing (..)
import List exposing (..)
import String exposing (join)
import Html exposing (Html, br, input, h1, h2, text, div, button, fromElement)
import Html.Attributes as HA
import Svg 
import Svg.Attributes exposing (version, viewBox, cx, cy, r, x, y, x1, y1, x2, y2, fill,points, transform, style, width, height, preserveAspectRatio)

w = 700
h = 700

rows = 30
cols = 30

type alias Box = 
  { visited : Bool
  }

type alias Direction = Int
up = 0
down = 1
left = 2
right = 3

type alias Wall = (Matrix.Location, Direction)

type alias Model =
  { boxes : Matrix.Matrix Box
  , walls : Set Wall
  , current : Matrix.Location
  , seed : Seed
  }

-- is there some built in way of doing this?
pairs : List a -> List b -> List (a,b)
pairs la lb = List.concatMap (\at -> List.map ((,) at) lb) la

initWalls : Int -> Int -> Set Wall
initWalls rows cols =
  let 
    downAndRight = pairs (pairs [0..rows-2] [0..cols-2]) [down, right] 
    onlyDown = pairs (pairs [0..rows-2] [cols-1..cols-1]) [down] 
    onlyRight = pairs (pairs [rows-1..rows-1] [0..cols-2]) [right] 
  in downAndRight ++ onlyDown ++ onlyRight |> fromList


init : Model
init = 
  let rowGenerator = Random.int 0 (rows-1)
      colGenerator = Random.int 0 (cols-1)
      locationGenerator = Random.pair rowGenerator colGenerator
      (c, s)= Random.generate locationGenerator (Random.initialSeed 45)
  in { boxes = Matrix.matrix rows cols (\location -> { visited = False }) 
     , walls = initWalls rows cols
     , current = c
     , seed = s
     }

view model =
  let

    greenLineStyle = style "stroke:green;stroke-width:0.3"
    redLineStyle = style "stroke:red;stroke-width:0.1" 

    x1Min = x1 <| toString 0
    y1Min = y1 <| toString 0
    x1Max = x1 <| toString cols
    y1Max = y1 <| toString rows
    x2Min = x2 <| toString 0
    y2Min = y2 <| toString 0
    x2Max = x2 <| toString cols
    y2Max = y2 <| toString rows

    wallToLine wall = 
      let side = snd wall
          (deltaX1, deltaY1) = if (side == right) then (1,0) else (0,1)
          (row, column) = fst wall
          x1value = column + deltaX1
          x2value = column + 1
          y1value = row    + deltaY1
          y2value = row    + 1
      in Svg.line [ x1 <| toString x1value
                  , y1 <| toString y1value
                  , x2 <| toString x2value
                  , y2 <| toString y2value 
                  , redLineStyle ] []

    borders = [ Svg.line [ x1Min, y1Min, x2Max, y2Min, greenLineStyle ] []
              , Svg.line [ x1Max, y1Min, x2Max, y2Max, greenLineStyle ] []
              , Svg.line [ x1Max, y1Max, x2Min, y2Max, greenLineStyle ] []
              , Svg.line [ x1Min, y1Max, x2Min, y2Min, greenLineStyle ] []
              ]
    maze = 
      Svg.g 
        []
        ((List.map wallToLine <| toList model.walls) ++ borders )
  in
    div []
      [ div floatLeft [ h2 centerTitle [text "Maze Generator"]
                      , Svg.svg 
                          [ version "1.1"
                          , width (toString w)
                          , height (toString h)
                          , viewBox (join " " 
                                       [ 0 |> toString
                                       , 0 |> toString
                                       , cols |> toString
                                       , rows |> toString ])
                          ] 
                          [ maze ]
                      ]

      ] 


floatLeft = [ HA.style [ ("float", "left") ] ]
centerTitle = [ HA.style [ ( "text-align", "center") ] ] 

main = view init
