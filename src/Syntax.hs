{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}

module Syntax where

import Data.List

type X    = String -- Syntactic variables
type S    = Int    -- Semantic variables
type Name = String -- Names of variables/definitions

-- Terms
data Term v = V v | C String [Term v] deriving (Eq, Ord) 
type Tx     = Term X
type Ts     = Term S

instance Functor Term where
  fmap f (V v)    = V $ f v
  fmap f (C s ts) = C s $ map (fmap f) ts

instance Show a => Show (Term a) where
  show (V v) = "v<SUB>" ++ show v ++ "</SUB>"
  show (C name ts) = 
    case name of 
      "Nil" -> "[]"
      "Cons" -> let [h,t] = ts
                in show h ++ " : " ++ show t
      _ -> case ts of 
             [] -> name 
             _  -> "C " ++ name ++ " " ++ concatMap show ts

-- Definitions
type Def = (Name, [Name], G X)

def = (,,)

-- Goals
data G a = 
    Term a :=: Term a
  | G a :/\: G a
  | G a :\/: G a
  | Fresh  Name (G a)
  | Invoke Name [Term a] 
--  | Zzz (G a)
  | Let Def (G a) deriving (Eq, Ord) 

instance Show a => Show (G a) where
  show (t1 :=:  t2)               = show t1 ++ " = "  ++ show t2
  show (g1 :/\: g2)               = "(" ++ show g1 ++ " /\\ " ++ show g2 ++ ")"
  show (g1 :\/: g2)               = "(" ++ show g1 ++ " <BR/> \\/ " ++ show g2 ++ ")"
  show (Fresh name g)             = 
    let (names, goal) = freshVars [name] g in 
    "fresh " ++ show (reverse names) ++ " (" ++ show goal ++ ")"
  show (Invoke name ts)           = name ++ "(" ++ show ts ++ ")"
  show (Let (name, args, body) g) = "let " ++ name ++ " " ++ (intercalate " " args) ++ " = " ++ show body ++ " in " ++ show g 

freshVars names (Fresh name goal) = freshVars (name : names) goal
freshVars names goal = (names, goal)

infix  8 :=:
infixr 7 :/\:
infixr 6 :\/:

infixr 7 &&&
infixr 6 |||
infix  8 ===

(===) = (:=:)
(|||) = (:\/:)
(&&&) = (:/\:)

fresh xs g = foldr Fresh g xs
call       = Invoke 

-- Free variables
fv :: Eq v => Term v -> [v]
fv t = nub $ fv' t where
  fv' (V v)    = [v]
  fv' (C _ ts) = concat $ map fv' ts

fvg :: G X -> [X]
fvg = nub . fv' 
 where
  fv' (t1 :=:  t2) = fv t1 ++ fv t2
  fv' (g1 :/\: g2) = fv' g1 ++ fv' g2
  fv' (g1 :\/: g2) = fv' g1 ++ fv' g2
  fv' (Invoke _ ts) = concat $ map fv ts
  fv' (Fresh x g)   = fv' g \\ [x]
  fv' (Let (_, _, _) g) = fv' g


