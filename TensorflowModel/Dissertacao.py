#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 29 13:10:45 2024

@author: jonathan
"""


import datetime
from keras import models, layers
import tensorflow as tf
from keras.callbacks import CSVLogger
from keras.optimizers import Adam
from keras.regularizers import l2

datestr= datetime.datetime.now().strftime('%Y%m%d')




#--------------------------------

BASE_MODEL='ConvNeXtXLarge'
MODELS=['ConvNeXtXLarge']
#MODELS=["MobileNet","MobileNetV2","VGG16","VGG19","RESNET50","RESNET52","RESNET101","RESNET101V2","RESNET152","RESNET152V2","InceptionV3","Xception",'DenseNet169', 'DenseNet121','DenseNet201',"InceptionResNetV2",\
#                   "NASNetMobile","NASNetLarge","EfficientNetB0","EfficientNetB1","EfficientNetB2","EfficientNetB3","EfficientNetB4","EfficientNetB5","EfficientNetB6","EfficientNetB7",\
#                   "EfficientNetV2B0","EfficientNetV2B1","EfficientNetV2B2","EfficientNetV2B3","EfficientNetV2_S","EfficientNetV2_M","EfficientNetV2_L",\
#                   "ConvNeXtTiny","ConvNeXtSmall","ConvNeXtBase","ConvNeXtLarge","ConvNeXtXLarge"]

RESOLUTION=224 #default
IMG_SIZE = (RESOLUTION, RESOLUTION) # [(224, 224), (384, 384), (512, 512), (640, 640)]
BATCH_SIZE = 64 # [1, 8, 16, 24]
GAUSSIAN_NOISE = 0.05
DROPOUT = 0.25
DENSE_COUNT = 256
LEARN_RATE = 0.0001
EPOCHS = 200
CLASSES=['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']

TUNNING=False

if (TUNNING):
    AUTOTUNE = tf.data.AUTOTUNE


for BASE_MODEL in MODELS:
    with open("./dataset/"+BASE_MODEL+'_'+datestr+'_SkinLesion_stats.csv', 'w') as file:

        if BASE_MODEL == 'MobileNetV2':
            from keras.applications.mobilenet_v2 import MobileNetV2 as Model
        elif BASE_MODEL=='MobileNet':
            from keras.applications.mobilenet import MobileNet as Model
        elif BASE_MODEL=='VGG16':
            from keras.applications.vgg16 import VGG16 as Model
        elif BASE_MODEL=='VGG19':
            from keras.applications.vgg19 import VGG19 as Model
        elif BASE_MODEL=='RESNET50':
            from keras.applications.resnet import ResNet50 as Model
        elif BASE_MODEL=='RESNET52':
            from keras.applications.resnet_v2 import ResNet50V2 as Model
        elif BASE_MODEL=='RESNET101':
            from keras.applications.resnet import ResNet101 as Model
        elif BASE_MODEL=='RESNET101V2':
            from keras.applications.resnet_v2 import ResNet101V2 as Model
        elif BASE_MODEL=='RESNET152':
            from keras.applications.resnet import ResNet152 as Model
        elif BASE_MODEL=='RESNET152V2':
            from keras.applications.resnet_v2 import ResNet152V2 as Model
        elif BASE_MODEL=='InceptionV3':
            from keras.applications.inception_v3 import InceptionV3 as Model
        elif BASE_MODEL=='Xception':
            from keras.applications.xception import Xception as Model
            RESOLUTION=299
        elif BASE_MODEL=='DenseNet169':
            RESOLUTION=224
            from keras.applications.densenet import DenseNet169 as Model
        elif BASE_MODEL=='DenseNet121':
            RESOLUTION=224
            from keras.applications.densenet import DenseNet121 as Model
        elif BASE_MODEL=='DenseNet201':
            RESOLUTION=224
            from keras.applications.densenet import DenseNet201 as Model
        elif BASE_MODEL=='InceptionResNetV2':
            from keras.applications.inception_resnet_v2 import InceptionResNetV2 as Model
        elif BASE_MODEL=='NASNetMobile':
            from keras.applications.nasnet import NASNetMobile as Model
        elif BASE_MODEL=='NASNetLarge':
            from keras.applications.nasnet import NASNetLarge as Model
            RESOLUTION=331
        elif BASE_MODEL=='EfficientNetB0':
            from keras.applications.efficientnet import EfficientNetB0 as Model
        elif BASE_MODEL=='EfficientNetB1':
            from keras.applications.efficientnet import EfficientNetB1 as Model
            RESOLUTION=240
        elif BASE_MODEL=='EfficientNetB2':
            from keras.applications.efficientnet import EfficientNetB2 as Model
            RESOLUTION=260
        elif BASE_MODEL=='EfficientNetB3':
            from keras.applications.efficientnet import EfficientNetB3 as Model
            RESOLUTION=300
        elif BASE_MODEL=='EfficientNetB4':
            from keras.applications.efficientnet import EfficientNetB4 as Model
            RESOLUTION=380
        elif BASE_MODEL=='EfficientNetB5':
            from keras.applications.efficientnet import EfficientNetB5 as Model
            RESOLUTION=456
        elif BASE_MODEL=='EfficientNetB6':
            from keras.applications.efficientnet import EfficientNetB6 as Model
            RESOLUTION=528
        elif BASE_MODEL=='EfficientNetB7':
            from keras.applications.efficientnet import EfficientNetB7 as Model
            RESOLUTION=600
        elif BASE_MODEL=='EfficientNetV2_B0':
            from keras.applications.efficientnet_v2 import EfficientNetV2B0 as Model
        elif BASE_MODEL=='EfficientNetV2_B1':
            from keras.applications.efficientnet_v2 import EfficientNetV2B1 as Model
            RESOLUTION=240
        elif BASE_MODEL=='EfficientNetV2_B2':
            from keras.applications.efficientnet_v2 import EfficientNetV2B2 as Model
            RESOLUTION=260
        elif BASE_MODEL=='EfficientNetV2_B3':
            from keras.applications.efficientnet_v2 import EfficientNetV2B3 as Model
            RESOLUTION=300
        elif BASE_MODEL=='EfficientNetV2_S':
            from keras.applications.efficientnet_v2 import EfficientNetV2S as Model
            RESOLUTION=300
        elif BASE_MODEL=='EfficientNetV2_M':
            from keras.applications.efficientnet_v2 import EfficientNetV2M as Model
            RESOLUTION=380
        elif BASE_MODEL=='EfficientNetV2_L':
            RESOLUTION=380
            from keras.applications.efficientnet_v2 import EfficientNetV2L as Model
        elif BASE_MODEL=='ConvNeXtTiny':
            RESOLUTION=224
            from keras.applications.convnext import ConvNeXtTiny as Model
        elif BASE_MODEL=='ConvNeXtSmall':
            RESOLUTION=384
            from keras.applications.convnext import ConvNeXtSmall as Model
        elif BASE_MODEL=='ConvNeXtBase':
            RESOLUTION=384
            from keras.applications.convnext import ConvNeXtBase as Model
        elif BASE_MODEL=='ConvNeXtLarge':
            RESOLUTION=384
            from keras.applications.convnext import ConvNeXtLarge as Model
        elif BASE_MODEL=='ConvNeXtXLarge':
            RESOLUTION=384
            from keras.applications.convnext import ConvNeXtXLarge as Model
        else:
            raise ValueError('Unknown model: {}'.format(BASE_MODEL))

        IMG_SIZE = (RESOLUTION, RESOLUTION)

        csv_logger = CSVLogger("./dataset/"+BASE_MODEL+"_"+datestr+"_KerasMel_pd_data10000.csv", append=True)
        

        train_ds =tf.keras.utils.image_dataset_from_directory('./dataset/train/',
                                                               labels='inferred',
                                                               label_mode='int',
                                                               class_names=CLASSES,
                                                               color_mode='rgb',
                                                               batch_size=BATCH_SIZE,
                                                               image_size=IMG_SIZE)
        valid_ds =tf.keras.utils.image_dataset_from_directory('./dataset/valid/',
                                                       labels='inferred',
                                                       label_mode='int',
                                                       class_names=CLASSES,
                                                       color_mode='rgb',
                                                       batch_size=BATCH_SIZE,
                                                       image_size=IMG_SIZE)

        if (TUNNING):
            train_ds = train_ds.cache().prefetch(buffer_size=AUTOTUNE)
            valid_ds = valid_ds.cache().prefetch(buffer_size=AUTOTUNE)
        #MODEL
        
        base_pretrained_model = Model(input_shape =  (RESOLUTION, RESOLUTION, 3),
                                      include_top = False, weights = 'imagenet')
        base_pretrained_model.trainable = False

       
        #Model layers:
       
        X = layers.Input((RESOLUTION, RESOLUTION, 3), name='image_rgb_in')
        Y = layers.GaussianNoise(GAUSSIAN_NOISE)(X)
        Y = base_pretrained_model(Y)
        Y = layers.BatchNormalization()(Y)
        Y = layers.Flatten()(Y)
        Y = layers.Dropout(DROPOUT)(Y)

        Y = layers.Dropout(DROPOUT)(layers.Dense(DENSE_COUNT, activation = 'relu',kernel_regularizer=l2(0.01))(Y))
        Y = layers.Dense(len(CLASSES), activation = 'softmax')(Y)

        Model = models.Model(inputs = X, outputs = Y, name = 'full_model')

        

        optimizer = Adam(learning_rate=LEARN_RATE)
        Model.compile(optimizer,
                           loss = 'sparse_categorical_crossentropy',
                           metrics = ['sparse_categorical_accuracy'])

        Model.summary()

        #CALLBACKS

        from keras.callbacks import ModelCheckpoint, EarlyStopping, ReduceLROnPlateau
        from IPython.display import clear_output

        
        weight_path="./dataset/"+BASE_MODEL+"_"+"{}.keras".format('skin_cancer_detector')
        checkpoint = ModelCheckpoint(weight_path, monitor='val_sparse_categorical_accuracy', verbose=1,
                                     save_best_only=True, mode='max')

        reduceLROnPlat =  ReduceLROnPlateau(monitor='val_sparse_categorical_accuracy', factor=0.2, patience=10, verbose=1, mode='auto', min_delta=0.0001, cooldown=5, min_lr=0.000001)
        early = EarlyStopping(monitor="val_sparse_categorical_accuracy",
                              mode="max",
                              patience=20)
        log_dir = "./logs/" +BASE_MODEL+"_" +datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        tensorboard_callback = tf.keras.callbacks.TensorBoard(
            log_dir=log_dir,
            histogram_freq=1)

        callbacks_list = [checkpoint, early, reduceLROnPlat,csv_logger, tensorboard_callback]

        train_ds.batch_size = BATCH_SIZE

        fit_results = Model.fit(train_ds,
                              validation_data=valid_ds,
                              epochs = EPOCHS,
                              callbacks = callbacks_list)
        clear_output();

        file.write(f"model: {BASE_MODEL}, loss: {fit_results.history['loss']}, val_loss:{fit_results.history['val_loss']}, Training: {fit_results.history['sparse_categorical_accuracy']}, validation: {fit_results.history['val_sparse_categorical_accuracy']};\n")
