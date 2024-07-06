#!/bin/bash

# GitHub token
GITHUB_TOKEN="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"

# Array of old and new repository names
declare -A repos=( 
    ["A_star"]="understand-astar-search" 
    ["ct_segmentation"]="understand-liver-segmentation" 
    ["jockey_logistic_regression"]="understand-jockey-logistic-sim" 
    ["kriging_model"]="understand-kriging" 
    ["marching_cubes_demo"]="understand-marching-cubes" 
    ["medical_imaging_ml"]="understand-medical-imaging-methods" 
    ["nn_scratch_project"]="understand-neural-networks-numpy"
    ["reinforcement_snake_game_"]="understand-reinforcement-learning" 
    ["understanding-biostat-poisson-tests"]="understand-poisson-tests" 
    ["understanding-clinical-trials"]="understand-clinical-trails" 
    ["understanding-nlp-classification"]="understand-nlp-classification" 
)

# Directory where the script is running
BASE_DIR=$(pwd)

# Rename repositories and add as submodules
for old_name in "${!repos[@]}"; do
    new_name="${repos[$old_name]}"
    
    # Rename the repository using GitHub API
    echo "Renaming repository $old_name to $new_name"
    curl -X PATCH -H "Authorization: token $GITHUB_TOKEN" \
         -H "Accept: application/vnd.github.v3+json" \
         -d "{\"name\":\"$new_name\"}" \
         https://api.github.com/repos/adamkurth/$old_name

    # Add the renamed repository as a submodule
    echo "Adding $new_name as a submodule"
    git submodule add https://github.com/adamkurth/$new_name $new_name

    # Commit the submodule addition
    git add .gitmodules $new_name
    git commit -m "Added submodule $new_name"
done

# Push changes to the repository
git push origin main

echo "All repositories renamed, added as submodules, and committed."
