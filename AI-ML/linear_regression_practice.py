import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

#Make a dataset
#Create generic model (y=wx+b) to fit the dataset
#Create cost function
#Create derivative function
#Create gradient descent function and algorithm

#Make a dataset
x_train = np.arange(1000,100000,10000)

w_train = 1.7
b_train = 35000
y_train=np.zeros(len(x_train))
for i in range(len(x_train)):
    y_train[i] = w_train*x_train[i]+b_train

#print(x_train)
#print(y_train)
###################### PRINT THE DATASET ################################
plt.scatter(x_train,y_train, c='r', marker='x')
plt.ylim(0,max(y_train)+40000)


#Create generic model to fit the dataset
w = 1.7
b = 35000
y_model = np.zeros(len(x_train))
for i in range(len(x_train)):
    y_model[i] = w * x_train[i] + b


###################### PRINT THE MODEL ################################
#plt.plot(x_train, y_model, c='g', marker="o")

###################### PRINT THE DATASET #################################
#plt.show()

#Define cost function
def calculate_cost(x, y, y_m):
    cost = 0
    m = len(x)
    for i in range(len(x)):
        cost += (y[i] - y_m[i])**2
    cost /= (2 * m)
    return cost

test_cost = calculate_cost(x_train, y_train, y_model)
print(f'The test_cost is {test_cost:.4f}')
print(type(test_cost))

####################Calculate the cost curve (given b is fixed)     ######################################
#Need arrays for w and cost
w_array = np.arange(-3.4, 6.9,0.1)

cost_array = np.zeros(len(w_array))
static_b = 35000
for i in range(len(w_array)):
    changing_model = np.zeros(len(x_train))
    for j in range(len(x_train)):
        changing_model[j] = w_array[i] * x_train[j] + static_b
    cost_array[i] = calculate_cost(x_train, y_train, changing_model)

for i in range(len(w_array)):
    print(f'w is {w_array[i]:.2f}, and cost is {cost_array[i]:.2f}')


######################Calculate the cost curve (give that w is fixed) #####################################
b_array = np.arange(0,70000, 5000)
print(b_array)
print(len(b_array))
b_cost_array = np.zeros(len(b_array))
print(b_cost_array)
static_w = 1.7
for i in range(len(b_array)):
    b_changing_model = np.zeros(len(x_train))
    for j in range(len(x_train)):
        b_changing_model[j] = static_w*x_train[j] + b_array[i]
    b_cost_array[i] = calculate_cost(x_train, y_train, b_changing_model)




# Create subplots
fig, axs = plt.subplots(2, 2)

# Plot on the first subplot
axs[0,0].plot(x_train, y_model, c='g', marker="o")
axs[0,0].set_title('Training Data')

# Plot on the second subplot
axs[0,1].plot(w_array, cost_array, label='w vs. cost', color='red')
axs[0,1].set_title('Cost and Model Slope')

# Plot on the third subplot
axs[1,0].plot(b_array, b_cost_array, c='b', marker="o")
axs[1,0].set_title('Cost and Model Y-Intercept')

# Plot on the third subplot
axs[1,1].plot(x_train, y_model, c='g', marker="o")
axs[1,1].set_title('Training Data')


for ax in axs.flat:
    ax.set(xlabel='x-label', ylabel='y-label')

# Hide x labels and tick labels for top plots and y ticks for right plots.
for ax in axs.flat:
    ax.label_outer()

fig.show()
input("Press Enter to end execution")

