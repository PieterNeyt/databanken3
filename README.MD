In order to be able to run the code in this repository, you need to install some software and packages. Follow the instructions with care. Don't skip any steps. If you have any problems, use the Teams channel to ask for help.

### 1. Install Python
1. Install the latest version of python 3.13 (no later) from https://www.python.org/downloads/ 
3. After installation, open a terminal and run the command: python --version (should be 3.13.x)

### 2. Loading this project in PyCharm
1. Open PyCharm
2. Select "Get from VCS"
3. Use this git-project as the URL and provide your credentials for GitLab
4. Do not yet create a virtual environment if asked in a popup.
5. In Settings >Project Settings > Python Interpreter, select Add interpreter... > Add local interpreter > Environment New > Base: 3.13 > Location: different from your project and on a path without spaces > OK
6. Make sure this new created environment is selected as the interpreter for this project

### 3. Setup the data architecture
The necessary data architecture is provided as docker containers. It includes a jupyter notebook server with spark and delta lake and postgres database.
1. Make sure you have Docker (Desktop) installed and running on your machine.
2. Open the deployDataArchitecture folder in a file explorer
3. Change the project_root in the deployDataArchitecture script to the path of this project (ps1 for windows, sh for MacOS/Linux*)
4. Run the deployDataArchitecture in DockerSetup (ps1 for Windows, sh for MacOS/Linux)
5. Wait until all containers are running (check in Docker Desktop)

Attention: If you have a local postgres installation it can conflict with the port of the docker container. 
Either uninstall the local postgres server or change 5432:5432 to 6432:5432 in deployDataArchitecture 
> Delete the containers > rerun the script 
> Make sure to use the updated port in your datasource settings in PyCharm


*the .sh script is AI generated based on the ps1 script. If you fixed something in the sh script please contact the teacher.

### 4. Installing the required packages
To enable the necessary code completion and integration in PyCharm, you need to install the required packages.
_If PyCharm asks to install required packages when opening the project, do so. If not, follow these steps:_
1. Go to terminal in PyCharm
2. Run the command: pip install -r requirements.txt (it includes all the necessary packages for this course)
3. Make sure all the packages are installed correctly (if you have errors, try to solve them and run the command again)
4. If the IDE asks to install jupyter, do so.

### 5. Install Big Data Tools plugin
_PyCharm has a set of plugins that helps you running Spark Applications._
2. Search for Big Data Tools and install the plugin bundle

### 6. Performing the first testruns
_The spark code is running in a jupyter notebook server in a docker container. You need to connect to it from PyCharm._
1. Open the CHECK_1_install.ipynb file in PyCharm
2. Create a new EXTERNAL jupyter server connection (top right corner) to http://localhost:8888 with password "data".
2. Run all cells one by one and check if everything is working correctly
3. If you have errors, try to solve them and run the cells again.
4. If you are stuck and cannot solve the errors, contact the teacher.
5. If everything is working correctly, you are ready to start the course!

