module Programs where
import MuKanren

appendo a b ab =
  fun "appendo" $
      conde [ [ a === nil, b === ab ]
            , [ call_fresh (\h ->
                  call_fresh (\t ->
                    a === pair h t &&&
                    call_fresh (\ab' ->
                      pair h ab' === ab &&& zzz (call (appendo t b ab') [t, b, ab']))
                 )
                )
              ]
            ]

reverso a b =
  fun "reverso" $
      conde [ [a === nil, b === nil]
            , [call_fresh (\h ->
                call_fresh (\t ->
                    a === pair h t &&&
                    call_fresh (\a' ->
                      (let h' = list [h] in zzz (call (appendo a' h' b) [a', h', b])) &&&
                        zzz (call (reverso t a') [t, a'])
                  )
                )
              )]
            ]

