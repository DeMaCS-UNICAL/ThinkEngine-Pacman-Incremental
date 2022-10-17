%% INPUT PROJECTION %%

energizer(0,X,Y):-energizerSensor(energizer,objectIndex(Index),positionToInt(x(X))), energizerSensor(energizer,objectIndex(Index),positionToInt(y(Y))).
pellet(0,X,Y):-energizer(0,X,Y).

ghost(0,X,Y,blinky):-blinkySensor(blinky,objectIndex(Index),positionToInt(x(X))),blinkySensor(blinky,objectIndex(Index),positionToInt(y(Y))).
ghost(0,X,Y,inky):-inkySensor(inky,objectIndex(Index),positionToInt(x(X))),inkySensor(inky,objectIndex(Index),positionToInt(y(Y))).
ghost(0,X,Y,pinky):-pinkySensor(pinky,objectIndex(Index),positionToInt(x(X))),pinkySensor(pinky,objectIndex(Index),positionToInt(y(Y))).
ghost(0,X,Y,clyde):-clydeSensor(clyde,objectIndex(Index),positionToInt(x(X))), clydeSensor(clyde,objectIndex(Index),positionToInt(y(Y))).
pacman(X,Y):- pacmanSensor(pacman,objectIndex(Index),positionToInt(x(X))),pacmanSensor(pacman,objectIndex(Index),positionToInt(y(Y))).
pellet(0,X,Y):- pacdotSensor(pacdot,objectIndex(Index),positionToInt(x(X))), pacdotSensor(pacdot,objectIndex(Index),positionToInt(y(Y))).

tile(X,Y):-gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(x(X))))), gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(y(Y))))), gameManagerSensor(gameManager,objectIndex(Index),tileManager(tiles(Index1,tile(occupied(false))))).


next(0,X) :- pacmanSensor(pacman,objectIndex(Index),playerController(aiDirection(X))).
powerup(0):-gameManagerSensor(gameManager,objectIndex(Index),gameManager(scared(true))).


planLenght(2).
planStep(1).
planStep(S):-planLenght(N), planStep(S-1), S<=N.
distance(1..10).
maxN(10).
move("left").
move("right").
move("up").
move("down").


opposite("right","left").
opposite("up","down").
opposite(X,Y):-opposite(Y,X).

pellet(S,X,Y):-pellet(S-1,X,Y), not reach(S-1,X,Y), planStep(S).

energizer(S,X,Y):-energizer(S-1,X,Y), not reach(S-1,X,Y), planStep(S).
ghost(S,X,Y,G):-ghost(0,X,Y,G), planStep(S).
powerup(S):-reach(S-1,X,Y), energizer(S-1,X,Y).
powerup(S+1):-powerup(S), planStep(S).



{next(S,Move) : move(Move)}=1 :- planStep(S).

move(S,1,0):-next(S,"right").
move(S,-1,0):-next(S,"left").
move(S,0,1):-next(S,"up").
move(S,0,-1):-next(S,"down").

nextCell(S,X+Dx,Y+Dy) :- pacman(S-1,X, Y), move(S,Dx,Dy), tile(X+Dx,Y+Dy).
moveOk(S) :- nextCell(S,X,Y).
:- not moveOk(S), planStep(S).


dead(S):-ghost(S,X,Y,_),reach(S,X,Y).

reach(S,0,X,Y):- nextCell(S,X,Y).
reach(0,0,X,Y):-pacman(X,Y).
reach(0,1,X+Dx,Y+Dy) :- reach(0,0,X,Y), move(0,Dx,Dy), tile(X+Dx,Y+Dy).
reach(S,N+1,X+Dx,Y+Dy) :- reach(S,N,X,Y), not intersection(X,Y), move(S,Dx,Dy), tile(X+Dx,Y+Dy), maxN(MN), N<=MN.

notLastReached(S,N):-reach(S,N,_,_), reach(S,N1,_,_), N<N1.
lastReached(S,X,Y):- reach(S,N,X,Y), not notLastReached(S,N).
pacman(S,X,Y) :- lastReached(S,X,Y).

intersection(X,Y):-tile(X1,Y), tile(X,Y1), tile(X,Y), Dx=X1-X, Dx*Dx=1, Dy=Y1-Y, Dy*Dy=1. 

distancePacmanNextGhost(S,D, G) :- nextCell(S,Xp, Yp), ghost(S,Xg, Yg, G), min_distance(Xp,Yp,Xg,Yg,D).

%notMinDistancePacmanNextGhost(S,X) :- distancePacmanNextGhost(S,X,_), distancePacmanNextGhost(S,Y,_), distance(X), X>Y.
%minDistancePacmanNextGhost(S,MD) :- not notMinDistancePacmanNextGhost(S,MD), distancePacmanNextGhost(S,MD,_).

:~ dead(S). [S@6, S]
%:~ powerup(S), ghost(S-1,X,Y,_), not reach(S,X,Y), planStep(S). [1@5, S,X,Y]

:~ energizer(S-1,X,Y), not reach(S,X,Y), not powerup(S),planStep(S). [1@4, S,X,Y]

:~ distancePacmanNextGhost(S,MD,_), Min=10-MD, not powerup(S), planStep(S). [Min@3, Min,MD,S]
:~ distancePacmanNextGhost(S,MD,_), powerup(S), planStep(S). [MD@3, MD,S]

:~ pellet(S-1,X,Y), not reach(S,X,Y),  planStep(S). [1@2, S,X,Y]

:~ next(S-1,X), next(S,Y), opposite(X,Y). [1@1, X,Y,S]


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
actionArgument(S,"ai", "2"):-planStep(S).
actionArgument(S,"Direction", X):-next(S,X),planStep(S).
actionArgument(S,"Order", S):-next(S,_),planStep(S).
actionArgument(S,"PlanLength", N):-planLenght(N), planStep(S).
actionArgument(S,"X", X):-pacman(S-1,X,_),planStep(S).
actionArgument(S,"Y", X):-pacman(S-1,_,X),planStep(S).

#show applyAction/2.
#show actionArgument/3.
%#show intersection/2.
%#show reach/4.
%#show eaten/2.
%#show previous_action/2.
#show pacman/2.
#show pacman/3.
%#show next/2.
%#show lastReached/3.
%#show pacmanSensor/3.
%#show opposite/2.