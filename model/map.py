
import cv2
import numpy as np
import matplotlib.pyplot as plt
from os import path
import os
import glob
from PIL import Image

#test_data_path = './data/align_dataset/0'
def files_with_ext(data_path, data_type):
    file_list = [file for file in os.listdir(data_path) if file.lower().endswith(data_type)]
    print(len(file_list))
    return file_list
def mk_dir(dir_path):
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
    return dir_path
def start(file_test_list):
    image_files = glob.glob(os.path.join(file_test_list, '*jpg'))
    for image_file in image_files:
        imagePath = os.path.join(image_file)
        imagePath = imagePath.replace('\\', '/')
        image_filename = os.path.basename(image_file)  # 获取图像文件名
        save_path = os.path.join(data_save_path, image_filename)  # 添加图像文件名到保存路径
        img = cv2.imread(imagePath)
        new_width = 512
        new_height = 512

        # 调整图片尺寸
        img = cv2.resize(img, (new_width, new_height))
        #cv2.imshow("src", img)
        grayImage = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        imageHeight, imageWidth = grayImage.shape[0:2]
        print(imageWidth, ", ", imageHeight)
        # 进行一次自适应阈值提升边界识别度，参数可根据不同图片适当调整，特别是左后一个参数
        binaryImage = cv2.adaptiveThreshold(grayImage, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 35, 10)
        #cv2.imshow("binaryImage", ~binaryImage)
        binaryImage = ~binaryImage
        # 形态学操作，可根据图片质量来取舍是否需要进行该操作
        # kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 1))
        # binaryImage = cv2.erode(binaryImage, kernel, iterations=1)
        # binaryImage = cv2.dilate(binaryImage, kernel, iterations=1)
        #cv2.imshow("binaryImage", binaryImage)
        # 查找轮廓
        contours, hierarchy = cv2.findContours(~binaryImage, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        # 画轮廓
        cv2.drawContours(img, contours, 0, (0, 0, 255), 1)
        #cv2.imshow("imgray", img)
        count = 0
        for i in range(len(contours)):
            arclen = cv2.arcLength(contours[i], True)
            epsilon = max(3, int(arclen * 0.02))
            # 每个轮廓进行多边形拟合，计算其面积，变数，周长等信息
            approx = cv2.approxPolyDP(contours[i], epsilon, True)
            # 计算面积
            area = cv2.contourArea(contours[i])
            #print("area = ", area)
            # 计算最小包围矩阵，这里没太多印象，要不要无所谓
            rect = cv2.minAreaRect(contours[i])
            #print("rect = ", rect)
            # 获取最小包围矩阵的四个点
            box = np.int0(cv2.boxPoints(rect))
            #print("box = ", box)
            h = int(rect[1][0])
            w = int(rect[1][1])
            if min(h, w) == 0:
                rotion = 0
            else:
                rotion = max(h, w) / min((h, w))
            imageArea = imageWidth * imageHeight
            # 这里是删选轮廓的判断，长款比太大的不要，面积太小的不要，太大的也不要，如果是想得到四边形，那么后面的shap[0]就是去这个轮廓的边数，我这里取四边形，满足条件的轮廓画出来
            if rotion < 15 and area > imageArea * 0.1 and area < imageWidth * imageHeight * 0.99 and approx.shape[0] == 4:
                # 对满足条件的轮廓画出轮廓的拟合多边形
                point1 = (approx[0][0][0], approx[0][0][1])
                point2 = (approx[1][0][0], approx[1][0][1])
                point3 = (approx[2][0][0], approx[2][0][1])
                point4 = (approx[3][0][0], approx[3][0][1])
                count = count +1
                # 输出四个点的坐标
                print("满足")
                cv2.polylines(img, [approx], True, (0, 255, 0), 1)
                cv2.circle(img, (approx[0][0][0], approx[0][0][1]), 3, (0, 0, 255), 2)
                cv2.putText(img, str(1), (approx[0][0][0], approx[0][0][1]), cv2.FONT_HERSHEY_PLAIN,
                            1.0, (0, 0, 0), thickness=1)
                cv2.circle(img, (approx[1][0][0], approx[1][0][1]), 3, (0, 0, 255), 2)
                cv2.putText(img, str(2), (approx[1][0][0], approx[1][0][1]), cv2.FONT_HERSHEY_PLAIN,
                            1.0, (0, 0, 0), thickness=1)
                cv2.circle(img, (approx[2][0][0], approx[2][0][1]), 3, (0, 0, 255), 2)
                cv2.putText(img, str(3), (approx[2][0][0], approx[2][0][1]), cv2.FONT_HERSHEY_PLAIN,
                            1.0, (0, 0, 0), thickness=1)
                cv2.circle(img, (approx[3][0][0], approx[3][0][1]), 3, (0, 0, 255), 2)
                cv2.putText(img, str(4), (approx[3][0][0], approx[3][0][1]), cv2.FONT_HERSHEY_PLAIN,
                            1.0, (0, 0, 0), thickness=1)
                #cv2.imshow("polylines", img)
                original_points = np.array([point2,point1, point4,point3], dtype=np.float32)

                # 变换后的图像中的四个点，顺序可以自定义
                transformed_points = np.array([[0, 0], [0, 512], [512, 512], [512, 0]], dtype=np.float32)

                # 计算透视变换矩阵
                M = cv2.getPerspectiveTransform(original_points, transformed_points)

                # 进行透视变换
                result_img = cv2.warpPerspective(img, M, (512, 512))  # width和height是目标图像的尺寸
                plt.axis('off')
                plt.imshow(cv2.cvtColor(result_img, cv2.COLOR_BGR2RGB))
                #plt.title('Perspective Transformed Image')
                plt.savefig(save_path)
        if(count==0):
            print("不满足")
            cv2.imwrite(save_path,img)
        else:
            # Find the bounding box around the transformed region
            non_zero_pixels = cv2.findNonZero(binaryImage)
            x, y, w, h = cv2.boundingRect(non_zero_pixels)

            # Crop the transformed image to the bounding box
            result_img = result_img[y:y + h, x:x + w]

            # Save the cropped image
            plt.axis('off')
            plt.imshow(cv2.cvtColor(result_img, cv2.COLOR_BGR2RGB))
            plt.savefig(save_path)


if __name__ == "__main__":
    data_save_path = r'C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\map'#保存图片的路径（这里是一个文件夹）
    file_test_list = r'C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\upload'#输入图片的路径（这里是一个文件夹）
#     data_save_path =  r'..\image\map'#保存图片的路径（这里是一个文件夹）
#     file_test_list = r'..\image\upload'#输入图片的路径（这里是一个文件夹）
    start(file_test_list)
    cv2.waitKey(0)




 # data_save_path =  r'../image/map'#保存图片的路径（这里是一个文件夹）
    # file_test_list = r'../image/upload'#输入图片的路径（这里是一个文件夹）

