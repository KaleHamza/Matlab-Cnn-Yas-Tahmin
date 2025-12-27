% ageDataStore.m 

classdef ageDataStore < matlab.io.Datastore & matlab.io.datastore.MiniBatchable
    properties
        ImageDatastore
        Labels
    end
    
    methods
        % KURUCU (Constructor)
        function self = ageDataStore(imds, labels)
            self.ImageDatastore = imds;
            self.Labels = labels;
            % Reset metodunu çağırarak Datastore'un başlangıç konumunu ayarla
            reset(self); 
        end
        
        % ZORUNLU METOD: Datastore'da daha fazla veri olup olmadığını kontrol eder
        function tf = hasdata(self)
            tf = hasdata(self.ImageDatastore);
        end
        
        % ZORUNLU METOD: Bir sonraki elemanı okur
        function [data, info] = read(self)
            [imgData, info] = read(self.ImageDatastore);
            
            % Etiketi oku (Datastore'daki mevcut index'i kullanarak)
            currentIdx = self.ImageDatastore.CurrentFileIndex;
            labelData = {self.Labels(currentIdx)}; 
            
            % Çıktıyı [Görüntü, Etiket] formatında birleştir
            data = [imgData, labelData];
        end
        
        % ZORUNLU METOD: Öğelerin toplam sayısını döndürür
        function n = numel(self) 
            n = numel(self.ImageDatastore);
        end
        
        % ZORUNLU METOD: Datastore'u başlangıç durumuna döndürür
        function reset(self)
            reset(self.ImageDatastore);
        end
        
        % ZORUNLU METOD: Datastore'u bölmeyi sağlar
        function self = subset(self, indices)
            self.ImageDatastore = subset(self.ImageDatastore, indices);
            self.Labels = self.Labels(indices);
        end
        
        % MiniBatchable Arayüzü İçin (trainNetwork gereksinimi):
        function [miniBatchData, info] = readNextBatch(self, batchSize)
            [imgDataCell, info] = readNextBatch(self.ImageDatastore, batchSize);
            
            % Etiketleri çek
            currentIdx = info.startIndex:info.endIndex;
            labelData = self.Labels(currentIdx);
            
            miniBatchData = {cat(4, imgDataCell{:}), labelData}; 
        end

        % EK ZORUNLU METOD: Parfor gibi paralel işlemlere hazırlar (Gerekli olmasa bile tanımlanmalıdır)
        function self = setupForParfor(self)
            self.ImageDatastore = setupForParfor(self.ImageDatastore);
        end

        % EK ZORUNLU METOD: Nesnenin kaydedilmesi için (Abstract hatası için kritik)
        function S = saveobj(self)
            S.ImageDatastore = self.ImageDatastore;
            S.Labels = self.Labels;
        end

        % EK ZORUNLU METOD: Nesnenin yüklenmesi için (Abstract hatası için kritik)
        function self = loadobj(S)
            self = ageDataStore(S.ImageDatastore, S.Labels);
        end
    end
end