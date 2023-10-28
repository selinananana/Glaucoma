from keras.models import load_model
from keras import backend as K
from tensorflow.keras.preprocessing.image import ImageDataGenerator, load_img, img_to_array
import os
import numpy as np

def label_smooth(y_true, y_pred):
    y_true = ((1 - 0.1) * y_true + 0.05)
    return K.categorical_crossentropy(y_true, y_pred)

def weight_kappa(result, test_num):
    weight = np.zeros((2, 2), dtype='float')
    for i in range(2):
        for j in range(2):
            weight[i, j] = (i - j) * (i - j) / 4
    fenzi = 0
    for i in range(2):
        for j in range(2):
            fenzi = fenzi + result[i, j] * weight[i, j]
    fenmu = 0
    for i in range(2):
        for j in range(2):
            fenmu = fenmu + weight[i, j] * result[:, j].sum() * result[i, :].sum()

    weght_kappa = 1 - (fenzi / (fenmu / test_num))
    return weght_kappa


os.environ["CUDA_VISIBLE_DEVICES"] = "7"
image_size = 512
batch_size = 1
#model_name = 'De_noise2_no_FP29.h5'
model_name = r'C:\\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\model\De_noise2_over30.h5'
#test_dir = './data/Fundus_Train_Val_Data/Fundus_Scanes_Sorted/Validation/'
custom_test = True

if custom_test == False:
    model = load_model( model_name)
else:
    model = load_model(model_name, custom_objects={'label_smooth': label_smooth})


def preprocess_image(image_path):
    # Load the image and preprocess it
    img = load_img(image_path, target_size=(512, 512))
    img_array = img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)

    # Create an ImageDataGenerator with desired preprocessing options
    datagen = ImageDataGenerator(
        # Add your desired preprocessing options here binary matrix conversion
    )

    # Preprocess the image using the ImageDataGenerator
    processed_img = datagen.flow(img_array, batch_size=1)[0]
    return processed_img



# Example usage to predict a single image
single_image_path =r'C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\deblur/1.jpg'
single_image = preprocess_image(single_image_path)
single_image_prediction = model.predict(single_image)
predicted_class = np.argmax(single_image_prediction) 
# maximize to output the probability predicted
print(predicted_class)
#print('Image:', single_image_path, 'Predicted class:', predicted_class)
