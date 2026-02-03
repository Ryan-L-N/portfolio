import numpy as np
import matplotlib.pyplot as plt

def compute_model_output(x, w, b):
    m = len(x)
    f_wb = np.zeros(m)
    for i in range(m):
        f_wb[i] = w * x[i] + b
    return f_wb


x_train = np.array([1.0, 2.0])
y_train = np.array([300, 500])

print(type(x_train), np.shape(x_train))
print(type(y_train))

print(x_train)
m = len(x_train)

i = 0
x_i = x_train[i]
y_i = y_train[i]


w = 200
b = 100

tmp_f_wb = compute_model_output(x_train,w,b)

#Plot our model prediction
plt.plot(x_train, tmp_f_wb, c='b', label="Our Prediction")
plt.scatter(x_train, y_train, marker='x', c='g', label="Actual Values")
plt.title("Housing Prices")
plt.ylabel('Price (in thousands of dollars)')
plt.xlabel('Size (1000 sq ft)')
plt.legend()    
plt.show()


#Once you fit the model, then use the model to make predictions
x_i = 1.2
cost_1200sqft = w*x_i + b
print(cost_1200sqft)
