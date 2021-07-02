import os
import re
import hashlib
MAX_NUM_WAVS_PER_CLASS = 2**27 - 1  # ~134M

def which_set(filename, validation_percentage, testing_percentage):
    base_name = os.path.basename(filename)
    hash_name = re.sub(r'_nohash_.*$', '', base_name)
    hash_name_hashed = hashlib.sha1(str(hash_name).encode('utf-8')).hexdigest()
    percentage_hash = ((int(hash_name_hashed, 16) %
                        (MAX_NUM_WAVS_PER_CLASS + 1)) *
                       (100.0 / MAX_NUM_WAVS_PER_CLASS))
    if percentage_hash < validation_percentage:
      result = 'validation'
    elif percentage_hash < (testing_percentage + validation_percentage):
      result = 'testing'
    else:
      result = 'training'
    return result

v = open("validation_set.txt", "a")
t = open("testing_set.txt", "a")
tr = open("training_set.txt", "a")

for subdir, dirs, files in os.walk('KWS_dataset'):
    for file in files:
        filepath = subdir + os.sep + file
        print(filepath)
        folder = which_set(filepath, 16, 20)
        if folder == 'validation':
            v.write(filepath + '\n')
        elif folder == 'testing':
            t.write(filepath + '\n')
        elif folder == 'training':
            tr.write(filepath + '\n')

v.close()
t.close()
tr.close()
