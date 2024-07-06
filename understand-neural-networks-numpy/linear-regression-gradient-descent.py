from numpy import genfromtxt, array, mean, float64
import matplotlib.pyplot as plt

# y = mx + b
# m is slope, b is y-intercept
def compute_error_for_line_given_points(b, m, points):
    total_error = 0
    for i in range(0, len(points)):
        x = points[i, 0]
        y = points[i, 1]
        total_error += (y - (m * x + b)) ** 2
    return total_error / float(len(points))

def step_gradient(b_current, m_current, points, learning_rate):
    b_gradient = 0
    m_gradient = 0
    N = len(points)
    for i in range(0, len(points)):
        x = points[i, 0]
        y = points[i, 1]
        m_gradient += -x * (y - (m_current * x + b_current))
        b_gradient += -(y - (m_current * x + b_current))
    m_gradient *= 2.0 / float(N)
    b_gradient *= 2.0 / float(N)
    new_b = b_current - (b_gradient * learning_rate)
    new_m = m_current - (m_gradient * learning_rate)
    return [new_b, new_m]

def gradient_descent_runner(points, starting_b, starting_m, learning_rate, num_iterations):
    b = starting_b
    m = starting_m
    error_list = []
    for i in range(num_iterations):
        b, m = step_gradient(b, m, array(points), learning_rate)
        error = compute_error_for_line_given_points(b, m, points)
        error_list.append(error)
    return [b, m], error_list

def run():
    points = genfromtxt("output.csv", delimiter=",")
    learning_rate = 0.0001
    b = 0  # initial y-intercept guess
    m = 0  # initial slope guess
    num_iterations = 1000
    threshold = 0.0001
    error_history = []
    
    for _ in range(1000):
        print(f"Starting gradient descent at b = {b}, m = {m}, error = {compute_error_for_line_given_points(b, m, points):.4f}")
        print("Running...")
        [final_params, error_list] = gradient_descent_runner(points, b, m, learning_rate, num_iterations)
        b, m = final_params
        print(f"After {num_iterations} iterations b = {b:.4f}, m = {m:.4f}, error = {compute_error_for_line_given_points(b, m, points):.4f}")
        error_history.extend(error_list)
        if compute_error_for_line_given_points(b, m, points) < threshold:
            break
    
    plt.plot(error_history)
    plt.xlabel('Iteration')
    plt.ylabel('Error')
    plt.title('Error over iterations')
    plt.show()

if __name__ == '__main__':
    run()
