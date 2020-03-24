#! /bin/bash
set -e
# The network that we're testing
# netctx=yolov3
# A text file that lists all the paths to each test image
testlist=/media/dh/Data1/coco/5k.txt
# A text file that lists the detectable categories in index order
nameslist=/home/dh/Workspace/coco-classes-mapping/coco80.names
# map_classes=/home/dh/Workspace/coco-classes-mapping/coco_mapping_80to91.json

# Where the results are written to
logfile=yolo_coco_eval.log
curr=$(pwd)
# Where the detector is to be found
dn=/home/dh/Workspace/retroyolo
# Where the coco-evaluation script is to be found
cocoeval=/home/dh/Workspace/retroyolo/cocoeval
# Ignore this - it's just a placeholder name to write detection results to
# dtout="yolov3-on-coco_val5k"

# Put resource files below. Set them carefully.
datas=(
       "cfg/coco.data"
       )
netcfgs=(
        "cfg/yolov3.cfg"
         )
weights=(
         "weights/yolov3.weights"
         )
gtouts=(
        "coco_val5k_GT.json"
        )

len=${#weights[@]}

for i in $(seq $len); do
    wts=${weights[i-1]}
    netcfg=${netcfgs[i-1]}
    data=${datas[i-1]}
    gtout=${gtouts[i-1]}

    cd ${curr}
    if [ ! -f ../results/${gtout} ]; then
        echo "Constructing ground truth from test text..."
        if [ -z "$map_classes" ]
        then
            python3 gtjson_from_folders.py ../results/${gtout} $testlist $nameslist
        else
            python3 gtjson_from_folders.py ../results/${gtout} $testlist $nameslist --map_classes $map_classes
        fi
    else
        echo ${gtout} already exists.
    fi

    cd ${dn}
    if [ ! -f results/${dtout}.json ]; then
        echo "Running detector through test set..."
        ./darknet detector test_rs ${data} ${netcfg} ${wts} -out ${dtout}
        # python3 results/filter_dets.py ${data} results/${dtout}.json
    else
        echo "${dtout}.json already exists."
    fi

    echo "Comparing detections with ground truth..."
    cd ${cocoeval}
    echo Evaluating ${wts},${netcfg},${data} >> ${logfile}
    python3 pycocoeval.py ${dn}/results/${gtout} ${dn}/results/${dtout}.json >> ${logfile}
done

# Clean up
# echo "Removing temporary files..."
# for i in $(seq $len); do
#     gtout=${gtouts[i-1]}
#     rm ${curr}/${gtout}.json
# done
# rm ${dn}/results/${dtout}.json

cd ${curr}

echo "Done!"
