# -------------------- import libraries
import face_recognition
import os
import sys

# get movie length
def get_movie_length(movie_id, path):

    # get movie path
    os.chdir(path)
    movie_names = os.listdir()
    movie_names.sort()
    movie_path = path + '/' + movie_names[movie_id] + '/'

    # get frame path
    os.chdir(movie_path)
    frames_names = os.listdir()
    #return len(frames_names) - 1
    return 200

# change directory to actual movie
def get_movie_path(movie_id, path):

    # get movie path
    os.chdir(path)
    movie_names = os.listdir()
    movie_names.sort()
    movie_path = path + '/' + movie_names[movie_id] + '/'
    return movie_path

# change directory to actual movie
def get_frame_name(movie_id, frame_id):

    # get movie path
    movie_path = get_movie_path(movie_id, path)

    # get frame path
    os.chdir(movie_path)
    frames_names = os.listdir()
    frames_names.sort()

    return movie_path + frames_names[frame_id]

# compare faces
def face_counter(movie_id, path):

    # remove possible text file
    if os.path.isfile(get_movie_path(movie_id, path) + 'zz_face_constraint.txt') :
        os.remove(get_movie_path(movie_id, path) + 'zz_face_constraint.txt')

    # get all faces in all frames
    length_movie_clip = get_movie_length(movie_id, path)
    #print(length_movie_clip)
    
    all_faces = [None]*1000000
    face_recurrence = [[False for x in range(len(all_faces))] for y in range(length_movie_clip)] 

    for frame_id_init in range(1, length_movie_clip) :

        frame = face_recognition.load_image_file(get_frame_name(movie_id, frame_id_init))
        frame_face_encodings = face_recognition.face_encodings(frame)

        if len(frame_face_encodings) > 0 :
            all_faces[0] = frame_face_encodings[0]
            all_faces_fill = 1
            break

    for frame_id in range(1, length_movie_clip) :
        
        frame = face_recognition.load_image_file(get_frame_name(movie_id, frame_id))
        frame_face_encodings = face_recognition.face_encodings(frame)

        for face in frame_face_encodings : 
            compare_faces_array = face_recognition.compare_faces(face, all_faces[0:all_faces_fill]);
            if sum(compare_faces_array) == 0 :
                all_faces[all_faces_fill] = face;
                face_recurrence[frame_id][all_faces_fill] = True
                all_faces_fill = all_faces_fill + 1
            else :
                for i in range(len(compare_faces_array)):
                    if compare_faces_array[i] :
                        face_recurrence[frame_id][i] = True

    # print data to file
    f = open(get_movie_path(movie_id, path) + 'zz_face_constraint.txt', 'w')
    for i in range(length_movie_clip): 
        for j in range(all_faces_fill) :
            if face_recurrence[i][j] :
                print('1', end = ' ', file = f)
            else :
                print('0', end = ' ', file = f)
        print('', file = f)
    f.close()

# -------------------- run function

# define variables
path = sys.argv[1]
movie_id = int(sys.argv[2])

# run function
face_counter(movie_id, path)
#print(get_movie_path(movie_id, path) + 'zz_face_constraint.txt', end = ' ')
