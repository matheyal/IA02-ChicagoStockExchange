% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------- INITIALISATION DU JEU ----------------------------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

initBourse([[ble,7],[mais,6], [riz,6], [cacao,6], [cafe,6], [sucre,6]]).
initPositionTrader(PT):-random(1,10,PT).
initReserve1([]).
initReserve2([]).

initJetons([ble,ble,ble,ble,ble,ble,mais,mais,mais,mais,mais,mais,riz,riz,riz,riz,riz,riz,cacao,cacao,cacao, cacao,cacao,cacao,cafe,cafe,cafe,cafe,cafe,cafe,sucre,sucre,sucre,sucre,sucre,sucre]).

%remplirPile(+Jetons, +Pile, ?newJetons)
%Remplit Pile avec 4 jetons aléatoires extraits de la liste Jetons et retourne newJetons qui est Jetons privé des jetons tirés
remplirPile(Jetons, [J1,J2,J3,J4], Jetons5):- 	extract_jeton(Jetons, Jetons2, J1), 
						extract_jeton(Jetons2, Jetons3, J2),
						extract_jeton(Jetons3, Jetons4, J3),
						extract_jeton(Jetons4, Jetons5, J4).
%extract_jeton(+Liste1, ?Liste2, ?J)
%Renvoie un jeton aléatoire de Jetons dans J puis le retire de Jetons pour obtenir Jetons2
extract_jeton(Jetons, Jetons2, J):-	length(Jetons, L), %L est la longueur de la liste des Jetons (=nombre de jetons restant à mettre dans les piles)
					L2 is L+1,
					random(1, L2, N), %N aléatoire entre 1 et L+1
					nth(N, Jetons, J), select(J, Jetons, Jetons2),!.

initPiles([Pile1, Pile2, Pile3, Pile4, Pile5, Pile6, Pile7, Pile8, Pile9]):-  
	initJetons(Jetons), 
	remplirPile(Jetons, Pile1, Jetons2), 
	remplirPile(Jetons2, Pile2, Jetons3), 
	remplirPile(Jetons3, Pile3, Jetons4), 
	remplirPile(Jetons4, Pile4, Jetons5), 
	remplirPile(Jetons5, Pile5, Jetons6), 
	remplirPile(Jetons6, Pile6, Jetons7), 
	remplirPile(Jetons7, Pile7, Jetons8), 
	remplirPile(Jetons8, Pile8, Jetons9), 
	remplirPile(Jetons9, Pile9, _).

plateau_depart(Plateau):-initPlateau(_,_,_,_,_,Plateau).
%plateau_depart(Plateau):-initPlateau(Piles,Bourse,PositionTrader,Reserve1,Reserve2,Plateau).
initPlateau(Piles, Bourse, PositionTrader, Reserve1, Reserve2, Plateau) :- initPiles(Piles), initBourse(Bourse), initPositionTrader(PositionTrader), initReserve1(Reserve1), initReserve2(Reserve2), append([Piles], [Bourse, PositionTrader, Reserve1, Reserve2], Plateau).

% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------- AFFICHAGE DU PLATEAU -----------------------------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

% Affichage des ressources
afficher(ble):-write(' ble ').
afficher(cafe):-write('cafe ').
afficher(cacao):-write('cacao').
afficher(mais):-write('mais ').
afficher(sucre):-write('sucre').
afficher(riz):-write(' riz ').

% Affichage de la bourse 
afficherBourse([]).
afficherBourse([H|T]):- nth(1,H,Marchandise), nth(2,H,Valeur), afficher(Marchandise), write('  '), write(Valeur), nl, afficherBourse(T).

% Affichage des piles de marchandises
afficherPiles([]) :- nl.
afficherPiles([[H|_]|T]) :- write(' '), afficher(H), write(' '), afficherPiles(T).

% Affichage trader
afficherTrader(1) :- write('   x   '), nl, !.
afficherTrader(PositionTrader) :- write('       '), N is PositionTrader-1, afficherTrader(N).

% Affichage de la reserve
afficherReserve([]):- nl.
afficherReserve([H|T]) :- afficher(H), write(' '), afficherReserve(T).

% Affichage plateau
afficherPlateau([Piles, Bourse, PositionTrader, Reserve1, Reserve2]) :- 
	nl,write('* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'),nl,
	afficherPiles(Piles),
	afficherTrader(PositionTrader),nl, 
	afficherBourse(Bourse), nl, 
	write('Reserve J1 : '), afficherReserve(Reserve1), 
	write('Reserve J2 : '), afficherReserve(Reserve2), nl,
	write('* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *'),nl,nl.

% test fonction random
get_random(0):-nl,!.
get_random(X):- random(1,10,N), write(N),nl, Y is X-1, get_random(Y).


% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------- GESTION DU JEU ---------------------------------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

% Un coup est une liste de la forme [joueur, deplacementTrader, ressourceGardée, ressourceVendue]

%coupPossible([Piles, _, PositionTrader, _, _], [_, Deplacement, Garde, Vendu]):- verifPriseJeton([Piles, _, PositionTrader, _, _], Deplacement, Garde, Vendu).

% deplacementValide(+Deplacement)
% Teste si le déplacement demandé est valide (entre 1 et 3). Sinon, demande une nouvelle valeur de déplacement
deplacementValide(Deplacement):- Deplacement>=1, Deplacement=<3.

% verifPriseJeton(+Piles, +PosTrader, +Deplacement, +Garde, +Vendu)
% vérifie si les jetons gardé et vendu sont ceux du dessus des piles adjacentes à la position du trader après déplacement
% Remarque : il faut changer memberchk pour prendre en compte le cas ou le joueur garde et vend la même ressource
verifPriseJeton([Piles, _, PositionTrader, _, _], Deplacement, Garde, Vendu) :- 
	NewPos is PositionTrader+Deplacement, 
	getPilesAutourPosition(Piles, NewPos, [Avant|_], [Apres|_]), 
	select(Garde,[Avant,Apres], L),!, 
	select(Vendu,L, _).

% caculeNouvellePosition(+PositionTrader, +Deplacement, +Piles, ?NouvellePosition)
% Calcule la nouvelle position du trader apres un déplacement selon le nombre de piles restantes
calculNouvellePosition(PositionTrader, Deplacement, Piles, NouvellePosition):- 
	length(Piles, L), 
	NouvellePosition is (PositionTrader+Deplacement) mod L, 
	NouvellePosition>0, !.
calculNouvellePosition(_, _, Piles, NouvellePosition):-length(Piles, NouvellePosition).

% getPilesAutourPosition(+Piles, +Pos, ?PilePrecedente, ?PileSuivante)
% Retourne la pile de la liste Piles qui est juste avant la position du trader et celle qui est juste après
getPilesAutourPosition(Piles, Pos, PilePrecedente, PileSuivante) :- 
	calculNouvellePosition(Pos,-1,Piles, PosAv), 
	calculNouvellePosition(Pos,1,Piles, PosSucc), 
	nth(PosAv, Piles, PilePrecedente), 
	nth(PosSucc, Piles, PileSuivante).

% getDeplacement(?Déplacement)
% Lire déplacement du joueur jusqu'à ce que le déplacement soit valide
getDeplacement(Deplacement) :- write('Entrez votre déplacement (entre 1 et 3) : '), read(Deplacement), deplacementValide(Deplacement), !.
getDeplacement(Deplacement) :- write('Déplacement non valide. '), getDeplacement(Deplacement). 

% getPrisesPossibles(+Plateau, +Deplacement))
% Afficher prises de jetons possibles après le déplacement
afficherPrisesPossibles([Piles, _, PositionTrader,_,_], Deplacement) :- 
	calculNouvellePosition(PositionTrader, Deplacement, Piles, NewPos), 
	getPilesAutourPosition(Piles, NewPos, [Avant|_], [Apres|_]), 
	write('Prises possibles : '),
	afficher(Avant), write(' '), afficher(Apres), nl.

% getPriseJoueur(+Plateau, +Déplacement, ?Garde, ?Vend)
% Obtenir le choix de prise de jetons du joueur (on considere que les valeurs rentrées sont celles affichées par afficherPrisesPossibles().)
getPriseJoueur(Plateau, Deplacement, Garde, Vend) :- 
	write('Entrez le jeton gardé : '), read(Garde), 
	write('Entrez le jeton vendu : '), read(Vend),
	verifPriseJeton(Plateau, Deplacement, Garde, Vend),!.
getPriseJoueur(Plateau, Deplacement, Garde, Vend) :- 
	write('Prise invalide.'), nl, getPriseJoueur(Plateau, Deplacement, Garde, Vend).

% getCoup(+Plateau, ?Coup)
% Construction d'un coup
getCoup(Plateau, [_,Deplacement, Garde, Vendu]) :- 
	getDeplacement(Deplacement),
	afficherPrisesPossibles(Plateau, Deplacement),
	getPriseJoueur(Plateau, Deplacement, Garde, Vendu).
	
replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O, replace(O, R, T, T2).

% miseAJourPiles(+Piles, +Position, +Coup, ?NewPiles)
% Enlève des piles les jetons piochés par le joueur
miseAJourPiles(Piles, Position, Garde, Vend, NewPiles) :-
	getPilesAutourPosition(Piles, Position, [Garde|Q1], [Vend|Q2]), 
	select(Garde,[Garde|Q1],Pile1), select(Vend, [Vend|Q2], Pile2),
	replace([Garde|Q1], Pile1, Piles, NewPiles1), 
	replace([Vend|Q2], Pile2, NewPiles1, NewPiles),!.
	
test(Plateau, _, NewPiles) :- 
	plateau_depart(Plateau), 
	afficherPlateau(Plateau), 
	getCoup(Plateau, [j1,Deplacement, Garde, Vendu]), 
	Plateau = [Piles, _, PositionTrader, _, _], 
	calculNouvellePosition(PositionTrader, Deplacement, Piles, NouvellePosition), 
	miseAJourPiles(Piles, NouvellePosition, [_,_,Garde, Vendu], NewPiles).

% jouerTour(+Plateau, +j1, ?NewPlateau)
% Permet de jouer un tour pour le joueur 1
jouerTour(Plateau, j1, [NewPiles, NewBourse, NewPosition, NewReserve1, Reserve2]):- 
	Plateau = [Piles, Bourse, PositionTrader, Reserve1, Reserve2],
	afficherPlateau(Plateau),
	write('-------------------------- Tour de J1 ---------------------------'), nl,
	getCoup(Plateau, [j1, Deplacement, Garde, Vend]),
	calculNouvellePosition(PositionTrader, Deplacement, Piles, NewPosition), 
	miseAJourPiles(Piles, NewPosition, Garde, Vend, NewPiles),
	%NewBourse=Bourse,
	append(Reserve1, [Garde], NewReserve1),
	vente(Vend, Bourse, NewBourse),!.

% jouerTour(+Plateau, +j2, ?NewPlateau)
% Permet de jouer un tour pour le joueur 2
jouerTour(Plateau, j2, [NewPiles, NewBourse, NewPosition, Reserve1, NewReserve2]):- 
	Plateau = [Piles, Bourse, PositionTrader, Reserve1, Reserve2],
	afficherPlateau(Plateau),
	write('-------------------------- Tour de J2 ---------------------------'), nl,
	getCoup(Plateau, [j2, Deplacement, Garde, Vend]),
	calculNouvellePosition(PositionTrader, Deplacement, Piles, NewPosition), 
	miseAJourPiles(Piles, NewPosition, Garde, Vend, NewPiles),
	%NewBourse = Bourse,
	append(Reserve2, [Garde], NewReserve2),
	vente(Vend, Bourse, NewBourse),!.
	
% vente(+Vend, +Bourse, ?NewBourse) 
% Met à jour les valeurs des marchandises dans la bourse suite à un coup	
vente(Vend, Bourse, NewBourse) :- vente(Vend, Bourse, Bourse, NewBourse).
vente(Vend, Bourse, [[Marchandise,_]|Q], NewBourse) :- Vend \= Marchandise, vente(Vend, Bourse, Q, NewBourse).
vente(Vend, Bourse, [[Vend,Val]|_], NewBourse) :-
	NewVal is Val-1,
	replace([Vend,Val], [Vend,NewVal], Bourse, NewBourse),!.

% Prédicat qui lance le jeu et le fait tourner en boucle jusqu'à la condition de fin.	
jouer :- 
	write('------------------------------------------------------------------'), nl,
	write('--------------------- CHICAGO STOCK EXCHANGE ---------------------'),nl,
	write('------------------------------------------------------------------'), nl,nl,nl,
	jouer(0, _).
jouer(0, _) :- 
	write('Qui commence ? (1 ou 2) : '),
	read(N), %Tester si N = 1 ou 2
	plateau_depart(Plateau),
	jouer(N, Plateau),!.
jouer(N,Plateau) :-
	M is N mod 2, %N est impair --> 12 joue
	M \= 0,
	jouerTour(Plateau, j1, NewPlateau),
	%jeuFini(NewPlateau),
	N2 is N+1,
	jouer(N2,NewPlateau).
jouer(N,Plateau) :-
	0 is N mod 2, %N est pair --> J2 joue
	jouerTour(Plateau, j2, NewPlateau),
	%jeuFini(NewPlateau),
	N2 is N+1,
	jouer(N2,NewPlateau).
	
% jeuFini(+Plateau)
% retourne vrai si le jeu est fini (lorsqu'il reste 2 piles ou moins)	

