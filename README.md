# 🧒👵 Age Estimation with CNN (MATLAB)

Bu proje, insan yüzü görüntülerini analiz ederek kişinin yaşını tahmin eden derin öğrenme tabanlı bir **Konvolüsyonel Sinir Ağı (CNN)** uygulamasıdır. **MATLAB Deep Learning Toolbox** kullanılarak geliştirilmiştir.

Sınıflandırma (Classification) yerine **Regresyon (Regression)** modeli kullanılarak, yaş grupları değil, doğrudan **sayısal yaş değeri** tahmin edilmektedir.

---

## 📋 İçindekiler
- [Proje Özeti](#-proje-özeti)
- [Kullanılan Veri Seti](#-kullanılan-veri-seti)
- [Model Mimarisi](#-model-mimarisi)
- [Gereksinimler](#-gereksinimler)
- [Kurulum ve Kullanım](#-kurulum-ve-kullanım)
- [Sonuçlar](#-sonuçlar)

---

## 🚀 Proje Özeti
Bu çalışmada, ham piksel verilerinden yaş tahmini yapmak amacıyla özelleştirilmiş bir CNN mimarisi tasarlanmıştır.

* **Veri İşleme:** Büyük veri setlerini belleği yormadan işlemek için MATLAB'in `ImageDatastore` ve `ArrayDatastore` yapıları kullanılmıştır.
* **Hız Optimizasyonu:** Eğitim süreci için veri seti içerisinden rastgele örnekleme yapılarak (6000 görüntü) dinamik bir alt küme oluşturulur.
* **Ön İşleme (Preprocessing):** Görüntüler eğitim öncesinde 96x96 piksel boyutuna getirilerek modele verilir.

---

## 📂 Kullanılan Veri Seti
Projede **UTKFace** veri seti kullanılmıştır. Bu veri seti 0-116 yaş aralığında, farklı ırk ve cinsiyetlerden binlerce yüz görüntüsü içerir.

Veri setindeki dosya isimlendirme formatı şöyledir:
`[yaş]_[cinsiyet]_[ırk]_[tarih].jpg`

> **Örnek:** `25_1_0_20170110.jpg` -> Bu dosya isminden kişinin **25** yaşında olduğu otomatik olarak ayrıştırılır.

---

## 🧠 Model Mimarisi
Model, `dags` veya hazır ağlar (Transfer Learning) yerine, sıfırdan oluşturulmuş sıralı (sequential) bir yapıdır:

1.  **Giriş Katmanı:** 96x96x3 (RGB Görüntü)
2.  **Konvolüsyon Blokları (x4):**
    * Derinleştikçe artan filtre sayıları: **32 -> 64 -> 128 -> 256**
    * Her blokta: `Conv2d` -> `BatchNormalization` -> `ReLU` -> `MaxPooling` (Son blok hariç)
3.  **Tam Bağlantılı (Fully Connected) Katmanlar:**
    * 128 Nöronlu gizli katman + ReLU
    * **Dropout Layer (%50):** Aşırı öğrenmeyi (overfitting) engellemek için.
    * Çıkış Katmanı: 1 Nöron (Regresyon çıktısı).
4.  **Kayıp Fonksiyonu:** Mean Squared Error (MSE).

---

## 🛠 Gereksinimler
Bu projeyi çalıştırmak için aşağıdaki yazılımlara ihtiyacınız vardır:

* **MATLAB** (R2021a veya üzeri önerilir)
* **Deep Learning Toolbox**
* **Computer Vision Toolbox** (Ön işleme fonksiyonları için)

---

## 💻 Kurulum ve Kullanım

1.  **Projeyi İndirin:** Bu repoyu bilgisayarınıza klonlayın veya indirin.
2.  **Veri Setini İndirin:** [UTKFace veri setini](https://susanqq.github.io/UTKFace/) indirin.
3.  **Dosya Yolunu Ayarlayın:**
    `main.m` dosyasını açın ve aşağıdaki satırı kendi veri seti klasörünüze göre güncelleyin:
    ```matlab
    dataFolder = "C:\Dosya\Yolunuz\UTKFace"; 
    ```
4.  **Çalıştırın:**
    MATLAB editöründe `Run` butonuna basın veya komut satırına dosya adını yazın.

---

## 📊 Sonuçlar
Eğitim sonucunda model `GelistirilmisModel_128px.mat` olarak kaydedilir. Kodun sonunda test kümesinden rastgele bir resim seçilerek tahmin yapılır.

**Örnek Çıktı:**
```text
Veri hazırlığı tamamlandı. Eğitim başlıyor...
...
Eğitim bitti ve model kaydedildi!
Gerçek: 34 | Tahmin: 31.2
