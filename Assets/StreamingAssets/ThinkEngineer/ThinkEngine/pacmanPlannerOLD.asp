%% INPUT PROJECTION %%

energizer(X,Y):-energizerSensor(energizer,objectIndex(Index),positionToInt(x(X))), energizerSensor(energizer,objectIndex(Index),positionToInt(y(Y))).
ghost(X,Y,blinky):-blinkySensor(blinky,objectIndex(Index),positionToInt(x(X))),blinkySensor(blinky,objectIndex(Index),positionToInt(y(Y))).
ghost(X,Y,inky):-inkySensor(inky,objectIndex(Index),positionToInt(x(X))),inkySensor(inky,objectIndex(Index),positionToInt(y(Y))).
ghost(X,Y,pinky):-pinkySensor(pinky,objectIndex(Index),positionToInt(x(X))),pinkySensor(pinky,objectIndex(Index),positionToInt(y(Y))).
ghost(X,Y,clyde):-clydeSensor(clyde,objectIndex(Index),positionToInt(x(X))), clydeSensor(clyde,objectIndex(Index),positionToInt(y(Y))).
pacman(X,Y):- pacmanSensor(pacman,objectIndex(Index),positionToInt(x(X))),pacmanSensor(pacman,objectIndex(Index),positionToInt(y(Y))).
pellet(X,Y):- pacdotSensor(pacdot,objectIndex(Index),positionToInt(x(X))), pacdotSensor(pacdot,objectIndex(Index),positionToInt(y(Y))).
tile(X,Y):-gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(x(X))))), gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(y(Y))))), gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(occupied(false))))).
previous_action(X) :- pacmanSensor(pacman,objectIndex(Index),playerController(aiDirection(X))).
powerup:-gameManagerSensor(gameManager,objectIndex(Index),gameManager(scared(true))).

next(left) | next(right) | next(up) | next(down).
%:-next(left), not_next(left).
%:-next(right), not_next(right).
%:-next(up), not_next(up).
%:-next(down), not_next(down).

distance(1..10).

nextCell(X,Y) :- pacman(Px, Y), next(right), X=Px+1, tile(X,Y).
nextCell(X,Y) :- pacman(Px, Y), next(left), X=Px-1, tile(X,Y).
nextCell(X,Y) :- pacman(X, Py), next(up), Y=Py+1, tile(X,Y).
nextCell(X,Y) :- pacman(X, Py), next(down), Y=Py-1, tile(X,Y).
moveOk :- nextCell(X,Y).
:- not moveOk.

empty(X,Y) :- tile(X,Y), not pellet(X,Y).
distancePacmanNextGhost(D, G) :- nextCell(Xp, Yp), ghost(Xg, Yg, G), min_distance(Xp,Yp,Xg,Yg,D).

notMinDistancePacmanNextGhost(X) :- distancePacmanNextGhost(X,_), distancePacmanNextGhost(Y,_), distance(X), X>Y.
minDistancePacmanNextGhost(MD) :- not notMinDistancePacmanNextGhost(MD), distancePacmanNextGhost(MD,_).
%minDistancePacmanNextGhost(MD) :- #min{D : distancePacmanNextGhost(D, _)} = MD, distance(MD).

:~ minDistancePacmanNextGhost(MD), Min=10-MD, not powerup. [Min@4, Min,MD]
:~ minDistancePacmanNextGhost(MD), powerup. [MD@4, MD]

distancePellet(D,X,Y) :- nextCell(Xp, Yp), pellet(X, Y), min_distance(Xp,Yp,X,Y,D).

notMinDistancePellet(X) :- distancePellet(X,_,_), distancePellet(Y,_,_), distance(X), X>Y.
distanceClosestPellet(MD) :- not notMinDistancePellet(MD), distancePellet(MD,_,_).
closestPellet(X,Y):-distanceClosestPellet(D),distancePellet(MD,X,Y) .

:~ nextCell(X,Y), empty(X,Y). [1@3, X,Y]
:~ nextCell(X,Y), closestPellet(X,Y), distanceClosestPellet(D). [D@2, D,X,Y]
:~ previous_action(X), next(Y), X!=Y. [1@1, X,Y]


adjacent(X1,Y1,X2,Y2) :- tile(X1,Y1), tile(X2,Y2), step(DX,DY), X2 = X1 + DX, Y2 = Y1 + DY.
adjacent(X1,Y1,X2,Y2) :- tile(X1,Y1), tile(X2,Y2), step(DX,DY), X2 = X1 - DX, Y2 = Y1 - DY.
step(0,1).
step(1,0).

distance(X1,Y1,X2,Y2,1) :- tile(X1,Y1), adjacent(X1,Y1,X2,Y2).
distance(X1,Y1,X3,Y3,Dp1) :- distance(X1,Y1,X2,Y2,D), adjacent(X2,Y2,X3,Y3), D = Dp1 - 1, distance(Dp1).

%min_distance(X1,Y1,X2,Y2,MD) :- #min{D : distance(X1,Y1,X2,Y2,D)} = MD, tile(X1,Y1), tile(X2,Y2), distance(MD).

nonMinDistance(X1,Y1,X2,Y2,D1) :- distance(X1,Y1,X2,Y2,D1), distance(X1,Y1,X2,Y2,D2), D1>D2.
min_distance(X1,Y1,X2,Y2,MD):- not nonMinDistance(X1,Y1,X2,Y2,MD), distance(X1,Y1,X2,Y2,MD).

applyAction(0,"MovePacman").
actionArgument(0,"ai", "1").
actionArgument(0,"Direction", X):-next(X).
