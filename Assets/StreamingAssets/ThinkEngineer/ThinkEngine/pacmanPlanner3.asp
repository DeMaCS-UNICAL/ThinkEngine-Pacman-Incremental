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

next("left") | next("right") | next("up") | next("down").
move(1,0):-next("right").
move(-1,0):-next("left").
move(0,1):-next("up").
move(0,-1):-next("down").

opposite(right,left).
opposite(up,down).
opposite(X,Y):-opposite(Y,X).

distance(1..5).

nextCell(X+Dx,Y+Dy) :- pacman(X, Y), move(Dx,Dy), tile(X+Dx,Y+Dy).
moveOk :- nextCell(X,Y).
:- not moveOk.

empty(X,Y) :- tile(X,Y), not pellet(X,Y).
distancePacmanNextGhost(D, G) :- nextCell(Xp, Yp), ghost(Xg, Yg, G), min_distance(Xp,Yp,Xg,Yg,D).

notMinDistancePacmanNextGhost(X) :- distancePacmanNextGhost(X,_), distancePacmanNextGhost(Y,_), distance(X), X>Y.
minDistancePacmanNextGhost(MD) :- not notMinDistancePacmanNextGhost(MD), distancePacmanNextGhost(MD,_).

:~ minDistancePacmanNextGhost(MD), Min=10-MD, not powerup. [Min@4, Min,MD]
:~ minDistancePacmanNextGhost(MD), powerup. [MD@4, MD]

distancePellet(D,X,Y) :- nextCell(Xp, Yp), pellet(X, Y), min_distance(Xp,Yp,X,Y,D).

notMinDistancePellet(X) :- distancePellet(X,_,_), distancePellet(Y,_,_), distance(X), X>Y.
distanceClosestPellet(MD) :- not notMinDistancePellet(MD), distancePellet(MD,_,_).
closestPellet(X,Y):-distanceClosestPellet(D),distancePellet(MD,X,Y) .

:~ nextCell(X,Y), empty(X,Y). [1@3, X,Y]
:~ nextCell(X,Y), closestPellet(X,Y), distanceClosestPellet(D). [D@2, D,X,Y]
:~ previous_action(X), next(Y), opposite(X,Y). [1@1, X,Y]


distance(X,X1,D):- D=X-X1, tile(X,_), tile(X1,_), distance(D).
distance(X,X1,D):- D=X-X1, tile(_,X), tile(_,X1), distance(D).
distance(X1,X,D):-distance(X,X1,D).
distance(X1,Y1,X2,Y2,X) :- tile(X1,Y1), tile(X2,Y2), distance(X1,X2,D), distance(Y1,Y2,D1), X=D+D1.


nonMinDistance(X1,Y1,X2,Y2,D1) :- distance(X1,Y1,X2,Y2,D1), distance(X1,Y1,X2,Y2,D2), D1>D2.
min_distance(X1,Y1,X2,Y2,MD):- not nonMinDistance(X1,Y1,X2,Y2,MD), distance(X1,Y1,X2,Y2,MD).

applyAction(0,"MovePacman").
actionArgument(0,"ai", "3").
actionArgument(0,"Direction", X):-next(X).
actionArgument(0,"X", X):-pacman(X,_).
actionArgument(0,"Y", X):-pacman(_,X).


#show applyAction/2.
#show actionArgument/3.