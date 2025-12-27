function dataOut = preprocessData(dataIn, targetSize)
    % dataIn: {Görüntü, Etiket} hücresi
    img = dataIn{1}; 
    lbl = dataIn{2}; 
    
    % 1. Boyutlandır
    img = imresize(img, targetSize(1:2));
    
    % 2. Kanal Kontrolü (Siyah beyazsa renkliye çevir)
    if size(img,3) == 1
        img = repmat(img, 1, 1, 3);
    end
    
    % 3. Single formatı (0-1 Normalize - Modelin başarısı için önemli)
    img = im2single(img);
    
    dataOut = {img, lbl};
end