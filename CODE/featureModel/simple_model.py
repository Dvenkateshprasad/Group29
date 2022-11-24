"""Train and validate neural net"""
import pickle
import warnings

from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier

from data_process import *

warnings.filterwarnings("ignore")


def train_model(x_train, y_train):
    """
    Train and save neural net.
    :param x_train: Training inputs.
    :param y_train: Training outputs.
    :return: Trained model
    """
    print('\nTraining by KNN Classifier...')
    # Change the model for differenct architecture.
    model = KNeighborsClassifier()
    # (hidden_layer_sizes=(40, 40), activation='identity', solver='sgd',
    #                        learning_rate='adaptive', max_iter=2000, verbose=True)
    model.fit(x_train, y_train)  # train neural net

    # print(model.coefs_)

    print('\nSaving trained neural net to file...')
    pickle.dump(model, open('trained_model', 'wb'))

    # visualize(pd.Series(model.loss_curve_), graph_type='area')  # plot loss curve

    return model


def run():
    """
    main.
    :return: None
    """
    voice_data = read()  # read data
    print("----- Sample of Data ------")
    print(voice_data.head())
    x_train, x_test, y_train, y_test = preprocess(
        voice_data)  # preprocess data

    trained_model = train_model(x_train, y_train)  # train neural net

    print('\nCalculating accuracy...\n')
    get_accuracy(x_train, x_test, y_train, y_test,
                 trained_model)  # print results


if __name__ == '__main__':
    run()
