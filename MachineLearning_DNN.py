#Linear Regression
import tensorflow as tf
import numpy as np

x = tf.placeholder("double", [500, 500])
y_ = tf.placeholder("int32",[2, 1])

W = tf.Variable(tf.zeros([500,1]))
b = tf.Variable(tf.zeros([2, 1]))

y=tf.matmul(x,W) + b

loss=tf.reduce_sum(tf.square(y_ - y))

train_step = tf.train.GradientDescentOptimizer(0.01).minimize(loss)

init = tf.initialize_all_variables()
sess = tf.Session()
sess.run(init)
sess.run(train_step, feed_dict={x:np.asarray(DF_X),y_:np.asarray(SR_y)})

sess.run(loss,feed_dict={x:np.asarray(DF_X),y_:np.asarray(SR_y)})


#Deep Neural Network
import tensorflow as tf
import numpy as np

# Data sets
IRIS_TRAINING = "TFR_training.csv"
IRIS_TEST = "TFR_test.csv"

# Load datasets.
training_set = tf.contrib.learn.datasets.base.load_csv(filename=TFR_TRAINING, target_dtype=np.int)
test_set = tf.contrib.learn.datasets.base.load_csv(filename=TFR_TEST, target_dtype=np.int)

x_train, x_test, y_train, y_test = training_set.data, test_set.data, \
  training_set.target, test_set.target

# Build 3 layer DNN with 10, 20, 10 units respectively.
classifier = tf.contrib.learn.DNNClassifier(hidden_units=[10, 20, 10], n_classes=3)

# Fit model
classifier.fit(x=x_train, y=y_train, steps=200)

accuracy_score = classifier.evaluate(x=x_test, y=y_test)["accuracy"]
print('Accuracy: {0:f}'.format(accuracy_score))
