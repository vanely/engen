# EnvGenerator
Scripts that generate a template for an environment where one can practice programming and build projects

Most of the code implies that the base environment where these scripts are being executed is a unix based OS,
or the user is using GIT Bash Shell on Windows.

### Create Directory Tree
In `engen/config-file-templates/` directory you'll find an example template for a config file that can be used
for building a reusable directory tree. 

A config file is optional, when the option "Create Directory Tree" is selected you will be prompted to use one or
continue with default template. 

!!NOTE!! When a directory tree is generated an alias `engen` is globally exported to a `~/.profile`, and sourced in your `.bashrc`, or `.zshrc`

### Update Directory Tree
Allows user to update created directory tree with modifications made to the config file the represents said created 
directory tree. 

### Install Programs
Add install functions to `engen/programs-to-install/` and put them in install arrays for their respective operating system<br/>
Currently only supports linux installs.<br/>
Support for Mac and Windows coming real soon! >=D

### Cleanup
The scripts in here allow the user to remove previously generated directory trees, and installed programs.

### Git Utils
The scripts in here allow the user to check the status of, and update any or all of the configured git repos in the directory tree.
You are also able to create and delete repos in github via the options provided by these scripts.
In the `engen/utils/git-utils/git_utils.sh` you will be able to configure a connection to your personal github account
so that you may use the `clone_git_repo` function inside for cloning repos to your directory trees.

### Extras
In the`engen/utils/helpers` directory you can modify the `initial_checks.sh` file for setting global, or local configs for git credentials.
You can also modify the `vscode_extensions.sh` file, which can be used to keep track of, and automate the installation of your favorite vscode extensions.
You may however want to opt for syncing either, your microsoft, or github account to vscode to keep your settings, and extensions where ever you go.

### Steps To Execute
To access the below menu:
When the repo is first cloned execute the `main.sh` script at the top level of the engen directory. After generating the first directory tree `Create Directory Tree` 
an alias `engen` will be globally exported to `~/.profile`, and sourced in `.bashrc`, and or `.zshrc`, which can be used after to access the same menu and allows the 
choice of generated directory context.

0: Create Directory Tree<br/>
1: Update Directory Tree<br/>
2: Install Programs<br/>
3: Clean Up<br/>
4: Git Utils<br/>
5: VS Code Extensions
