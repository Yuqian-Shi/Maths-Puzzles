%  File     	: proj2.pl
%  Author   	: Yuqian Shi
%  Purpose  	: Prolog code for number puzzle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Define the solution by defining a predicate puzzle_solution/1:
%%	 puzzle_solution(Puzzle).
%%  where Puzzle will be a proper list of proper lists,
%% A numbers puzzle will be represented as a list of lists,
%%  each of the same length, representing a single row of the puzzle.
%% The first element of each list is considered to be the header for that row.
%% Each element but the first of the first list in the puzzle is considered to be
%%  the header of the corresponding column of the puzzle.
%% The first element of the first element of the list is the corner square of the puzzle,
%%  and thus is ignored.
%% The way I do it is checking each row and column seperately to see whether all of them meet all the requirements.
%% As long as some requirement is not met, cut the search to save time.
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Define the solution predicate and relative predicates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- ensure_loaded(library(clpfd)).
puzzle_solution(Puzzle):-
	length(Puzzle,Len),
	(Len =:=3 ->
		puzzle_solution2(Puzzle)
	;Len =:=4->
		puzzle_solution3(Puzzle)
	;Len =:=5->
		puzzle_solution4(Puzzle)
	).

% Pattern match: for 2*2 puzzle.
% First check whether the numbers on the diagonal line from upper left to lower right.
%  If not equal, cut the search to save time.
% Then use the predicate valid/1 to check each row and each column, ensure that they meet the requirements.
%  If any row or any column failed to meet the requirements, then cut the search.

puzzle_solution2([[_,C1,C2], [R1,R11,R12], [R2,R21,R22]]) :-
	R11 = R22,
	valid([R1,R11,R12]),
	valid([R2,R21,R22]),
	valid([C1,R11,R21]),
	valid([C2,R12,R22]).

% puzzle_solution([[_,Col1,Col2,Col3], [Row1,Row1Col1,Row1Col2,Row1Col3], [Row2,Row2Col1,Row2Col2,Row2Col3],
%	 [Row3,Row3Col1,Row3Col2,Row3Col3]])
% Pattern match: for 3*3 puzzle.
% The same process as the one for 2*2 puzzle.

puzzle_solution3([[_,C1,C2,C3], [R1,R11,R12,R13], [R2,R21,R22,R23], [R3,R31,R32,R33]]) :-
	R11 = R22, R22 = R33,
	Puzzle = [[_,C1,C2,C3], [R1,R11,R12,R13], [R2,R21,R22,R23], [R3,R31,R32,R33]],
	dia_check(Puzzle),
	valid([R1,R11,R12,R13]),
	valid([R2,R21,R22,R23]),
	valid([R3,R31,R32,R33]),
	valid([C1,R11,R21,R31]),
	valid([C2,R12,R22,R32]),
	valid([C3,R13,R23,R33]).

% puzzle_solution([[_,Col1,Col2,Col3,Col4], [Row1,Row1Col1,Row1Col2,Row1Col3,Row1Col4], [Row2,Row2Col1,Row2Col2,Row2Col3,Row2Col4],
%	 [Row3,Row3Col1,Row3Col2,Row3Col3,Row3Col4]], [Row4,Row4Col1,Row4Col2,Row4Col3,Row4Col4])
% Pattern match: for 3*3 puzzle.
% The same process as the one for 2*2 puzzle.

puzzle_solution4(	[[_,C1,C2,C3,C4],
					[R1,R11,R12,R13,R14],
					[R2,R21,R22,R23,R24],
					[R3,R31,R32,R33,R34],
					[R4,R41,R42,R43,R44]]
					) :-
	R11 = R22, R22 = R33, R33 = R44,
	valid([R1,R11,R12,R13,R14]),
	valid([R2,R21,R22,R23,R24]),
	valid([R3,R31,R32,R33,R34]),
	valid([R4,R41,R42,R43,R44]),
	valid([C1,R11,R21,R31,R41]),
	valid([C2,R12,R22,R32,R42]),
	valid([C3,R13,R23,R33,R43]),
	valid([C4,R14,R24,R34,R44]).

% valid/1
% valid checks whether a row/column of the puzzle meet all the requirements.
% 1) all the elements except the header is a single digit 1-9. If not, cut the search.
% 2) no repeated digits.
% 3) the header of the list is the sum or the product of the rest elements.
valid([X|Xs]) :-
	inrange(Xs),
	all_distinct(Xs),
	head_check([X|Xs]).

% inrange/1
% Make sure the element is a single digit in 1-9.
inrange([]).
inrange([X|Xs]) :-
	between(1,9,X),
	inrange(Xs).


% d2_nth(Puzzle,Raw,Col,Element)
% d2_nth/4 is used to get an element form a 2D list.
% D2List is the 2D list, in this case, it is the puzzle.
% Row and Col are the first and second indexes respectively.
d2_nth(D2List,Raw,Col,Element):-
    nth0(Raw, D2List, List1),
    nth0(Col, List1, Element).



% dia_check(Puzzle)
% dia_check/1 is used to perform the diagonal check for the puzzle.
dia_check(Puzzle):-
	length(Puzzle,Len),
	Len1 is Len -1,
	d2_nth(Puzzle,Len1,Len1,E),
	dia_check(Puzzle,Len1,E).
dia_check(Puzzle,Index,Last_value):-
	(Index =:= 1 ->
		d2_nth(Puzzle,1,1,Last_value)
	;Index>1->
    	d2_nth(Puzzle,Index,Index,Last_value),
    	Index1 is Index - 1,
    	dia_check(Puzzle,Index1,Last_value)
).


% head_check(Row)
% head_check/1 checks whether the sum or
% multiplicative equals to first elements of the given row

head_check(Row):-
	head_check(Row,0,_,1,_).
head_check([Item1],Sum,Sum,Pdt,Pdt):-
	Item1 = Sum;
	Item1 = Pdt.
head_check([Item1,Item2 | Tail],Acc_s,Sum,Acc_p,Pdt):-
	Acc_s1 is Acc_s + Item2,
	Acc_p1 is Acc_p * Item2,
	head_check([Item1| Tail],Acc_s1,Sum,Acc_p1,Pdt).
