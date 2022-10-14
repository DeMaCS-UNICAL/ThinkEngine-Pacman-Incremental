%% INPUT PROJECTION %%

energizer(0,X,Y):-energizerSensor(energizer,objectIndex(Index),positionToInt(x(X))), energizerSensor(energizer,objectIndex(Index),positionToInt(y(Y))).

ghost(0,X,Y,blinky):-blinkySensor(blinky,objectIndex(Index),positionToInt(x(X))),blinkySensor(blinky,objectIndex(Index),positionToInt(y(Y))).
ghost(0,X,Y,inky):-inkySensor(inky,objectIndex(Index),positionToInt(x(X))),inkySensor(inky,objectIndex(Index),positionToInt(y(Y))).
ghost(0,X,Y,pinky):-pinkySensor(pinky,objectIndex(Index),positionToInt(x(X))),pinkySensor(pinky,objectIndex(Index),positionToInt(y(Y))).
ghost(0,X,Y,clyde):-clydeSensor(clyde,objectIndex(Index),positionToInt(x(X))), clydeSensor(clyde,objectIndex(Index),positionToInt(y(Y))).
pacman(0,X,Y):- pacmanSensor(pacman,objectIndex(Index),positionToInt(x(X))),pacmanSensor(pacman,objectIndex(Index),positionToInt(y(Y))).
pellet(0,X,Y):- pacdotSensor(pacdot,objectIndex(Index),positionToInt(x(X))), pacdotSensor(pacdot,objectIndex(Index),positionToInt(y(Y))).

tile(X,Y):-gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(x(X))))), gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(y(Y))))), gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(occupied(false))))).
previous_action(0,X) :- pacmanSensor(pacman,objectIndex(Index),playerController(aiDirection(X))).
powerup(0):-gameManagerSensor(gameManager,objectIndex(Index),gameManager(scared(true))).

%next(left) | next(right) | next(up) | next(down).
%:-next(left), not_next(left).
%:-next(right), not_next(right).
%:-next(up), not_next(up).
%:-next(down), not_next(down).
planLenght(2).
planStep(1).
planStep(S):-planLenght(N), planStep(S-1), S<=N.
distance(1..10).
maxN(10).
move(left).
move(right).
move(up).
move(down).

pellet(S,X,Y):-pellet(S-1,X,Y), not reach(S-1,X,Y), planStep(S).
energizer(S,X,Y):-energizer(S-1,X,Y), not reach(S-1,X,Y), planStep(S).
ghost(S,X,Y,G):-ghost(0,X,Y,G), planStep(S).
powerup(S):-reach(S-1,X,Y), energizer(S-1,X,Y).
powerup(S+1):-powerup(S), planStep(S).
previous_action(S,X) :-next(S-1,X).

intersection(X,Y):-tile(X1,Y), tile(X,Y1), tile(X,Y), Dx=X1-X, Dx*Dx=1, Dy=Y1-Y, Dy*Dy=1. 

{next(S,Move) : move(Move)}=1 :- planStep(S).
nextCell(S,Px+1,Y) :- pacman(S-1,Px, Y), next(S,right), tile(Px+1,Y).
nextCell(S,Px-1,Y) :- pacman(S-1,Px, Y), next(S,left), tile(Px-1,Y).
nextCell(S,X,Py+1) :- pacman(S-1,X, Py), next(S,up), tile(X,Py+1).
nextCell(S,X,Py-1) :- pacman(S-1,X, Py), next(S,down), tile(X,Py-1).
moveOk(S) :- nextCell(S,X,Y).
:- not moveOk(S), planStep(S).

reach(S,0,X,Y):- nextCell(S,X,Y).
reach(S,N+1,X+1,Y) :- reach(S,N,X,Y), not intersection(X,Y), next(S,right), tile(X+1,Y), max(MN), N<=MN.
reach(S,N+1,X-1,Y) :- reach(S,N,X,Y), not intersection(X,Y), next(S,left), tile(X-1,Y), max(MN), N<=MN.
reach(S,N+1,X,Y+1) :- reach(S,N,X,Y), not intersection(X,Y), next(S,up), tile(X,Y+1), max(MN), N<=MN.
reach(S,N+1,X,Y-1) :- reach(S,N,X,Y), not intersection(X,Y), next(S,down), tile(X,Y-1), max(MN), N<=MN.
notLastReached(S,N):-reach(S,N,X,Y), reach(S,N1,X1,Y1), N<N1.
lastReached(S,X,Y):- reach(S,N,X,Y), not notLastReached(S,N).
pacman(S,X,Y) :- lastReached(S,X,Y).



empty(S,X,Y) :- tile(X,Y), not pellet(S,X,Y), planStep(S).
distancePacmanNextGhost(S,D, G) :- nextCell(S,Xp, Yp), ghost(S,Xg, Yg, G), min_distance(Xp,Yp,Xg,Yg,D).

notMinDistancePacmanNextGhost(S,X) :- distancePacmanNextGhost(S,X,_), distancePacmanNextGhost(S,Y,_), distance(X), X>Y.
minDistancePacmanNextGhost(S,MD) :- not notMinDistancePacmanNextGhost(S,MD), distancePacmanNextGhost(S,MD,_).
%minDistancePacmanNextGhost(MD) :- #min{D : distancePacmanNextGhost(D, _)} = MD, distance(MD).

:~ minDistancePacmanNextGhost(S,MD), Min=10-MD, not powerup(S), planStep(S). [Min@4, Min,MD,S]
:~ minDistancePacmanNextGhost(S,MD), powerup(S), planStep(S). [MD@4, MD,S]

distancePellet(S,D,X,Y) :- nextCell(S,Xp, Yp), pellet(S,X, Y), min_distance(Xp,Yp,X,Y,D).

notMinDistancePellet(S,X) :- distancePellet(S,X,_,_), distancePellet(S,Y,_,_), distance(X), X>Y.
distanceClosestPellet(S,MD) :- not notMinDistancePellet(S,MD), distancePellet(S,MD,_,_).
closestPellet(S,X,Y):-distanceClosestPellet(S,D),distancePellet(S,MD,X,Y).

:~ nextCell(S,X,Y), empty(S,X,Y). [1@3, X,Y,S]
:~ nextCell(S,X,Y), closestPellet(S,X,Y), distanceClosestPellet(S,D). [D@2, D,X,Y,S]
:~ previous_action(S-1,X), next(S,Y), X!=Y. [1@1, X,Y,S]


adjacent(X1,Y1,X2,Y2) :- tile(X1,Y1), tile(X2,Y2), step(DX,DY), X2 = X1 + DX, Y2 = Y1 + DY.
adjacent(X1,Y1,X2,Y2) :- tile(X1,Y1), tile(X2,Y2), step(DX,DY), X2 = X1 - DX, Y2 = Y1 - DY.
step(0,1).
step(1,0).

distance(X1,Y1,X2,Y2,1) :- tile(X1,Y1), adjacent(X1,Y1,X2,Y2).
distance(X1,Y1,X3,Y3,Dp1) :- distance(X1,Y1,X2,Y2,D), adjacent(X2,Y2,X3,Y3), D = Dp1 - 1, distance(Dp1).

%min_distance(X1,Y1,X2,Y2,MD) :- #min{D : distance(X1,Y1,X2,Y2,D)} = MD, tile(X1,Y1), tile(X2,Y2), distance(MD).

nonMinDistance(X1,Y1,X2,Y2,D1) :- distance(X1,Y1,X2,Y2,D1), distance(X1,Y1,X2,Y2,D2), D1>D2.
min_distance(X1,Y1,X2,Y2,MD):- not nonMinDistance(X1,Y1,X2,Y2,MD), distance(X1,Y1,X2,Y2,MD).

applyAction(S,"MovePacman"):-planStep(S).
actionArgument(S,"ai", "1"):-planStep(S).
actionArgument(S,"Direction", X):-next(S,X).
actionArgument(S,"Order", S):-next(S,_).
actionArgument(S,"PlanLength", N):-planLenght(N), planStep(S).
actionArgument(S,"X", X):-pacman(S-1,X,_), planStep(S).
actionArgument(S,"Y", Y):-pacman(S-1,_,Y), planStep(S).
#show applyAction/2,actionArgument/3.