#!/usr/bin/env python3
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import os
import csv
from pathlib import Path

# Load and preprocess data
wd = os.getcwd()
data = pd.read_csv(Path('/Users/adamkurth/Documents/vscode/code/understanding-series/nn_scratch_project/digit-recognizer/train.csv'))
data = np.array(data)
m, n = data.shape
np.random.shuffle(data)

# Create dev and train datasets
data_dev = data[0:1000].T
Y_dev = data_dev[0]
X_dev = data_dev[1:n] / 255.

data_train = data[1000:m].T
Y_train = data_train[0]
X_train = data_train[1:n] / 255.
_, m_train = X_train.shape

# Initialize parameters
def init_parameters():
    W1 = np.random.normal(size=(10, 784)) * np.sqrt(1. / 784)
    b1 = np.random.normal(size=(10, 1)) * np.sqrt(1. / 10)
    W2 = np.random.normal(size=(10, 10)) * np.sqrt(1. / 20)
    b2 = np.random.normal(size=(10, 1)) * np.sqrt(1. / 10)
    return W1, b1, W2, b2

# Activation functions
def ReLU(Z):
    return np.maximum(0, Z)

def softmax(Z):
    Z -= np.max(Z, axis=0)
    A = np.exp(Z) / np.sum(np.exp(Z), axis=0)
    return A

# Forward propagation
def forward_prop(W1, b1, W2, b2, X):
    Z1 = W1.dot(X) + b1
    A1 = ReLU(Z1)
    Z2 = W2.dot(A1) + b2
    A2 = softmax(Z2)
    return Z1, A1, Z2, A2

# One hot encoding
def one_hot(Y):
    one_hot_Y = np.zeros((Y.size, Y.max() + 1))
    one_hot_Y[np.arange(Y.size), Y] = 1
    return one_hot_Y.T

# Derivative of ReLU
def deriv_ReLU(Z):
    return Z > 0

# Backward propagation
def backward_prop(Z1, A1, Z2, A2, W1, W2, X, Y):
    one_hot_Y = one_hot(Y)
    dZ2 = A2 - one_hot_Y
    dW2 = 1 / m_train * dZ2.dot(A1.T)
    db2 = 1 / m_train * np.sum(dZ2, axis=1, keepdims=True)
    dZ1 = W2.T.dot(dZ2) * deriv_ReLU(Z1)
    dW1 = 1 / m_train * dZ1.dot(X.T)
    db1 = 1 / m_train * np.sum(dZ1, axis=1, keepdims=True)
    return dW1, db1, dW2, db2

# Update parameters
def update_parameters(W1, b1, W2, b2, dW1, db1, dW2, db2, alpha):
    W1 -= alpha * dW1
    b1 -= alpha * db1
    W2 -= alpha * dW2
    b2 -= alpha * db2
    return W1, b1, W2, b2

# Get predictions
def get_predictions(A2):
    return np.argmax(A2, axis=0)

# Get accuracy
def get_accuracy(predictions, Y):
    return np.sum(predictions == Y) / Y.size

# Gradient descent
def gradient_descent(X, Y, alpha, iterations, data_array):
    W1, b1, W2, b2 = init_parameters()
    for i in range(iterations):
        Z1, A1, Z2, A2 = forward_prop(W1, b1, W2, b2, X)
        dW1, db1, dW2, db2 = backward_prop(Z1, A1, Z2, A2, W1, W2, X, Y)
        W1, b1, W2, b2 = update_parameters(W1, b1, W2, b2, dW1, db1, dW2, db2, alpha)
        
        if i % 10 == 0:
            predictions = get_predictions(A2)
            print(f"Iteration: {i}, Accuracy: {get_accuracy(predictions, Y):.4f}")
        
        data_array.append([np.mean(b1), np.mean(b2), np.mean(W1), np.mean(W2), get_accuracy(predictions, Y), i])
    return W1, b1, W2, b2, data_array

# Main execution
data_array = []
W1, b1, W2, b2, data_array = gradient_descent(X_train, Y_train, 0.10, 500, data_array)

with open('output.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    for row in data_array:
        writer.writerow(row)

# Make predictions
def make_predictions(X, W1, b1, W2, b2):
    _, _, _, A2 = forward_prop(W1, b1, W2, b2, X)
    return get_predictions(A2)

# Test prediction
def test_prediction(index, W1, b1, W2, b2):
    current_image = X_train[:, index, None]
    prediction = make_predictions(current_image, W1, b1, W2, b2)
    label = Y_train[index]
    print(f"Prediction: {prediction[0]}, Label: {label}")
    
    current_image = current_image.reshape((28, 28)) * 255
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()

test_prediction(0, W1, b1, W2, b2)
test_prediction(1, W1, b1, W2, b2)
test_prediction(2, W1, b1, W2, b2)
test_prediction(3, W1, b1, W2, b2)

dev_predictions = make_predictions(X_dev, W1, b1, W2, b2)
print(f"Dev set accuracy: {get_accuracy(dev_predictions, Y_dev):.4f}")
