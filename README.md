# EnvGenerator
Scripts that generate a template for an environment where one can practice programming languages and write projects

Most of the code implies that the base environment where these scripts are being executed are unix based OSes,
or the user is using GIT Bash Shell on Windows.

### Generate Dir Tree
In the `create_directories` function inside of the
`PublicEnvGenerator/env-creation/generate_directory_tree.sh` file,
find where directories are being created. EX: `mkdir "${ROOT}"`.
There are comments for how to use the `clone_git_repo` function inside of the
`PublicEnvGenerator/utils/git-utils/git_utils.sh`

### Install Programs
Add install functions and put them in install arrays.
TODO: Add installs for other OSes 

### Steps To Execute
The `main.sh` executable at the top level of PublicEnvGenerator will present the following choices

0: Generate Programming Environment<br/>
1: Install Programs<br/>
2: Clean Up<br/>
3: Git Utils
