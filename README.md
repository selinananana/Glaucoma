# Glaucoma

## Introduction
This project is an AI-based galucoma diagnosis method, taking color fundus photos taken by mobile phones as input and providing users with online diagnostic results. 

## Program associations
The overall project is mainly divided into three ends, mobile APP, server, and model library. This project is mainly related to the server and model library.
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
This project is a server-side inspection program, the following mainly introduces the server-side design,it will be judged by the AI model,finally. The model first invokes two image preprocessing modules: rectification and noise-removal modules. In the rectification module, images are output with a fixed size and appropriate position using a perspective transform. After the rectification, a noise-removal module efficiently denoises the uploaded image to improve its overall quality. With these two steps, the quality of the images themselves is significantly enhanced. Furthermore, a prediction module is designed with AI-powered components including a feature extraction module, an attention module, and a classifier. With the optimizations in the prediction module, the accuracy and generalization ability of the analysis are improved, since problems including problems over fine details, discriminative regions caused by unbalanced labels, and overfitting are effectively addressed. The front end is an APP ([Glaucoma](https://github.com/selinananana/Glaucoma-APP)) implemented through VUE, which is mainly responsible for taking photos and uploading inspections.

## Environmental preparation
### environment preparation
1. Conda creates a virtual python environment named Glaucoma, python 3.7.4
2. Matlab is invoked to perform the denoising task, matlab 2017a
<br>Note that you need to install CUDA according to your computer configuration, and you need to ensure that the pytorch and python versions match

### Server side configuration
1. ENV Version: JDK 11.0.8、maven 3.6.3
2. Import the Glaucoma project in IDEA and update the maven information.
3. Modify the file addresses of the three python files（**main.py**, **map.py**, **test.py**） and update them to the current environment directory

## Run it
At this point, the configuration is complete and the server is started.<br>
Note: Whether the environment of the entire machine is blocked by firewalls, etc., to ensure that the APP can access the IP+Port.
