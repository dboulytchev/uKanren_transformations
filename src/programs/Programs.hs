module Programs where

import List
import Num
import Syntax

palindromo :: G a -> G a
palindromo g = let x = V "x" in Let (def "palindromo" ["x"] (call "reverso" [x, x])) $ reverso g

doubleAppendo :: G a -> G a
doubleAppendo g =
  let x = V "x" in
  let y = V "y" in
  let z = V "z" in
  let r = V "r" in
  let t = V "t" in
  Let (def "doubleAppendo" ["x", "y", "z", "r"]
        (
          fresh ["t"] ( call "appendo" [x, y, t] &&& call "appendo" [t, z, r] )
        )
      ) $ appendo g

eveno :: G a -> G a
eveno g =
  let x = V "x" in
  let z = V "z" in
  Let (def "eveno" ["x"] (fresh ["z"] (call "addo" [z, z, x]))) $ addo g

doubleo :: G a -> G a
doubleo g =
  let x = V "x" in
  let xx = V "xx" in
  Let (def "doubleo" ["x", "xx"] (call "appendo" [x, x, xx])) $ appendo g

emptyAppendo :: G a -> G a
emptyAppendo g =
  let x = V "x" in
  let y = V "y" in
  Let (def "emptyAppendo" ["x", "y"] (call "appendo" [nil, x, y])) $ appendo g

toList [] = nil
toList (c:cs) = peanify c % toList cs

appendo123 :: G a -> G a
appendo123 g =
  let x = V "x" in
  let y = V "y" in
  Let (def "appendo123" ["x", "y"] (call "appendo" [toList [1..3], x, y])) $ appendo g

appendoXyz :: G a -> G a
appendoXyz g =
  let x = V "x" in
  let y = V "y" in
  let z = V "z" in
  let t = V "t" in
  let r = V "r" in
  Let (def "appendoXyz" ["x", "y", "z", "t", "r"] (call "appendo" [x % (y % (z % nil)), t, r])) $ appendo g


singletonReverso :: G a -> G a
singletonReverso g =
  let x = V "x" in
  let y = V "y" in
  Let (def "singletonReverso" ["x", "y"] (fresh ["l"] (call "lengtho" [x, peanify 1] &&& call "reverso" [x, y]))) $ reverso $ lengtho g