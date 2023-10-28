# Glaucoma

## Introduction
This project is a practical project of glaucoma AI diagnosis method based on color fundus photos taken by mobile phones. 

## Program associations
It is mainly divided into three parts, mobile APP, server and model library. This project is mainly related to the server and model library.
```
                                 +-----------+
                                 | AI Model  |
                                 +--^----+---+
                                    |    |
                                    |    |
+----------------+           +------+----v-------+
|                |   http    |                   |
|      APP       +---------->|      Server       |
|                |           |                   |
+----------------+           +-------------------+
```
The front end is an APP ([Glaucoma](https://github.com/selinananana/Glaucoma-APP)) implemented through VUE, which is mainly responsible for taking photos and uploading inspections, this project is a server-side inspection program, the following mainly introduces the server-side design,it will be judged by the AI model,finally.

## Environmental preparation
### Python environment preparation (PYTHON)
1. Conda creates a virtual python environment named Glaucoma, python==3.7.4
2. Create a deblur virtual environment, the python version is 3.9.7
And configure the following environment of deblur:
<br>Note that you need to install CUDA according to your computer configuration, and you need to ensure that the pytorch and python versions match

### Server side configuration (JAVA):
1. ENV Version: JDK 11.0.8、maven 3.6.3
2. Import the Glaucoma project in IDEA and update the maven information.
3. Modify the file addresses of the three python files（**main.py**, **map.py**, **test.py**） and update them to the current environment directory

## Run it
At this point, the configuration is complete and the server is started.<br>
Note: Whether the environment of the entire machine is blocked by firewalls, etc., to ensure that the APP can access the IP+Port.
