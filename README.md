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

!!NOTE!!: when the project is cloned and used to generate a directory tree, the scripts should 
then after be run from the same project(fork of `PublicEnvGenerator`) but the one that get's cloned into the generated directory tree.
The reason for this is, multiple directory trees can be generated, and each will have their own respective context in the file system
that's derived by the location of the main project.

### Install Programs
Add install functions to `PublicEnvGenerator/programs-to-install/` and put them in install arrays for their respective operating system<br/>
Currently only supports linux installs.<br/>
Support for Mac and Windows coming real soon! >=D


### Cleanup
The scripts in here allow the user to remove previously generated directory trees, and installed programs.

### Git Utils
The scripts in here allow the user to check the status of, and update any or all of the configured git repos in the directory tree.
You are also able to create and delete repos in github via the options provided by these scripts.
In the `PublicEnvGenerator/utils/git-utils/git_utils.sh` you will be able to configure a connection to your personal github account
so that you may use the `clone_git_repo` function inside for cloning repos to your directory trees.

### Extras
There is a `PublicEnvGenerator/utils/helpers` directory where you can modify an `initial_checks.sh` file for setting global, or local configs for git credentials.
You can also modify the `vscode_extensions.sh` file, which can be used to keep track of, and automate the installation of your favorite vscode extensions.
You may however want to opt for syncing either, your microsoft, or github account to vscode to keep your settings, and extensions where ever you go.

### Steps To Execute
The `main.sh` executable at the top level of PublicEnvGenerator will present the following choices

0: Create Directory Tree<br/>
1: Update Directory Tree<br/>
2: Install Programs<br/>
3: Clean Up<br/>
4: Git Utils<br/>
5: VS Code Extensions
