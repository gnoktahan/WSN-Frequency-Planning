Python

import tensorflow as tf
import numpy as np

# Data sets
IRIS_TRAINING = "/Users/GKN/Desktop/THESIS/Iris_Dataset/iris_training.csv"
IRIS_TEST = "/Users/GKN/Desktop/THESIS/Iris_Dataset/iris_test.csv"

# Load datasets.
training_set = tf.contrib.learn.datasets.base.load_csv(filename=IRIS_TRAINING, target_dtype=np.int)
test_set = tf.contrib.learn.datasets.base.load_csv(filename=IRIS_TEST, target_dtype=np.int)

x_train, x_test, y_train, y_test = training_set.data, test_set.data, training_set.target, test_set.target

# Build 3 layer DNN with 10, 20, 10 units respectively.
# Creates a DNNClassifier model with three hidden layers, containing 10, 20, and 10 neurons, respectively (hidden_units=[10, 20, 10]), and three target classes (n_classes=3).
classifier = tf.contrib.learn.DNNClassifier(hidden_units=[10, 20, 10], n_classes=3)

# Fit model
classifier.fit(x=x_train, y=y_train, steps=200)

# Evaluate model accuracy
accuracy_score = classifier.evaluate(x=x_test, y=y_test)["accuracy"]
print('Accuracy: {0:f}'.format(accuracy_score))

# Classify two new flower samples.
new_samples = np.array(
    [[6.4, 3.2, 4.5, 1.5], [5.8, 3.1, 5.0, 1.7]], dtype=float)
y = classifier.predict(new_samples)
print ('Predictions: {}'.format(str(y)))
