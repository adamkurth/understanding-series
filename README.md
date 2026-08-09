# understanding-series

A collection of self-contained submodules where I build up theoretical and applied
statistics/ML concepts from first principles — implementations, derivations, and
notes, not just library calls.

Each folder below is its own git repository, tracked here as a submodule against
its `main` branch.

## Modules

| Module | Topic |
|---|---|
| [understand-bayes-nonparametrics](https://github.com/adamkurth/understand-bayes-nonparametrics) | Bayesian nonparametric modeling |
| [understanding-mcmc](https://github.com/adamkurth/understanding-mcmc) | MCMC sampling methods |
| [understanding-statistical-linear-models](https://github.com/adamkurth/understanding-statistical-linear-models) | Linear / generalized linear models |
| [understand-poisson-tests](https://github.com/adamkurth/understand-poisson-tests) | Poisson-process hypothesis testing |
| [understand-kriging](https://github.com/adamkurth/understand-kriging) | Kriging and spatial statistics |
| [understand-liver-segmentation](https://github.com/adamkurth/understand-liver-segmentation) | Medical image segmentation |
| [understand-jockey-logistic-sim](https://github.com/adamkurth/understand-jockey-logistic-sim) | Logistic regression simulation study |
| [understand-neural-networks-numpy](https://github.com/adamkurth/understand-neural-networks-numpy) | Neural networks implemented from scratch in NumPy |
| [understand-reinforcement-learning](https://github.com/adamkurth/understand-reinforcement-learning) | Reinforcement learning fundamentals |
| [understand-nlp-classification](https://github.com/adamkurth/understand-nlp-classification) | NLP text classification |
| [understand-nlp-sentiment-analysis](https://github.com/adamkurth/understand-nlp-sentiment-analysis) | NLP sentiment analysis |
| [understand-astar-search](https://github.com/adamkurth/understand-astar-search) | A* search algorithm |
| [understand-marching-cubes](https://github.com/adamkurth/understand-marching-cubes) | Marching cubes / 3D surface extraction |

## Usage

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/adamkurth/understanding-series.git

# Or, if already cloned:
git submodule update --init --recursive
```

## Maintenance

`AUTOMATE-REPO-SUBMOD-SETUP.sh` manages the submodules:

```bash
./AUTOMATE-REPO-SUBMOD-SETUP.sh create <new-repo-name>   # scaffold a new module
./AUTOMATE-REPO-SUBMOD-SETUP.sh update                     # sync all to latest main
./AUTOMATE-REPO-SUBMOD-SETUP.sh status                      # check what's behind
./AUTOMATE-REPO-SUBMOD-SETUP.sh remove <repo-name>          # retire a module
```
