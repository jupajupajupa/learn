Now that you understand the basics of quantum-inspired optimization, let's come back to our mineral shipment problem. Your spaceship has to optimize how it distributes the mineral chunks between the two container shipments. In other words, each chunk has a weight, $w$, associated with it, and you want to partition these weights into two sets: $W_A$ and $W_B$.

The two sets correspond to the mineral chunks to be loaded onto container A or container B, and we define $\Delta$ as the weight difference between the two containers.

This short animation shows one possible way that an optimizer might distribute the mineral. The running time of the optimizer is measured in steps. At each step, the animation shows the best solution found so far.

> [!VIDEO https://www.microsoft.com/videoplayer/embed/RE4MFtm]

In this section, we'll use quantum-inspired optimization to solve the problem.

> [!NOTE]
> This problem is known as a *number partitioning problem*. Although it's classified as NP-hard, in practice other efficient algorithms exist that can provide approximate solutions much faster than quantum-inspired optimization might. Nevertheless, we'll use the freight-balancing problem to illustrate QIO concepts and how to use the Azure Quantum service, because it's a familiar and easily understood example. In a later module, [Solve a job shop scheduling optimization problem by using Azure Quantum](/training/modules/solve-job-shop-optimization-azure-quantum/), we'll tackle a more challenging problem where quantum-inspired optimization might provide a practical advantage.

## Express the problem

Let's start by coming up with an expression for the weight of a given container. This is simply the sum of the weights of all the mineral chunks it contains. The sum is expressed in the following equation, where $w_i$ is the weight of chunk *i*:

![An equation that shows the sum of mineral weights.](../media/cost-function-1.svg)

Ideally, we want a solution where the weight difference between the containers, $\Delta$, is as small as possible.

![An equation that subtracts the weight of one container from the weight of the other to produce a cost function.](../media/cost-function-2.svg)

This equation subtracts the sum of weights on container B from the sum of weights on container A.

The letter *H* is used to represent a cost function. This notation originates from the model we're using to define our optimization problem, known as the *Ising model*. In this model, the energy, which represents the cost, is given by a Hamiltonian, whose variables take the value of +1 or -1. Our goal is to map the optimization to this form.

## Refine the problem

We now introduce a variable, $x_i$, to represent whether an individual mineral chunk *i* is assigned to container A or container B.

Because we assign the chunk *i* to either of two containers, the variable $x_i$ can take on two different values, which makes it a binary variable. For convenience, we say the two values it can take on are *1* and *-1*. The value *1* corresponds to the mineral chunk being placed on container A, and *-1* to the chunk being placed on container B. Because of our decision to make $x_i$ either *1* or *-1*, our optimization problem is called an *Ising problem*.

By introducing the variable $x_i$, we can simplify the equation as follows:

![An equation that introduces a binary variable to simplify the calculation of the cost function.](../media/cost-function-3.svg)

## Refine the problem again

There's one last change we need to make before we can solve this problem.

If we look at our cost function *H*, there's a flaw: the solution with the least cost is to assign the entirety of the extracted mineral to container B by setting all of the $x_i$ variables equal to *-1*. But that's not correct. To fix this, we square the right side of the equation to ensure that it can't be negative.

![An equation that squares the previous computation to ensure that the cost function is not negative.](../media/cost-function-4.svg)

This final model gives us a cost function with the required properties.

- If all the mineral is in one container, the function is at its highest value. This is the least optimal solution.
- If the freight containers are perfectly balanced, the value of the summation inside the square is *0*. This means the function is at its lowest, or optimal, value.

## Solve the problem with Azure Quantum

Now that you've learned how our combinatorial optimization problem can be cast in Ising form, we're ready to invoke a QIO solver to compute solutions for us. As you make your way through the rest of this section, copy the code sequences into a Jupyter notebook to execute them. Feel free to play with the problem parameters and observe how the results change.

### Create a new Notebook in your workspace

1. Log in to the [Azure portal](https://portal.azure.com/) and select the workspace you created in the previous step.
1. In the left blade, select **Notebooks**.
1. Click **My Notebooks** and click **Add New**.
1. In **Kernel Type**, select **IPython**.
1. Type a name for the file, for example *MineralWeightsOptimization.ipynb*, and click **Create file**. 

When your new Notebook opens, it automatically creates the code for the first cell, based on your subscription and workspace information.

```py
from azure.quantum import Workspace
workspace = Workspace (
    subscription_id = <your subscription ID>, 
    resource_group = <your resource group>,   
    name = <your workspace name>,          
    location = <your location>        
    )
```

You'll need to import two additional modules. Click **+ Code** to add a new cell and add the following lines:


```py
from typing import List
from azure.quantum.optimization import Term
```

### Problem instantiation

To submit a problem to the Azure Quantum services, we first need to create a `Problem` instance. This is a Python object that stores all the required information, such as the cost function details and the kind of problem we are modeling.

We've already introduced some problem types, such as PUBO, QUBO, and Ising. In this example, we'll use the Ising type, which is available via `ProblemType.ising`.

To represent cost functions, we'll apply a formulation that uses `Term` objects. Ultimately, any polynomial cost function can be written as a simple sum of products. That is, the function can be rewritten in the following form, where $p_k$ indicates a product over the problem variables $x_0, x_1, \dots$:

$$ H(x) = \sum_k \alpha_k \cdot p_k(x_0, x_1, \dots) $$

$$ \text{e.g. } H(x) = 5 \cdot (x_0) + 2 \cdot (x_1 \cdot x_2) - 3 \cdot ({x_3}^2) $$

In this form, every term in the sum has a coefficient $\alpha_k$ and a product $p_k$. In the `Problem` instance, each term in the sum is represented by a `Term` object, with parameters `c`, corresponding to the coefficient, and `indices`, corresponding to the product. Specifically, the `indices` parameter is populated with the indices of all variables that appear in the term. For instance, the term $2 \cdot (x_1 \cdot x_2)$ translates to the following object: `Term(c=2, indices=[1,2])`.

Let's run through an example by using the cost function we derived earlier. For $n$ mineral chunks, the index $i$ runs from $0$ to $n-1$ :

$$ H(x) = \left(\sum_{i} w_{i} \cdot x_{i}\right)^2 $$

After we expand the square, we get a double summation where $j$ also indexes the $n$ chunks:

$$ H(x) = \sum_i \sum_j (w_i \cdot w_j) \cdot (x_i \cdot x_j) $$

While it may not look like it, this double sum is just another way to write a large sum with $n^2$ terms. Using the transformation $k=i \cdot n + j$, with $\alpha_k = w_i \cdot w_j$ and $p_k(x_0, \cdots, x_{n-1}) = x_i \cdot x_j$, we would indeed obtain the single summation form:

$$ H(x) = \sum_{k=0}^{n^2-1} \alpha_k \cdot p_k(x_0, \cdots, x_{n-1}) $$

Let's plug in some numbers. We'll use three mineral chunks with the weights $w_i \in [2,4,7]$ and, thus, with indices $i,j \in \\{0,1,2\\}$. The double summation form is easier to work with, so let's use that one. For every value of $i$, we add three terms, one for each value of $j$:

$$ H(x) = (2 \cdot 2) \cdot (x_0 \cdot x_0) + (2 \cdot 4) \cdot (x_0 \cdot x_1) + (2 \cdot 7) \cdot (x_0 \cdot x_2) $$
$$ \hspace{25pt} +\ (4 \cdot 2) \cdot (x_1 \cdot x_0) + (4 \cdot 4) \cdot (x_1 \cdot x_1) + (4 \cdot 7) \cdot (x_1 \cdot x_2) $$
$$ \hspace{25pt} +\ (7 \cdot 2) \cdot (x_2 \cdot x_0) + (7 \cdot 4) \cdot (x_2 \cdot x_1) + (7 \cdot 7) \cdot (x_2 \cdot x_2) $$

Because this is an Ising problem, the variables $x_i$ can take on a value of either $1$ or $-1$, which implies that $x_i^2$ will always equal $1$. Because we don't care what the actual value of $H$ is, only that it's minimized, we can safely remove these terms. The final form, now containing six instead of nine terms, is then given by:

$$ H(x) = 8 \cdot (x_0 \cdot x_1) + 14 \cdot (x_0 \cdot x_2) + 8 \cdot (x_1 \cdot x_0) + 28 \cdot (x_1 \cdot x_2) + 14 \cdot (x_2 \cdot x_0) + 28 \cdot (x_2 \cdot x_1) $$

In Python, we would thus introduce the following `Terms`:

- `Term(c =  8, indices = [0, 1])`
- `Term(c = 14, indices = [0, 2])`
- `Term(c =  8, indices = [1, 0])`
- `Term(c = 28, indices = [1, 2])`
- `Term(c = 14, indices = [2, 0])`
- `Term(c = 28, indices = [2, 1])`

The following function generalizes the `Term` creation for any number of weights by using some for loops. It takes an array of mineral weights and returns a `Problem` object that contains the cost function.

Click **+ Code** to add another new cell and add the following lines:

```python
from typing import List
from azure.quantum.optimization import Problem, ProblemType, Term

def createProblemForMineralWeights(mineralWeights: List[int]) -> Problem:
    terms: List[Term] = []

    # Expand the squared summation
    for i in range(len(mineralWeights)):
        for j in range(len(mineralWeights)):
            if i == j:
                # Skip the terms where i == j as they form constant terms in an Ising problem and can be disregarded.
                continue

            terms.append(
                Term(
                    c = mineralWeights[i] * mineralWeights[j],
                    indices = [i, j]
                )
            )

    # Return an Ising-type problem
    return Problem(name="Freight Balancing Problem", problem_type=ProblemType.ising, terms=terms)
```

Before we submit the problem to Azure Quantum, we instantiate it by defining a list of mineral chunks via their weights. 

Click **+ Code** to add another new cell and add the following lines:

```python
# This array contains the weights of all the mineral chunks
mineralWeights = [1, 5, 9, 21, 35, 5, 3, 5, 10, 11]

# Create a problem for the given list of minerals:
problem = createProblemForMineralWeights(mineralWeights)
```

### Submit the problem to Azure Quantum

You're now ready to submit your problem to Azure Quantum using the `ParallelTempering` solver:

> [!NOTE]
> Here we use the Parallel Tempering solver as an example of a Microsoft QIO solver. For more information about available solvers, you can visit the [Microsoft QIO provider](/azure/quantum/provider-microsoft-qio?azure-portal=true) documentation page. However, solver selection and tuning is beyond the scope of this module.

Add another cell with the following code that opens the solver, submits the problem, and displays the result:

```python
from azure.quantum.optimization import ParallelTempering

solver = ParallelTempering(workspace, timeout=100)

result = solver.optimize(problem)
print(result)
```
This method submits the problem to Azure Quantum for optimization and synchronously wait for it to be solved. 

Click **Run all** and you'll see output like the following in your Notebook:

```output
......{'version': '1.0', 'configuration': {'0': 1, '1': -1, '2': 1, '3': 1, '4': -1, '5': -1, '6': -1, '7': -1, '8': 1, '9': 1}, 'cost': -2052.0, 'parameters': {'all_betas': [0.00020408163265306123, 0.0010031845282727856, 0.004931258069052868, 0.024240112818991428, 0.00020408163265306123, 0.00041416312947479666, 0.0008405023793001501, 0.0017057149691356173, 0.0034615768230851457, 0.007024921700835206, 0.014256371424073268, 0.028931870679351317, 0.058714319100389226, 0.00020408163265306123, 0.0003216601955060876, 0.000506979878727771, 0.0007990687098552142, 0.0012594401274306443, 0.001985047612326009, 0.003128702935041415, 0.0049312580690528685, 0.007772328229454337, 0.012250238227336452, 0.019308028713685834, 0.030432059025318557, 0.04796503207311015, 0.07559936381105262, 0.00020408163265306123, 0.0002853639172320586, 0.0003990195697643234, 0.0005579423586529702, 0.000780161423569038, 0.0010908866075247, 0.0015253684103382742, 0.0021328970135012235, 0.0029823940494438134, 0.004170231478526455, 0.0058311645933360684, 0.008153619454858395, 0.011401069057563778, 0.015941923261808107, 0.022291323383991948, 0.031169582869598398, 0.043583903904173556, 0.06094264037716683, 0.08521506986401543, 0.00020408163265306123, 0.0002661133962019146, 0.0003470000642267741, 0.0004524726913109797, 0.0005900043184095882, 0.0007693394594342792, 0.0010031845282727856, 0.001308108124995844, 0.0017057149691356171, 0.002224176656606702, 0.002900227698828882, 0.0037817682692016645, 0.004931258069052867, 0.006430141778288393, 0.0083846196467327, 0.010933172089261346, 0.01425637142407326, 0.018589675944162696, 0.02424011281899142, 0.031608031858238926, 0.04121547145476594, 0.05374314651596505, 0.0700786790855087, 0.09137948893466513], 'replicas': 70, 'sweeps': 600}, 'solutions': [{'configuration': {'0': 1, '1': -1, '2': 1, '3': 1, '4': -1, '5': -1, '6': -1, '7': -1, '8': 1, '9': 1}, 'cost': -2052.0}]}
```

Notice that the solver returned the results in the form of a Python dictionary, along with some metadata. For a more human-readable format, use the following function to print a summary of what the solution means. 

Click **+ Code** to add another new cell and add the following lines:

```python
def printResultSummary(result):
    # Print a summary of the result
    containerAWeight = 0
    containerBWeight = 0
    for chunk in result['configuration']:
        chunkAssignment = result['configuration'][chunk]
        chunkWeight = mineralWeights[int(chunk)]
        container = ''
        if chunkAssignment == 1:
            container = 'A'
            containerAWeight += chunkWeight
        else:
            container = 'B'
            containerBWeight += chunkWeight

        print(f'Mineral chunk {chunk} with weight {chunkWeight} was placed on Container {container}')

    print(f'\nTotal weights: \n\tContainer A: {containerAWeight} tons \n\tContainer B: {containerBWeight} tons')

printResultSummary(result)
```

```output
Mineral chunk 0 with weight 1 was placed on Container A
Mineral chunk 1 with weight 5 was placed on Container B
Mineral chunk 2 with weight 9 was placed on Container A
Mineral chunk 3 with weight 21 was placed on Container A
Mineral chunk 4 with weight 35 was placed on Container B
Mineral chunk 5 with weight 5 was placed on Container B
Mineral chunk 6 with weight 3 was placed on Container B
Mineral chunk 7 with weight 5 was placed on Container B
Mineral chunk 8 with weight 10 was placed on Container A
Mineral chunk 9 with weight 11 was placed on Container A

Total weights: 
	Container A: 52 tons 
	Container B: 53 tons
```

Great! The solver found a partition such that the containers are within 1&nbsp;ton of each other. This outcome is satisfactory, because a perfectly balanced solution doesn't exist for this problem instance.

## Improve the cost function

The cost function you've built works well so far, but let's take a closer look at the `Problem` that was generated.

Click **+ Code** to add another new cell and add the following lines:

```python
print(f'The problem has {len(problem.terms)} terms for {len(mineralWeights)} mineral chunks:')
print(problem.terms)
```

```output
The problem has 90 terms for 10 mineral chunks:
[{'c': 5, 'ids': [0, 1]}, {'c': 9, 'ids': [0, 2]}, {'c': 21, 'ids': [0, 3]}, {'c': 35, 'ids': [0, 4]}, {'c': 5, 'ids': [0, 5]}, {'c': 3, 'ids': [0, 6]}, {'c': 5, 'ids': [0, 7]}, {'c': 10, 'ids': [0, 8]}, {'c': 11, 'ids': [0, 9]}, {'c': 5, 'ids': [1, 0]}, {'c': 45, 'ids': [1, 2]}, {'c': 105, 'ids': [1, 3]}, {'c': 175, 'ids': [1, 4]}, {'c': 25, 'ids': [1, 5]}, {'c': 15, 'ids': [1, 6]}, {'c': 25, 'ids': [1, 7]}, {'c': 50, 'ids': [1, 8]}, {'c': 55, 'ids': [1, 9]}, {'c': 9, 'ids': [2, 0]}, {'c': 45, 'ids': [2, 1]}, {'c': 189, 'ids': [2, 3]}, {'c': 315, 'ids': [2, 4]}, {'c': 45, 'ids': [2, 5]}, {'c': 27, 'ids': [2, 6]}, {'c': 45, 'ids': [2, 7]}, {'c': 90, 'ids': [2, 8]}, {'c': 99, 'ids': [2, 9]}, {'c': 21, 'ids': [3, 0]}, {'c': 105, 'ids': [3, 1]}, {'c': 189, 'ids': [3, 2]}, {'c': 735, 'ids': [3, 4]}, {'c': 105, 'ids': [3, 5]}, {'c': 63, 'ids': [3, 6]}, {'c': 105, 'ids': [3, 7]}, {'c': 210, 'ids': [3, 8]}, {'c': 231, 'ids': [3, 9]}, {'c': 35, 'ids': [4, 0]}, {'c': 175, 'ids': [4, 1]}, {'c': 315, 'ids': [4, 2]}, {'c': 735, 'ids': [4, 3]}, {'c': 175, 'ids': [4, 5]}, {'c': 105, 'ids': [4, 6]}, {'c': 175, 'ids': [4, 7]}, {'c': 350, 'ids': [4, 8]}, {'c': 385, 'ids': [4, 9]}, {'c': 5, 'ids': [5, 0]}, {'c': 25, 'ids': [5, 1]}, {'c': 45, 'ids': [5, 2]}, {'c': 105, 'ids': [5, 3]}, {'c': 175, 'ids': [5, 4]}, {'c': 15, 'ids': [5, 6]}, {'c': 25, 'ids': [5, 7]}, {'c': 50, 'ids': [5, 8]}, {'c': 55, 'ids': [5, 9]}, {'c': 3, 'ids': [6, 0]}, {'c': 15, 'ids': [6, 1]}, {'c': 27, 'ids': [6, 2]}, {'c': 63, 'ids': [6, 3]}, {'c': 105, 'ids': [6, 4]}, {'c': 15, 'ids': [6, 5]}, {'c': 15, 'ids': [6, 7]}, {'c': 30, 'ids': [6, 8]}, {'c': 33, 'ids': [6, 9]}, {'c': 5, 'ids': [7, 0]}, {'c': 25, 'ids': [7, 1]}, {'c': 45, 'ids': [7, 2]}, {'c': 105, 'ids': [7, 3]}, {'c': 175, 'ids': [7, 4]}, {'c': 25, 'ids': [7, 5]}, {'c': 15, 'ids': [7, 6]}, {'c': 50, 'ids': [7, 8]}, {'c': 55, 'ids': [7, 9]}, {'c': 10, 'ids': [8, 0]}, {'c': 50, 'ids': [8, 1]}, {'c': 90, 'ids': [8, 2]}, {'c': 210, 'ids': [8, 3]}, {'c': 350, 'ids': [8, 4]}, {'c': 50, 'ids': [8, 5]}, {'c': 30, 'ids': [8, 6]}, {'c': 50, 'ids': [8, 7]}, {'c': 110, 'ids': [8, 9]}, {'c': 11, 'ids': [9, 0]}, {'c': 55, 'ids': [9, 1]}, {'c': 99, 'ids': [9, 2]}, {'c': 231, 'ids': [9, 3]}, {'c': 385, 'ids': [9, 4]}, {'c': 55, 'ids': [9, 5]}, {'c': 33, 'ids': [9, 6]}, {'c': 55, 'ids': [9, 7]}, {'c': 110, 'ids': [9, 8]}]
```

That's a lot of terms for just 10 chunks! On closer inspection, you'll note that there are essentially duplicate terms. These terms are the result of having squared the right side of the equation when we built our cost function. For example, look at the last term: `{'w': 110, 'ids': [9, 8]}`. If you look through the rest of the terms, you'll find a symmetrical copy of it: `{'w': 110, 'ids': [8, 9]}`.

This duplicate encodes the exact same information in our cost function. However, because we don't care about the value of the cost function, only the shape, we can omit these terms, as shown here:

![An equation that reduces the number of terms in the previous cost function.](../media/cost-function-5.svg)

Notice that we've expanded the square in our previous cost function to a summation over two indices, $i$ and $j$. With the constraint $i<j$, we exclude the symmetric copies of terms mentioned above. As a bonus, "constant" $i=j$ terms, which don't contribute to the solution, are excluded as well.

To implement the improved cost function, modify your `createProblemForMineralWeights` function as follows. Add another cell with the following code:


```python
def createSimplifiedProblemForMineralWeights(mineralWeights: List[int]) -> Problem:
    terms: List[Term] = []

    # Expand the squared summation
    for i in range(len(mineralWeights)-1):
        for j in range(i+1, len(mineralWeights)):
            terms.append(
                Term(
                    w = mineralWeights[i] * mineralWeights[j],
                    indices = [i, j]
                )
            )

    # Return an Ising-type problem
    return Problem(name="Freight Balancing Problem (Simplified)", problem_type=ProblemType.ising, terms=terms)
```

Let's check that this creates a smaller problem:

```python
# Create the simplified problem
simplifiedProblem = createSimplifiedProblemForMineralWeights(mineralWeights)
print(f'The simplified problem has {len(simplifiedProblem.terms)} terms')
```

```output
The simplified problem has 45 terms
```

Success! The problem has half as many terms. Now let's run it and verify the result. 

Click **+ Code** to add another new cell and add the following code:

```python
# Optimize the problem
print('Submitting simplified problem...')
start = time.time()
simplifiedResult = solver.optimize(simplifiedProblem)
timeElapsedSimplified = time.time() - start
print(f'Result in {timeElapsedSimplified} seconds: ', simplifiedResult)
printResultSummary(simplifiedResult)
```

```output
Submitting simplified problem...
..Result in 8.950008630752563 seconds:  {'version': '1.0', 'configuration': {'0': 1, '1': -1, '2': -1, '3': -1, '4': 1, '5': -1, '6': -1, '7': 1, '8': -1, '9': 1}, 'cost': -1026.0}
Mineral chunk 0 with weight 1 was placed on Container A
Mineral chunk 1 with weight 5 was placed on Container B
Mineral chunk 2 with weight 9 was placed on Container B
Mineral chunk 3 with weight 21 was placed on Container B
Mineral chunk 4 with weight 35 was placed on Container A
Mineral chunk 5 with weight 5 was placed on Container B
Mineral chunk 6 with weight 3 was placed on Container B
Mineral chunk 7 with weight 5 was placed on Container A
Mineral chunk 8 with weight 10 was placed on Container B
Mineral chunk 9 with weight 11 was placed on Container A

Total weights:
    Container A: 52 tons
    Container B: 53 tons
```

As you can see, the quality of the solution is the same for both cost functions. The container loads are within 1&nbsp;ton of each other. This reveals an important fact about using quantum-inspired optimization solvers: it's often possible (and necessary) to optimize the cost function to generate more optimal solutions more quickly.
