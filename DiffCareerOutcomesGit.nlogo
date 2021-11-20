; This is a basic version of the code used for "RASE: Modeling cumulative disadvantage due to marginalized group status in academia", by Shandera, Matsick, Hunter and Leblond. For simpicity, it does not contain all the features required to do the thresholding analysis in that paper.
; In addition, this model contains stochastic events whose effect is accurately captured for the small populations that are nice to visualize. We recommend using this model with R or Mathematica (and supressing graphics) to run with large populations and to perform statistical analysis.


globals [ sLAdv aLAdv sigmaAAdv rLAdv srAdv saAdv InitRListAdv aLDis sigmaaDis rLDis srDis saDis InitRListDis fracposEventsBothPops posAeventsMeanBothPops negAeventsMeanBothPops sigAeventsBothPops posReventsMeanBothPops negReventsMeanBothPops sigReventsBothPops AeventsMeanOnePop sigAeventsOnePop NeventsOnepopRperyear ReventsMeanOnePop sigReventsOnePop ExtraEventsFlagAdv ExtraEventsFlagDis WindowStart WindowWidth SignOnePopEvents sorderedAdv]
; These are defined in setup-values below

breed [Aevents Aevent] ; The Events that affect Achievement of both populations
breed [Revents Revent] ; The Events that affect Resources of both populations
breed [OnePopAEvents OnePopAEvent] ; Events that affect Achievement of only one population
breed [OnePopREvents OnePopREvent] ; Events that affect Resources of only one population
breed [people-Adv person-Adv] ; The Advantaged population
breed [people-Dis person-Dis] ; The Disadvantaged population

people-Adv-own [achieveAdv statusAdv resourcesAdv RecentResourceAdv aindividualAdv]
people-Dis-own [achieveDis statusDis resourcesDis RecentResourceDis aindividualDis]

to set-up
  clear-all
  ask patches [set pcolor 109]
  setup-Aevents ; Events affecting Achievement (sets up number, graphics, positions)
  setup-Revents ; Events affecting Resources (sets up number, graphics, positions)
  setup-OnePopAevents ; Events affecting Achievement of just one population (sets up number, graphics, positions)
  setup-OnePopRevents ; Events affecting Resources of just one population (sets up number, graphics, positions)
  setup-values ; The conversion between Resources, Achievement and Status for each group, and the properties of the Events experienced by both popuations
  setup-people-Adv ; Number, graphics, positions, initial resource distributions, numerical labels according to initial Resources for the Advantaged population
  setup-people-Dis ; Number, graphics, positions, initial resource distributions, numerical labels according to initial Resources for the Disadvantaged population
  reset-ticks
end

to setup-Aevents ; These events will affect the Achievement of both populations identically
  create-Aevents  round (1089 * NeventsAperyear / 2) ; 1089 assumes a 33 x 33 grid. If you change the grid, change the number here to be the number of squares
  ask Aevents [
    set shape "circle"
    set color green
    set size 0.3 ; Decrease the size (from 0.3) if you would like the Achievement Events to be invisible
    setxy random-xcor random-ycor
  ]
end

to setup-Revents ; These events will affect the Resources of both populations identically
  create-Revents round (1089 * NeventsRperyear / 2) ; 1089 assumes a 33 x 33 grid. If you change the grid, change the number here to be the number of squares
  ask Revents [
    set shape "circle"
    set color brown
    set size 0.3 ; Decrease the size (from 0.3) if you would like the Resource Events to be invisible
    setxy random-xcor random-ycor
  ]
end

to setup-OnePopAevents ; These Events will affect the Achievement of only one population
  create-OnePopAevents round (1089 * NeventsOnepopAperyear / 2) ; 1089 assumes a 33 x 33 grid. If you change the grid, change the number here to be the number of squares
  ask OnePopAevents [
    set shape "circle plus"
    set color green
    set size 0.001 ; Increase the size (from 0.001) if you would like the one-population Achievment Events to be visible
    setxy random-xcor random-ycor
  ]
end

to setup-OnePopRevents ; These Events will affect the Resources of only one population
  create-OnePopRevents round (1089 * NeventsOnepopRperyear / 2) ; 1089 assumes a 33 x 33 grid. If you change the grid, change the number here to be the number of squares
  ask OnePopRevents [
    set shape "circle plus"
    set color brown
    set size 0.001 ; Increase the size (from 0.001) if you would like the one-population Resource Events to be visible
    setxy random-xcor random-ycor
  ]
end

to setup-values ; Advantaged population (Adv) has starred shirts

  set aLAdv 0.2 ; Linear rate (or mean rate) to convert Resources to new Achievement for Adv population
  set sigmaAAdv 0.004 ; Variance for coefficient converting Resources to Achievement for Adv population
  set rlAdv 0.4 ; Linear rate to convert Status into new Resources for Adv population
  set sLAdv 1 ; Linear rate to convert Achievement to Status for Adv population

  set aLDis 0.2 ; Linear rate (or mean rate)  to convert Resources to new Achievement for Dis population
  set sigmaADis 0.004 ; Variance for coefficient converting Resources to Achievement for Dis population
  set rlDis 0.4 ; Linear rate to convert Status into new Resources for Dis population

  set fracposEventsBothPops 0.5 ;fraction of (Achievement and Resource) Events that affect both populations that are positive Events
  set posAeventsMeanBothPops 1 ;mean amplitude of positive Achievement Events that affect both populations
  set negAeventsMeanBothPops 1 ;mean amplitude of negative Achievement Events that affect both populations
  set sigAeventsBothPops 0.5 ;std dev of the distributions for Acheivement Events that affect both populations
  set posReventsMeanBothPops 5 ;mean amplitude of positive Resource Events that affect both populations
  set negReventsMeanBothPops 5 ;mean amplitude of negative Resource Events that affect both populations
  set sigReventsBothPops 2.5 ;std dev of the distributions for Resource Events that affect both populations

  set SignOnePopEvents 1 ; +1 gives positive one pop events, -1 for negative one pop events
  set NeventsOnepopRperyear 0; Number of Resource Events experienced by only one population
  set ReventsMeanOnePop 5 ;mean amplitude of Resource Events experienced by only one population
  set sigReventsOnePop 2.5 ;std dev of the distribution for Resource Events experienced by only one population
  set AeventsMeanOnePop 1 ;mean amplitude of Achievement Events experienced by only one population
  set sigAeventsOnePop 0.5 ;std dev of the distribution for Acheivement Events experienced by only one population

  set WindowStart 16 ;when should windowing of resources start (which timestep)?
  set WindowWidth 10 ;what is the resource lifetime (how many timesteps?)?

  set sorderedAdv []

end

to setup-people-Adv ;set up the Advantaged population.
  create-people-Adv NumberAdv
  ask people-Adv [
    set shape "person black hair red star"
    set color 49
    set size 3.6
    set label-color blue
    setxy random-xcor random-ycor
    set ExtraEventsFlagAdv 0 ; 0 if the population doesn't experience the OnePop Events, 1 if it does

;    set resourcesAdv 10 ; option if you want all individuals the same. Use this or the next line.
    set resourcesAdv random-normal 4 1 ; option if you want all individuals to have different starting resources. Use this or the previous line.

    set aindividualAdv aLAdv ; option if you want all individuals the same. Use this or the next line.
;    set aindividualAdv random-normal aLAdv sigmaaAdv ; option if you want individual to have different rates to convert resources to achievement. Use this or the previous line.
    set achieveAdv 0

    set RecentResourceAdv [] ;initialize a vector to hold "recent resource" events
    let sumnumber 0
    while [ sumnumber < WindowWidth ]   [
      set RecentResourceAdv lput 0 RecentResourceAdv
      set sumnumber 1 + sumnumber
    ]
  ]

 set InitRListAdv (sort-by > [resourcesAdv] of people-Adv) ; Label is position in starting resource distribution.
  ask people-Adv[
   let labelnumber 0 ; Smallest label number is the most starting Resources
    set label 1
    while [resourcesAdv < (item labelnumber InitRListAdv)] [
      set labelnumber 1 + labelnumber
      set label labelnumber + 1
    ]
  ]
end

to setup-people-Dis ;set up the Disadvantaged population.
  create-people-Dis NumberDis
  ask people-Dis [
    set color 49
    set shape "person gray hair"
    set size 3.6
    set label-color red
    setxy random-xcor random-ycor
    set ExtraEventsFlagDis 0; Set to 0 if the population doesn't experience the OnePop Events, 1 if it does

;    set resourcesDis 10 ; Option if you want all individuals to start with the same Resources. Use this or the next line.
    set resourcesDis random-normal (RinitDis * 4) 1 ; Option if you want all individuals to have different starting Resources. Use this or the previous line.
    set aindividualDis aLDis  ; Option if you want all individuals to start with the same Achievement. Use this or the next line.
  ;  set aindividualDis random-normal aLDis sigmaaDis ; Option if you want individuals to have different rates to convert Resources to Achievement.Use this or the previous line.
    set achieveDis 0

    set RecentResourceDis [] ;initialize a vector to hold "recent resource" events
    let sumnumber 0
    while [ sumnumber < WindowWidth ]   [
      set RecentResourceDis lput 0 RecentResourceDis
      set sumnumber 1 + sumnumber
    ]

]
  set InitRListDis (sort-by > [resourcesDis] of people-Dis); Label is position in starting resource distribution.
  ask people-Dis[
   let labelnumber 0 ; Smallest label number is the most starting Resources
    set label 1
    while [resourcesDis < (item labelnumber InitRListDis)] [
      set labelnumber 1 + labelnumber
      set label labelnumber + 1
    ]
  ]
end


to-report adjust-achievement [resources-in alin deltaAeventseff] ; The equation for new Achievement. The first term is the conversion of Resources to Achievement, the second is from any Events.
  report alin * resources-in + deltaAeventseff
end

to-report adjust-resources [status-in rlin deltaReventseff] ; The equation for new Resources. The first term is the conversion of Status to Resources, the second is from any Events.
  report rlin * status-in + deltaReventseff
end

to-report pstatus [plin achievein] ; The equation for Status, gained proportional to Achievement.
  report plin * achievein
end

to go
   if ticks >= StopTick [ stop ]  ;;
  tick
  move-Aevents    ; Achievement events move randomly one position
  move-Revents    ; Resource events move randomly one position
  check-achieve   ; updates Achievements for each individual (Adv population first, then Dis population).
  check-resources ; updates Resources, then updates Status and graphics (Status pants) for each individual (Adv population first, then Dis population).
end

to move-Aevents
  ask Aevents [
   right random 360
   forward 1
  ]
end

to move-Revents
  ask Revents [
   right random 360
   forward 1
  ]
end

to check-achieve
  ask people-Adv[
    let deltaAeventseff 0

    if ((count Aevents-here) > 0) [
      let counter 0
      while [counter < ((count Aevents-here))] [
        let sign (random-float 1)
        ifelse sign < fracposEventsBothPops
        [set deltaAeventseff (deltaAeventseff +  abs (random-normal posAeventsMeanBothPops sigAeventsBothPops))]
        [set deltaAeventseff (deltaAeventseff -  abs (random-normal negAeventsMeanBothPops sigAeventsBothPops))]
        set counter counter + 1
      ]
    ]

    if (ExtraEventsFlagAdv > 0) [
      if ((count OnePopAevents-here) > 0) [
        let counter 0
        while [counter < ((count OnePopAevents-here))] [
          set deltaAeventseff (deltaAeventseff + SignOnePopEvents * (abs (random-normal (AeventsMeanOnePopFactor * AeventsMeanOnePop) (sigAeventsOnePopFactor * sigAeventsOnePop))))
          set counter counter + 1
             print deltaAeventseff
        ]
      ]
    ]
    ifelse ticks < WindowStart
    [ set achieveAdv (adjust-achievement resourcesAdv aindividualAdv deltaAeventseff) ]
    [ set achieveAdv (adjust-achievement (resourcesAdv + sum RecentResourceAdv) aindividualAdv deltaAeventseff) ]
    if achieveAdv < 0 [set achieveAdv 0]

  ]

  ask people-Dis[
    let deltaAeventseff 0
     if ((count Aevents-here) > 0) [
      let counter 0
      while [counter < ((count Aevents-here))] [
        let sign random-float 1
        ifelse sign < fracposEventsBothPops
        [set deltaAeventseff (deltaAeventseff +  abs (random-normal posAeventsMeanBothPops sigAeventsBothPops))]
        [set deltaAeventseff (deltaAeventseff -  abs (random-normal negAeventsMeanBothPops sigAeventsBothPops))]
        set counter counter + 1
      ]
    ]

    if (ExtraEventsFlagDis > 0) [
      if ((count OnePopAevents-here) > 0) [
        let counter 0
        while [counter < ((count OnePopAevents-here))] [
          ;set deltaAeventseff (deltaAeventseff + SignOnePopEvents * (abs (random-normal 50 2.5)))
          set deltaAeventseff (deltaAeventseff + SignOnePopEvents * (abs (random-normal ( AeventsMeanOnePopFactor * AeventsMeanOnePop) (sigAeventsOnePopFactor * sigAeventsOnePop))))
          set counter counter + 1
        ]
      ]
    ]

    ifelse ticks < WindowStart
    [ set achieveDis (adjust-achievement resourcesDis aindividualDis  deltaAeventseff) ]
    [ set achieveDis (adjust-achievement (resourcesDis + sum RecentResourceDis) aindividualDis deltaAeventseff)]
    if achieveDis < 0 [set achieveDis 0]

  ]
end


to check-resources ; updates Resources, then updates Status and Status pants of each individual
  ask people-Adv [
    let deltaReventseff 0
    if ((count Revents-here) > 0) [
      let counter 0
      while [counter < ((count Revents-here))] [
        let sign random-float 1
        ifelse sign < fracposEventsBothPops
        [set deltaReventseff (deltaReventseff +  abs (random-normal posReventsMeanBothPops sigReventsBothPops))]
        [set deltaReventseff (deltaReventseff -  abs (random-normal negReventsMeanBothPops sigReventsBothPops))]
        set counter counter + 1
      ]
    ]

    if (ExtraEventsFlagAdv > 0) [
      if ((count OnePopRevents-here) > 0) [
        let counter 0
        while [counter < ((count OnePopRevents-here))] [
          set deltaReventseff (deltaReventseff + SignOnePopEvents * (abs (random-normal ReventsMeanOnePop sigReventsOnePop)))
          set counter counter + 1
        ]
      ]
    ]

    set statusAdv (pstatus sLAdv achieveAdv)
    ifelse ticks < ( WindowStart)
    [ set resourcesAdv (resourcesAdv + (adjust-resources statusAdv rlAdv deltaReventseff)) ]
    [ set RecentResourceAdv replace-item ( (ticks - WindowStart) mod WindowWidth ) RecentResourceAdv (adjust-resources statusAdv rlAdv deltaReventseff) ]
    if statusAdv = 0  [set color 0]     ;black
    if statusAdv > 0  [set color 15]    ;red
    if statusAdv > 10 [set color 45]    ;yellow
    if statusAdv > 20 [set color 65]    ;green
    if statusAdv > 30 [set color 95]    ;blue
    if statusAdv > 40 [set color 115]   ;purple

  ]
  ask people-Dis [
    let deltaReventseff 0
    if ((count Revents-here) > 0) [
      let counter 0
      while [counter < ((count Revents-here))] [
        let sign random-float 1
        ifelse sign < fracposEventsBothPops
        [set deltaReventseff (deltaReventseff + abs (random-normal posReventsMeanBothPops sigReventsBothPops))]
        [set deltaReventseff (deltaReventseff - abs (random-normal negReventsMeanBothPops sigReventsBothPops))]
        set counter counter + 1
      ]
    ]
    if (ExtraEventsFlagDis > 0) [
      if ((count OnePopRevents-here) > 0) [
        let counter 0
        while [counter < ((count OnePopRevents-here))] [
          set deltaReventseff (deltaReventseff + SignOnePopEvents * (abs (random-normal ReventsMeanOnePop sigReventsOnePop)))
          set counter counter + 1
        ]
      ]
    ]

    set statusDis (pstatus sLDis achieveDis)
    ifelse ticks < WindowStart
    [set resourcesDis (resourcesDis + (adjust-resources statusDis rlDis deltaReventseff))]
    [set RecentResourceDis replace-item ((ticks - WindowStart) mod WindowWidth) RecentResourceDis (adjust-resources statusDis rlDis deltaReventseff)]
    if statusDis = 0  [set color 0]     ;black
    if statusDis > 0  [set color 15]    ;red
    if statusDis > 10 [set color 45]    ;yellow
    if statusDis > 20 [set color 65]    ;green
    if statusDis > 30 [set color 95]    ;blue
    if statusDis > 40 [set color 115]   ;purple

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
736
10
1173
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
15
10
88
43
NIL
set-up
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
107
11
170
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
21
135
193
168
NumberAdv
NumberAdv
0
100
20.0
10
1
People
HORIZONTAL

SLIDER
22
172
194
205
NumberDis
NumberDis
0
100
20.0
10
1
People
HORIZONTAL

SLIDER
23
312
196
345
StopTick
StopTick
1
101
81.0
1
1
half-years
HORIZONTAL

SLIDER
249
223
421
256
RinitDis
RinitDis
0.75
1
0.95
0.01
1
NIL
HORIZONTAL

SLIDER
249
259
427
292
sLDis
sLDis
0.9
1
0.95
0.01
1
NIL
HORIZONTAL

MONITOR
354
391
608
436
Mean Status of a Disadvantaged Person
mean [statusDis] of people-Dis
2
1
11

MONITOR
97
392
341
437
Mean Status of an Advantaged Person
mean [statusAdv] of people-Adv
2
1
11

SLIDER
23
223
195
256
NeventsAperyear
NeventsAperyear
0
2
0.5
0.25
1
NIL
HORIZONTAL

SLIDER
471
164
680
197
NeventsOnepopAperyear
NeventsOnepopAperyear
0
10
10.0
0.1
1
NIL
HORIZONTAL

SLIDER
470
210
685
243
AeventsMeanOnePopFactor
AeventsMeanOnePopFactor
0
1
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
471
259
675
292
sigAeventsOnePopFactor
sigAeventsOnePopFactor
0
10
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
23
259
195
292
NeventsRperyear
NeventsRperyear
0
2
0.5
0.25
1
NIL
HORIZONTAL

TEXTBOX
248
104
446
205
This column of sliders changes the parameters of the Disadvantaged group (mean initial Resources and Status received for Achievement), with values shown as a fraction of what the Advantaged group receives.
11
0.0
1

TEXTBOX
484
69
669
181
This column of sliders allows you to add extra Events affecting Achievement of just one group. You can choose the number of Events, their mean amplitude and variance.
11
0.0
1

TEXTBOX
38
72
188
128
Set population sizes,  number of stochastic Resource and Achievment Events, and time to evolve.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Rectangle -7500403 true true 375 195 405 345
Rectangle -7500403 true true 435 195 585 225

circle minus
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Rectangle -7500403 true true 375 195 405 345
Rectangle -7500403 true true 75 135 225 165

circle plus
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Rectangle -7500403 true true 135 75 165 225
Rectangle -7500403 true true 75 135 225 165

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person black hair red star
false
0
Circle -16777216 true false 96 -24 108
Polygon -16777216 true false 183 196 113 196 84 285 105 303 140 299 150 236 163 302 199 301 215 286
Polygon -6459832 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -6459832 true false 123 90 149 141 177 90
Rectangle -6459832 true false 123 76 176 92
Circle -6459832 true false 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -1 true false 180 90 195 90 183 160 180 195 150 195 150 105 180 90
Polygon -1 true false 120 90 105 90 114 161 120 195 150 195 150 105 120 90
Polygon -1 true false 195 90 195 90 225 135 180 150 195 90 195 90
Polygon -1 true false 105 90 105 90 75 135 120 150 105 90 105 90
Polygon -5825686 true false 150 105 150 105 135 135 105 135 135 150 120 180 150 165 180 180 165 150 195 135 165 135
Circle -16777216 true false 105 0 30
Circle -16777216 true false 129 -13 30
Circle -16777216 true false 154 -9 30
Circle -16777216 true false 173 4 30
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285

person blue team
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -6459832 true false 123 90 149 141 177 90
Rectangle -6459832 true false 123 76 176 92
Circle -6459832 true false 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -13345367 true false 180 90 195 90 183 160 180 195 150 195 150 105 180 90
Polygon -13345367 true false 120 90 105 90 114 161 120 195 150 195 150 105 120 90
Polygon -13345367 true false 195 90 195 90 225 135 180 150 195 90 195 90
Polygon -13345367 true false 105 90 105 90 75 135 120 150 105 90 105 90

person gray hair
false
2
Circle -7500403 true false 97 -21 102
Polygon -955883 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -6459832 true false 123 90 149 141 177 90
Rectangle -6459832 true false 123 76 176 92
Circle -6459832 true false 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -1 true false 180 90 195 90 183 160 180 195 150 195 150 105 180 90
Polygon -1 true false 120 90 105 90 114 161 120 195 166 196 158 110 120 90
Polygon -1 true false 195 90 195 90 225 135 180 150 195 90 195 90
Polygon -1 true false 105 90 105 90 75 135 120 150 105 90 105 90
Circle -7500403 true false 105 0 30
Circle -7500403 true false 120 -15 30
Circle -7500403 true false 150 -15 30
Circle -7500403 true false 165 0 30

person red team
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -6459832 true false 123 90 149 141 177 90
Rectangle -6459832 true false 123 76 176 92
Circle -6459832 true false 110 5 80
Line -6459832 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 105 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 105 120 90
Polygon -2674135 true false 195 90 195 90 225 135 180 150 195 90 195 90
Polygon -2674135 true false 105 90 105 90 75 135 120 150 105 90 105 90

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
