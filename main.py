import numpy as np
import pandas as pd
import tensorflow as tf
from numpy.random import seed
from sklearn import metrics
from sklearn import preprocessing
from sklearn.linear_model import Lasso
from sklearn.metrics import roc_curve, auc
from tensorflow import keras

np.random.seed(2095)

# read input file
#file = 'all_training8.xlsx'
#ipData = pd.read_excel(file, sheet_name='Sheet1')
file = 'dataset.xlsx'
ipData = pd.read_excel(file, sheet_name='Sheet1')
print(ipData.columns)


# data drop
opLabel = np.array(ipData['标签'])
ipData.drop(['病人', '标签'], axis=1, inplace=True)
# # 过采样
# smo = SMOTE(random_state=42)
# x_smo, y_smo = smo.fit_resample(ipData, opLabel)
# y_smo = pd.DataFrame({'target': y_smo})
# print(x_smo.shape)
# print(y_smo.shape)
# ipData = pd.concat([x_smo, y_smo],axis=1)
# opLabel = np.array(ipData['target'])
# ipData.drop(['target'], axis=1, inplace=True)

ipData = pd.get_dummies(ipData, columns=["病人", "标签"])
print(ipData)
varb = np.array(ipData.columns)
ipData = np.array(ipData)
print(ipData.shape)
print(len(opLabel[opLabel == 0]))
print(len(opLabel[opLabel == 1]))
num0 = int(len(opLabel[opLabel == 0]))
num1 = int(len(opLabel[opLabel == 1]))
featureVote = np.zeros(ipData.shape[1])
print(featureVote.shape)

trainRate = 0.8

iteR = 100
for num in range(iteR):
    label0_ind = np.where(opLabel == 0)[0]  # no coronary heart disease
    label1_ind = np.where(opLabel == 1)[0]  # coronary heart disease
    numTrainData0 = int(num0*trainRate)
    numTrainData1 = int(num1*trainRate)
    np.random.shuffle(label0_ind)
    np.random.shuffle(label1_ind)
    label0_ind_train = label0_ind[0:numTrainData0 - 1]
    label1_ind_train = label1_ind[0:numTrainData1 - 1]
    label0_ind_test = label0_ind[numTrainData0:]
    label1_ind_test = label1_ind[numTrainData1:]

    trainInd = np.append(label0_ind_train, label1_ind_train)
    trainData = ipData[trainInd]
    trainLabel = opLabel[trainInd]
    testInd = np.append(label0_ind_test, label1_ind_test)
    testData = ipData[testInd]
    testLabel = opLabel[testInd]

    # %% data standardization
    scaler = preprocessing.StandardScaler().fit(trainData)  # 用于计算训练数据的均值和方差， 后面就会用均值和方差来转换训练数据
    trainData_scaled = scaler.transform(trainData)          # 把训练数据转换成标准的正态分布
    testData_scaled = scaler.transform(testData)

    # %% Elastic net and Lasso from scikit
    reg = Lasso(random_state=0, alpha=0.006, tol=0.000001, max_iter=100000)
    """
    random_state：一个整数或者RandomState实例，也可能是None
    alpha:a值，其值越大说明正则化项的占比越大
    tol：一个浮点数，指定判断迭代收敛与否的阈值
    max_iter：指定最大的迭代次数，值为整数
    """
    reg.fit(trainData_scaled, trainLabel)
    cof = np.abs(reg.coef_)
    colInd = np.where(cof != 0)[0]
    for col in colInd:
        featureVote[col] += 1
print(featureVote)
score = reg.score(testData_scaled, testLabel)
print(score)

thresH = 0
print(testData_scaled.shape)
featureInd = np.where(featureVote[0:37] > thresH)[0]
featureInd = np.append(featureInd, np.arange(37, ipData.shape[1]))
print(featureInd)
print(varb[featureInd])

reduced_data = ipData[:, featureInd]

label0_ind = np.where(opLabel == 0)[0]  # no cardiac arrest
label1_ind = np.where(opLabel == 1)[0]  # cardiac arrest
numTrainData0 = int(num0*trainRate)
numTrainData1 = int(num1*trainRate)

np.random.shuffle(label0_ind)
np.random.shuffle(label1_ind)

label0_ind_train = label0_ind[0:numTrainData0]
label1_ind_train = label1_ind[0:numTrainData1]
label0_ind_test = label0_ind[numTrainData0:]
label1_ind_test = label1_ind[numTrainData1:]

testInd = np.append(label0_ind_test, label1_ind_test)
trainInd = np.append(label0_ind_train, label1_ind_train)
x_train = reduced_data[trainInd]
y_train = opLabel[trainInd]
x_test = reduced_data[testInd]
y_test = opLabel[testInd]
scaler = preprocessing.StandardScaler().fit(x_train)
x_train = scaler.transform(x_train)
x_test = scaler.transform(x_test)

# %% one-hot-encoding
y_train = tf.keras.utils.to_categorical(y_train, 2)
y_test = tf.keras.utils.to_categorical(y_test, 2)

inputs = tf.keras.layers.Input(shape=(x_train.shape[1], 1))
RS0 = tf.keras.layers.Reshape((x_train.shape[1], ))(inputs)
FC0 = tf.keras.layers.Dense(64, bias_initializer=keras.initializers.VarianceScaling())(RS0)
BN0 = tf.keras.layers.BatchNormalization(axis=-1)(FC0)
AC0 = tf.keras.layers.Activation('relu')(BN0)
DP0 = tf.keras.layers.Dropout(0.2)(AC0)

RS1 = tf.keras.layers.Reshape((64, 1))(DP0)
FC1 = tf.keras.layers.Conv1D(2, 3, strides=1)(RS1)
BN1 = tf.keras.layers.BatchNormalization(axis=-1)(FC1)
AC1 = tf.keras.layers.Activation('relu')(BN1)
Pool1 = tf.keras.layers.AveragePooling1D(pool_size=2)(AC1)

FC2 = tf.keras.layers.Conv1D(4, 5, strides=1)(Pool1)
BN2 = tf.keras.layers.BatchNormalization(axis=-1)(FC2)
AC2 = tf.keras.layers.Activation('relu')(BN2)
Pool2 = tf.keras.layers.AveragePooling1D(pool_size=2)(AC2)

FL1 = tf.keras.layers.Flatten()(Pool2)

FC3 = keras.layers.Dense(512, bias_initializer=keras.initializers.VarianceScaling())(FL1)
BN3 = keras.layers.BatchNormalization(axis=-1)(FC3)
AC3 = keras.layers.Activation('relu')(BN3)
DP3 = keras.layers.Dropout(0.2)(AC3)
FC4 = tf.keras.layers.Dense(2)(DP3)
outputs = tf.keras.layers.Activation('softmax')(FC4)

myCNN5D4 = tf.keras.Model(inputs=inputs, outputs=outputs)


myCNN5D4.compile(optimizer=tf.keras.optimizers.Adam(),
                 loss='categorical_crossentropy',
                 metrics=['accuracy'])

myCNN5D4.summary()

class_weight = {0: 1, 1: 2.0}


myCNN5D4.fit(x_train, y_train, batch_size=32, epochs=100, verbose=1, class_weight=class_weight, shuffle=1)
#history = myCNN5D4.fit(x_train, y_train, validation_data=(x_test, y_test), batch_size=32, epochs=100, class_weight=class_weight, verbose=1)
test_loss, test_acc = myCNN5D4.evaluate(x_test, y_test)
print(test_acc)
# # Get training and test loss histories
# training_loss = history.history['loss']
# test_loss = history.history['val_loss']
# training_acc = history.history['accuracy']
# test_acc = history.history['val_accuracy']
#
# # Create count of the number of epochs
# epoch_count = range(1, len(training_loss) + 1)
#
# # Visualize loss history
# plt.plot(epoch_count, training_loss, 'r--')
# plt.plot(epoch_count, test_loss, 'b-')
# plt.legend(['Training Loss', 'Test Loss'])
# plt.xlabel('Epoch')
# plt.ylabel('Loss')
# plt.show();
#
#
# # Create count of the number of epochs
# epoch_count = range(1, len(training_acc) + 1)
# # Visualize accuracy history
# plt.plot(epoch_count, training_acc, 'r--')
# plt.plot(epoch_count, test_acc, 'b-')
# plt.legend(['Training Accuracy', 'Test Accuracy'])
# plt.xlabel('Epoch')
# plt.ylabel('Accuracy')
# plt.show()

preLabel = myCNN5D4.predict(x_test)
f = np.argmax(preLabel, axis=1)
score = np.amax(preLabel, axis=1)
prediction_acc = metrics.accuracy_score(np.argmax(y_test, axis=1), f)
print(prediction_acc)
recall_score = metrics.recall_score(np.argmax(y_test, axis=1), f)               # 召回率
print("recall:", recall_score)
tn, fp, fn, tp = metrics.confusion_matrix(np.argmax(y_test, axis=1), f).ravel()
print("tn:", tn, "fp:", fp, "fn:", fn, "tp:", tp)
precision = tp/(tp+fp)
print("precision:", precision)
Specificity = tn/(tn+fp)
print("Specificity:", Specificity)



# confMat = metrics.confusion_matrix(np.argmax(y_test, axis=1), f)
# confMat[0][0] = tp
# confMat[0][1] = fn
# confMat[1][0] = fp
# confMat[1][1] = tn
# total_sum = confMat.sum()
# correct_sum = (np.diag(confMat)).sum()
# prediction_acc = round(100*float(correct_sum)/float(total_sum), 2)
# print(prediction_acc)
# plt.figure()
# plt.imshow(confMat, cmap=plt.cm.Blues)
# plt.colorbar()
# plt.title("混淆矩阵", fontdict={'weight': 'normal', 'size': '18'})
# plt.xlabel('预测值', fontdict={'weight': 'normal', 'size': '16'})
# plt.ylabel('真实值', fontdict={'weight': 'normal', 'size': '16'})
#
# classes = ['阳性', '阴性']
# tick_marks = np.arange(len(classes))
# plt.xticks(tick_marks, classes, fontsize=12)
# plt.yticks(tick_marks, classes, fontsize=12)
# plt.rcParams['font.sans-serif'] = ['SimHei']
# plt.rcParams['axes.unicode_minus'] = False
#
# normalize = False
# fmt = '.2f' if normalize else 'd'
# thresh = confMat.max() / 2.
# for i in range(len(confMat)):    # 第几行
#     for j in range(len(confMat[i])):    # 第几列
#         plt.text(j, i, format(confMat[i][j], fmt),
#         fontsize=16,  # 矩阵字体大小
#         horizontalalignment="center",  # 水平居中。
#         verticalalignment="center",  # 垂直居中。
#         color="white" if confMat[i, j] > thresh else "black")
# plt.show()
# print(confMat)

# # ROC曲线
fpr, tpr, thread = roc_curve(f, score)
roc_auc = auc(fpr, tpr)
print("AUC:", roc_auc)
#
# plt.figure()
# lw = 2
# plt.plot(fpr, tpr, color='darkorange',
#          lw=lw, label='ROC curve (area = %0.2f)' % roc_auc)
# plt.plot([0, 1], [0, 1], color='navy', lw=lw, linestyle='--')
# plt.xlim([0.0, 1.0])
# plt.ylim([0.0, 1.05])
# plt.xlabel('FPR')
# plt.ylabel('TPR')
# plt.title('ROC and AUC')
# plt.legend(loc="lower right")
# plt.show()

# t0 = time.time()
# t = time.time()-t0

