module Tree where 

import Data.Text.Lazy (Text, pack, unpack)
import Data.Graph.Inductive (Gr, mkGraph)
import Data.GraphViz (
  GraphvizParams,
  GlobalAttributes(
    GraphAttrs,
    NodeAttrs
    ),
  X11Color(Transparent, White),
  nonClusteredParams,
  globalAttributes,
  fmtNode,
  fmtEdge,
  graphToDot
  )
import Data.GraphViz.Printing (toDot, renderDot)
import Data.GraphViz.Attributes.Complete (
  Attribute(
    BgColor,
    Shape,
    Label,
    ViewPort,
    RankDir,
    Style,
    FillColor
    ),
  Shape(BoxShape),
  Label(StrLabel),
  RankDir(FromTop),
  StyleName(Filled),
  StyleItem(SItem),
  toWColor,
  )

import qualified Eval as E
import Syntax

data Tree = 
  Fail                           | 
  Success E.Sigma                | 
  Or      Tree Tree (G S)        | 
  Rename  (G S) Renaming         |
  Gen     Generalizer Tree (G S) | 
  Split   Tree Tree (G S)        -- deriving Show

-- Renaming
type Renaming = [(S, S)]

-- Generalization
type Generalizer = [(S, Ts)]

treeToGraph :: Tree -> Gr Text Text
treeToGraph tree = 
  let (vs, es) = label tree 
  in  mkGraph (map (\(i, v) -> (i, pack v)) vs) (map (\(i,j,l) -> (i,j, pack l)) es)

label :: Tree -> ([(Int,String)], [(Int,Int,String)])
label tree = 
  label' tree 1 [] []
  where 
    addLeaf  i n ns es = ((i, n) : ns, es)
    addChild i n ns es ch = 
      let i' = 2*i
          (ns', es') = label' ch i' ns es 
      in  ((i, n) : ns', (i, i', "") : es')
    addChildren i n ns es ch1 ch2 = 
      let i1 = 2*i
          i2 = i1 + 1
          (ns',  es')  = label' ch1 i1 ns es
          (ns'', es'') = label' ch2 i2 ns es
      in  ((i, n) : (ns' ++ ns''), (i, i1, "") : (i, i2, "") : (es' ++ es''))
    label' t@Fail                         i ns es = addLeaf     i (show t) ns es
    label' t@(Success _)                  i ns es = addLeaf     i (show t) ns es
    label' t@(Rename _ _)                 i ns es = addLeaf     i (show t) ns es
    label' t@(Gen _ ch _)                 i ns es = addChild    i (show t) ns es ch
    label' t@(Or ch1 ch2 _)               i ns es = addChildren i (show t) ns es ch1 ch2
    label' t@(Split ch1 ch2 _)            i ns es = addChildren i (show t) ns es ch1 ch2


instance Show (Tree) where 
  show Fail = "_|_"
  show (Success s)    = ("S\n" ++ show s)
  show (Rename g ts)  = "R\n" ++ show g ++ "\n" ++ show (reverse ts)
  show (Gen g _ curr) = "G\n" ++ show g ++ "\n" ++ show curr
  show (Or _ _ curr)  = "O\n" ++ show curr
  show (Split t1 t2 curr) = "Splt\n" ++ show curr

params :: GraphvizParams n Text Text () Text
params = nonClusteredParams {
  globalAttributes = ga,
  fmtNode = fn,
  fmtEdge = fe
  }
  where
    ga = [
      GraphAttrs [
         RankDir FromTop,
         BgColor [toWColor Transparent]
         ],
      NodeAttrs [
        Shape BoxShape,
        FillColor [toWColor White],
        Style [SItem Filled []]
        ]
      ]

    fn (n,l) = [(Label . StrLabel) l]
    fe (f,t,l) = [(Label . StrLabel) l]

printTree filename tree =
  writeFile filename $ unpack $ renderDot $ toDot $ graphToDot params (treeToGraph tree)