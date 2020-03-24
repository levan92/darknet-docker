import matplotlib.pyplot as plt
from pycocotools.coco import COCO
from pycocotools.cocoeval import COCOeval
import numpy as np
import skimage.io as io
import pylab
import sys
pylab.rcParams['figure.figsize'] = (10.0, 8.0)

import os, sys

class HiddenPrints:
    def __enter__(self):
        self._original_stdout = sys.stdout
        sys.stdout = open(os.devnull, 'w')

    def __exit__(self, exc_type, exc_val, exc_tb):
        sys.stdout.close()
        sys.stdout = self._original_stdout

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python3 pycocoeval.py [/path/to/ann/file] [/path/to/results/file]')
        exit()
    annFile = sys.argv[1]
    resFile = sys.argv[2]
    
    with HiddenPrints():
        cocoGt=COCO(annFile)
        imgIds=sorted(cocoGt.getImgIds())

        cocoDt=cocoGt.loadRes(resFile)

        # running evaluation
        cocoEval = COCOeval(cocoGt,cocoDt,'bbox')
        cocoEval.params.imgIds  = imgIds
        cocoEval.evaluate()
        cocoEval.accumulate()
    cocoEval.summarize()