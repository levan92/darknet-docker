import os
import cv2
import json
import argparse
import datetime
from tqdm import tqdm
from pathlib import Path

IMG_EXTS = ('.jpg', '.jpeg','.png')

parser = argparse.ArgumentParser()
parser.add_argument('outputjson', help='Location to write the groundtruth json to.')
# parser.add_argument('dataset_root', help='Path to root dir of dataset')
parser.add_argument('testtext', help='Path to a text file. Each entry in the file is a path to a test image, from which the corresponding label text file can be inferred.')
parser.add_argument('namelist', help='Path to a text file with the names corresponding to each category index. (This is pre-map)')
parser.add_argument('--map_classes', help='Path to json that maps the class idx (optional, needed in case of coco where there is a difference between 80 classes and 91 classes.)')
args = parser.parse_args()

assert Path(args.testtext).is_file()
assert Path(args.namelist).is_file()

class_map = None
if args.map_classes:
    def keys2int(d):
        return {int(k):v for k,v in d}
    assert Path(args.map_classes).is_file()
    with open(args.map_classes,'r') as f:
        class_map = json.load(f, object_pairs_hook=keys2int)

with open(args.namelist, 'r') as namefp:
    lines = [line.strip() for line in namefp.readlines()]
    if class_map is None:
        catStrs = { (idx+1):name for idx, name in enumerate( lines ) }
    else:
        catStrs = { (class_map[idx+1]):name for idx, name in enumerate( lines ) }

# pairs = [pair.split(':') for pair in args.catStrs.split(',')]
# catStrs = { int(pair[0]):pair[1] for pair in pairs }

assert len( catStrs ) > 0
category_list = [{'id':k, 'name':v} for k,v in catStrs.items()]

img_ids = []
annotations = []

with open(args.testtext, 'r') as testfp:
    lines = [line.strip() for line in testfp.readlines()]


uid = 0
img_id = 0    
no_label_file = []
for line in tqdm(lines):
    # base = os.path.basename( line )
    # base = base.split('.')[0]
    # print(base)
    # parent = os.path.dirname( line )
    # parent = os.path.dirname( parent )
    # print(parent)
    line_path = Path(line)
    parent, img_part_path = line.split('images')
    label_part_path = img_part_path
    for img_ext in IMG_EXTS:
        if img_part_path.endswith(img_ext):
            label_part_path = label_part_path.replace(img_ext, '.txt')
            break
    else:
        assert True,'img path given does not end with either {}'.format(IMG_EXTS)
    # base = line_path.stem
    # parent = line_path.parents[1]

    label_path = Path('{}/labels/{}'.format( parent, label_part_path))
    image_path = Path('{}/images/{}'.format( parent, img_part_path))

    # img_id = int(img_part_path.split('.')[0].split('_')[-1]) 

    assert image_path.is_file(),'{} does not exist'.format(image_path)
    img = cv2.imread( str(image_path) )
    im_h, im_w = img.shape[:2]

    img_ids.append({
                    'id': img_id, 
                    'file_name': str(image_path),
                    'width': im_w,
                    'height': im_h,
                    'license': 0,
                    'flickr_url': '',
                    'coco_url': ''
                    })


    if not label_path.is_file():
        no_label_file.append(str(label_path))
    else:
        with open(str(label_path),'r') as f:
            lines = f.readlines()

        for line in lines:
            cat_id, cen_x, cen_y, w, h = line.split()
            cat_id = int(cat_id) + 1
            if class_map:
                cat_id = class_map[cat_id]
            cen_x = float(cen_x)
            cen_y = float(cen_y)
            w = float(w)
            h = float(h)
            x = cen_x - (w / 2.0)
            y = cen_y - (h / 2.0)
            x = x * im_w
            y = y * im_h
            w = w * im_w
            h = h * im_h

            annotations.append({
                                'id': uid,
                                'image_id': img_id,
                                'category_id': int(cat_id),
                                'segmentation': [],
                                'area': w*h,
                                'bbox': [x, y, w, h],
                                'iscrowd': 0
                                })
            
            uid += 1

            # if cat_id not in category_list:
            #     category_list.append({'id': cat_id, 'name':catStrs[cat_id]})
    img_id+=1

out_dict = {}
out_dict['categories'] = category_list
out_dict['images'] = img_ids
out_dict['annotations'] = annotations

now = datetime.datetime.now()
out_dict['info'] = {'year': now.year, 'date_created': '{0:04d}-{0:02d}-{0:02d} {0:02d}:{0:02d}:{0:02d}.{0:06d}'.format( now.year, now.month, now.day, now.hour, now.minute, now.second, now.microsecond ), 'contributor': 'data.sg', 'description': 'This is a test dataset from data.sg', 'version': '0.0', 'url': 'http://data.sg'}
out_dict['licenses'] = [{'id':0, 'name':'The data.sg License', 'url':''}]

with open('{}'.format( args.outputjson ), 'w') as fp:
    json.dump(out_dict, fp)

print(no_label_file)
print('Num of images with no corresponding label files:{}'.format(len(no_label_file)))
import pdb;pdb.set_trace()