clc; clear; close all;

%% =========================
%   1) VERİYİ YÜKLE VE SEÇ
%% =========================
dataFolder = "C:\Users\hamza\Downloads\UTK\UTKFace"; 
fprintf("Proje başlatılıyor...\n");

imageFiles = dir(fullfile(dataFolder, "*.jpg"));
totalImages = numel(imageFiles);

% HIZ AYARI: CPU için 6000 resim seçiyoruz
targetCount = 6000; 
rng(1); 
if totalImages > targetCount
    randIdx = randperm(totalImages, targetCount);
    imageFiles = imageFiles(randIdx);
    fprintf("Hız için %d resim içinden rastgele %d tanesi seçildi.\n", totalImages, targetCount);
else
    fprintf("Toplam resim sayısı: %d\n", totalImages);
end

%% =========================
%   2) YAŞ ETİKETLERİNİ HAZIRLA
%% =========================
numFiles = numel(imageFiles);
ages = zeros(numFiles,1);
for i = 1:numFiles
    fname = imageFiles(i).name;
    parts = split(fname, "_");
    ages(i) = str2double(parts{1});
end

%% =========================
%   3) DATASTORE HAZIRLIĞI
%% =========================
trainCount = round(0.8 * numFiles);
idx = randperm(numFiles);
trainIdx = idx(1:trainCount);
testIdx  = idx(trainCount+1:end);
%%resimlerin adresteki yerlerini toplayıp bi liste yapılan kısım
%%full fill ile birleştirdi
trainFiles = fullfile({imageFiles(trainIdx).folder}, {imageFiles(trainIdx).name});
testFiles  = fullfile({imageFiles(testIdx).folder},  {imageFiles(testIdx).name});
YTrain = ages(trainIdx);
YTest  = ages(testIdx);

% --- Datastore ve Transform ---
inputSize = [96 96 3]; % 128px Kalite

% Combine işlemi
cdsTrain = combine(imageDatastore(trainFiles), arrayDatastore(YTrain));
cdsTest  = combine(imageDatastore(testFiles),  arrayDatastore(YTest));

% Transform 
dsTrain = transform(cdsTrain, @(x) preprocessData(x, inputSize));
dsTest  = transform(cdsTest,  @(x) preprocessData(x, inputSize));

fprintf("Veri hazırlığı tamamlandı. Eğitim başlıyor...\n");

%% =========================
%   4) CNN MODELİ (V2 - Derin)
%% =========================
layers = [
    imageInputLayer(inputSize)%%boyut 96x96 RGB
    
    convolution2dLayer(3, 32, "Padding", "same")%%same = görüntü boyutu korunur
    batchNormalizationLayer%% eğitimi hızlandırır ve kararlı hale getirir
    reluLayer%%doğrusal olmayan aktivitasyon fonk,karmaşık ilişkilerin öğrenilmesini sağlar.
    maxPooling2dLayer(2, "Stride", 2)%%boyut indirgeme ve önemli öz tutma
    
    convolution2dLayer(3, 64, "Padding", "same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, "Stride", 2)
    
    convolution2dLayer(3, 128, "Padding", "same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, "Stride", 2)
    
    convolution2dLayer(3, 256, "Padding", "same")
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(128)%%yüksek seviye özellikleri birleştirir
    reluLayer
    dropoutLayer(0.5)%%overfittingi önler yarısı rastgele kapatılır
    
    fullyConnectedLayer(1)%%tek değer çıkışı(yaş tahmini)
    regressionLayer%%çıkış katmanı MSE loss fonk kullanılır
];

%% =========================
%   5) EĞİTİMİ BAŞLAT
%% =========================
options = trainingOptions("adam", ...%%adaptif tahmin optimizasyonu
    "MaxEpochs", 15, ...%%tüm veri seti 15 kez işlenir
    "MiniBatchSize", 32, ...%%her adımda 32 görüntü işlenir
    "Shuffle", "every-epoch", ...%%her epochta veri karşılaştırılır
    "InitialLearnRate", 0.001, ...%%modelin her adımda hatadan ne kadar ders çıkarır.
    "ValidationData", dsTest, ...%%modelin genelleme yeteneği kontrol edilir
    "ValidationFrequency", 50, ...%% her 50 iterasyonda doğrulama
    "Plots", "training-progress", ...
    "Verbose", true);

trainedNet = trainNetwork(dsTrain, layers, options);%%eğitilmiş model ağırlıkları

%% =========================
%   6) SONUÇLARI KAYDET VE TEST ET
%% =========================
save('GelistirilmisModel_128px.mat', 'trainedNet', 'inputSize');
fprintf("Eğitim bitti ve model kaydedildi!\n");

% Örnek Test
idx2 = randi(numel(testFiles)); 
img = imread(testFiles{idx2});
processedImg = preprocessData({img, 0}, inputSize); % Fonksiyonu test için de kullanıyoruz
predAge = predict(trainedNet, processedImg{1});

figure; imshow(img);
title(sprintf("Gerçek: %d | Tahmin: %.1f", YTest(idx2), predAge));