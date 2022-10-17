{- ex: 2xy + 7 -> [(2, [(x, 1), (y,1)]), (7, [])]-}
-- [ (0 , [('x',2)] ) , (2, [('y',1)]) , (5, [('z', 1)]) , (1 , [('y',1)]) , (7 , [('y',2)]) ] -> (0*x^2 + 2*y + 5*z + y + 7*y^2)
type Mono = (Int, [(Char, Int)])
type Poly = [Mono]

-- TODO: no normalize xy é igual a yx






----------------------------------------------------------------------------------------------
-- BASE FUNCTIONS TO REMOVE coeficientE NULL AND EXPOENTE NULL
removeExpNull :: (Num b, Eq b) => [(a, b)] -> [(a, b)]
removeExpNull [] = []
removeExpNull ((x,y):xs)
    | y == 0 = removeExpNull xs
    | otherwise = (x,y): removeExpNull xs

 -- REMOVES ALL MONO WHO HAVE 0 IN COEF AND CALLS EXP NULL TO SEE IF THEY ARE OK
removeCoefNull :: Poly -> Poly
removeCoefNull [] = []
removeCoefNull ((0, x:xs ):xss) = removeCoefNull xss
removeCoefNull ((a,[]):xs) = (a,[]):removeCoefNull xs
removeCoefNull ((a,(b, c):xs):xss) = (a, removeExpNull ((b,c):xs) ): removeCoefNull xss
----------------------------------------------------------------------------------------------

-- ADDS MONO AND KEEPS SAME LITERAL
addMono :: Mono -> Mono -> Mono
addMono m1 m2 = (fst m1 + fst m2, snd m1)

-- ADDS MONO USING ABOVE FUNC, THIS FUNCTION ADDS MONOS WITH SAME LITERAL EXPRESSION
addSame :: Mono -> Poly -> Poly
addSame m [] = [m]
addSame m (x:xs)
    | snd m == snd x = addMono m x:xs
    | otherwise = x:addSame m xs

----------------------------------------------------------------------------------------

-- THIS FUNCTION NORMALIZES POLY USING ABOVE FUNC OF ONLY ADDING IF SAME
normalizePoly :: Poly -> Poly
normalizePoly p
 | null p = []
 | otherwise = normalizeFunc (removeCoefNull p)
 where normalizeFunc xs
        | null xs = []
        | otherwise = addSame (head xs) (normalizeFunc (tail xs))

----------------------------------------------------------------------------------------

-- THIS FUNCTION ADDS POLYS BY CONCAT TWO INTO ONE AND THEN NORMALIZING IT, ADDING SAME EXPRESSIONS, AS EXPECTED
addPoly :: Poly -> Poly -> Poly
addPoly p1 p2
 | p1 == [] = p2
 | p2 == [] = p1
 | otherwise = normalizePoly ( p1 ++ p2)

---------------------------------------------------------------------------------------

-- multiplies same MONO literal AND increases literal (2, [('x',2), ('y',1)]) (2, [('x',2) ,('y',1)])
mulMono :: Mono -> Mono -> Mono
mulMono m1 m2 = (fst m1 * fst m2 , auxRec(snd m1))
  where auxRec m1aux
         | length m1aux == 1 = [( fst (head m1aux), snd (head m1aux) + snd (head m1aux))]
         | otherwise = [(fst (head m1aux), snd (head m1aux) + snd (head m1aux))] ++ auxRec (drop 1 m1aux)


mulOnlyCoef :: Mono -> Mono -> Mono
mulOnlyCoef m1 m2 = (fst m1 * fst m2 , var) where var = if(snd m1 /= []) then snd m1 else snd m2

isMember:: (Eq a)  => a -> [(a,b)] -> Bool
isMember y [] = False
isMember y (x:xs) =
 if y == fst x then
  True
 else
  isMember y xs

calcLiterals :: (Eq a, Num b, Eq b) => [(a,b)] -> [(a,b)] -> [(a,b)]
calcLiterals m1 m2 = lista ++ [ (h,i) | (h,i) <- m1, isMember h lista == False ] ++ [ (j,k) | (j,k) <- m2, isMember j lista == False ]
  where lista = [ (a, b+d) | (a,b) <- m1, (c,d) <- m2, a == c ]

mulExpression :: Mono -> Poly-> Poly
mulExpression m [] = []
mulExpression m (x:xs)
    -- if only coef is multiplying
    | (snd m == [] || snd x == [])= [mulOnlyCoef m x] ++ mulExpression m xs
    -- if same literals
    | (snd m == snd x)  = [mulMono m x] ++ mulExpression m xs
    | snd m /= snd x = [(fst m * fst x, calcLiterals (snd m) (snd x) )] ++ mulExpression m xs
    | otherwise = x:mulExpression m xs


mulPoly :: Poly -> Poly -> Poly
mulPoly p1 p2
 | p1 == [] = []
 | p2 == [] = []
 | otherwise =  mulExpression (head p1) p2 ++ mulPoly (tail p1) p2

-- mulPoly [ (2, [('y',1)]), (5, [('z', 1)]) ]  [ (1 , [('y',1)]) ]

---------------------------------------------------------------------------------------

-- DERIVADA FUNCTIONS
mylookup :: (Eq a, Num b, Ord b) => a -> [(a,b)] -> [(a,b)]
mylookup _ [] =  []
mylookup key ((x,y) : xys)
  | y == 0 = [] ++ mylookup key xys
  | (length ((x,y) : xys) == 1 && key /= x) = []
  | key == x  =  if (y > 1) then  ( ( x, (y-1) ) : xys) else (xys)
  | otherwise =  mylookup key xys

monoDer :: (Int, [(Char, Int)]) -> Char -> (Int, [(Char, Int)])
monoDer m c
 | fst m == 0 = (0, [])
 | snd m == [] = (0, [])
 | mylookup c (snd m) == [] = (0, [])
 | otherwise = (fst m * expoente , mylookup c (snd m)) where expoente = (snd (head (mylookup c (snd m))) ) + 1

polyDer :: Poly -> Char -> Poly
polyDer poly c = normalizePoly( map (\mono -> monoDer mono c) poly )

--------------------------------------------------------------------------------------------

-- LIST TO STRING PRINT FUNCTIONS
listToString :: Poly -> String
listToString p
 | length p == 1 = show(fst (head p) ) ++ "*" ++ literalsToString(snd (head p))
 | fst (head p) == 0 = "" ++ listToString (drop 1 p)
 | snd (head p) == [] = show(fst (head p)) ++ " " ++ "+" ++ " " ++ listToString (drop 1 p)
 | otherwise = show(fst (head p) ) ++ "*" ++ literalsToString(snd (head p)) ++ " " ++ "+" ++ " " ++ listToString (drop 1 p)

-- PRINT LITERALS FUNCTIONS
literalsToString :: (Eq b, Num b,  Show b) => [(Char, b)] -> String
literalsToString m
 | (length m == 1 && snd (head m) /= 1) = [fst (head (m))] ++ "^" ++ show (snd (head m) )
 | length m == 1 && snd (head m) == 1 = [fst (head (m))]
 | snd (head m) == 1 = [fst (head m)]  ++ literalsToString (drop 1 m)
 | otherwise = [fst (head m)] ++ "^" ++ show(snd(head m)) ++ literalsToString (drop 1 m)

----------------------------------------------------------------------------------
-- CALLING FUNCTIONS

-- print normalizar
normalizar :: Poly -> String
normalizar p = listToString (normalizePoly p)

-- print adicionar
adicionar :: Poly -> Poly -> String
adicionar p1 p2 = listToString (addPoly p1 p2)

multiplicar :: Poly -> Poly -> String
multiplicar p1 p2 = listToString (normalizePoly (mulPoly p1 p2) )

-- DERIVADA PRINT FUNCTION
derivada :: Poly -> Char -> String
derivada p c = listToString (polyDer p c)
