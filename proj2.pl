%  File     	: proj2.pl
%  Author   	: Yuqian Shi
%  Purpose  	: Prolog code for number puzzle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% General approach:
%% Assuming that any given puzzle is a proper puzzle.
%% 1. Extract rows and columns.
%% 2. Perform the diagonal check.
%% 3. Perform check on each row and column.
%% If some of the rules are not satisified, then cut them(during the check function).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- ensure_loaded(library(clpfd)).


puzzle_solution(Puzzle):-
	Rows = Puzzle,
	transpose(Rows, Cols),
	% The firs row of Rows and Cols are the sums and productions.
	% Therefore, remove them.
	remove_head(Rows,Row1),
	remove_head(Cols,Col1),
	% Perform the diagonal check.
	dia_check(Puzzle),
	% Perform check on each row and column.
	check(Col1,Row1).

% check/1
% Perform checks on the given lists of rows and columns.
% For each element(row or column), call valid to perfoem the examination.
check([],[]).
check([Head_cols|Tail_cols],[Head_rows|Tail_rows]):-
	valid(Head_cols),
	valid(Head_rows),
	check(Tail_cols,Tail_rows).


% remove_head/1
% Returns all the elements in a list but the first one.
% In this case it is used to remove the first row and column of the puzzle.
remove_head([_|Tail],Tail).


% valid/1
% valid checks whether a row/column of the puzzle meet all the requirements.
% 1) All the elements except the header is a single digit 1-9. If not, cut the search.
% 2) No repeated digits.
% 3) The head of the list is the sum or the product of the rest elements.
valid([Head|Tail]) :-
	inrange(Tail),
	all_distinct(Tail),
	head_check([Head|Tail]).


% inrange/1
% Make sure the element is a single digit in 1-9.
inrange([]).
inrange([Digit|Tail]) :-
	between(1,9,Digit),
	inrange(Tail).


% d2_nth/4
% Used to get an element form a 2D list.
% D2List is the 2D list, in this case, it is the puzzle.
% Row and Col are the first and second indexes respectively.
d2_nth(D2List,Raw,Col,Element):-
    nth0(Raw, D2List, List1),
    nth0(Col, List1, Element).


% dia_check/1
% Used to perform the diagonal check form the puzzle.
% The approach is get diagonal elements out and compare with the initial one.
dia_check(Puzzle):-
	length(Puzzle,Len),
	Len1 is Len -1,
	d2_nth(Puzzle,Len1,Len1,E),
	dia_check(Puzzle,Len1,E).
% diagonal check recursively.
dia_check(Puzzle,Index,Last_value):-
	(Index =:= 1 ->
		% Stop at index 1,
		% since elemet at the left-top of the puzzle is meaningless.
		d2_nth(Puzzle,1,1,Last_value)
	;Index>1->
    	d2_nth(Puzzle,Index,Index,Last_value),
    	Index1 is Index - 1,
    	dia_check(Puzzle,Index1,Last_value)
).


% head_check/1
% It checks whether the sum or
% multiplicative equals to first elements of the given row.
head_check(Row):-
	head_check(Row,0,_,1,_).
head_check([Item1],Sum,Sum,Pdt,Pdt):-
	Item1 = Sum;
	Item1 = Pdt.
head_check([Item1,Item2 | Tail],Acc_s,Sum,Acc_p,Pdt):-
	Acc_s1 is Acc_s + Item2,
	Acc_p1 is Acc_p * Item2,
	head_check([Item1| Tail],Acc_s1,Sum,Acc_p1,Pdt).
