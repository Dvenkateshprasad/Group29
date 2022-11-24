import pandas as pd
import os
from subprocess import run

import pickle
from subprocess import run
import numpy as np
import pandas as pd
import sound_recorder
import simple_model

if __name__ == '__main__':
    # put your files in test/ directory
    # record_to_file('/test/test.wav')

    if not os.path.isfile('features.csv'):
        open("features.csv", "w+").close()
    if not os.path.exists('test'):
        os.makedirs('test')
    while True:
        print('\nMenu')
        print('1. Record Voice')
        print('2. Predict')
        print('3. Train Sample Model')
        print('4. Extract Features')

        option = input('Enter Option Number: ')

        if option == "4":
            # sound_recorder.run()
            print("Extracting Features from the test folder \n")
            run(['Rscript', 'getFeatures.r', os.getcwd()])
        if option == '1':
            sound_recorder.run()
            break
        if option == "3":
            simple_model.run()
        if option == "2":
            loc = 'features.csv'
            # loc = "voiceDetailsr.csv"
            data = pd.read_csv('features.csv')
            del data['peakf'], data['test.files']
            # del data['peakf'], data['sound.files'], data['selec'], data['duration'], data['label']

            # print(data)
            if not os.path.isfile('trained_model'):
                print('Please train and save the model as "trained_model"')
                continue
            model = pickle.load(
                open('trained_model', 'rb'))
            # data = (data - dataset.mean()) / \
            #     (dataset.max() - dataset.min())  # scale

            # load trained neural net from file
            y_pred = model.predict(data)
            print(list(y_pred))
            value = np.sum(y_pred)/len(y_pred)
            print('Female' if value
                  < 0.5 else 'Male')
            break
        else:
            print('\nInvalid option. Please try again...')

    # print("Converting from python file")
    # convert()
    # print(data)
