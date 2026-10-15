(#%require dunit 2htdp/image)
(load "_submission.rkt")

(test
 (single-tab
  (context "result"
           (case*
            (call-= (image-width (make-square 30)) 30)
            (call-= (image-height (make-square 30)) 30)))))
