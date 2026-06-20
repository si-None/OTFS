=================================================================
SISO CP-OTFS: GERÇEK ZAMANLI METİN AKTARIMI VE PERFORMANS ANALİZİ (CONSTELLATION & BER-SNR)
=================================================================

[TR]
AÇIKLAMA:
Bu proje, Yazılım Tanımlı Radyo (SDR - USRP B200) donanımları üzerinden gerçek zamanlı çalışan Tek Giriş Tek Çıkışlı (SISO) CP-OTFS tabanlı bir haberleşme sisteminin tam MATLAB uygulamasını içermektedir. Sistem, "Hello OTFS" gibi metin verilerinin Gecikme-Doppler (Delay-Doppler) domeninde paketlenerek sürekli iletimini ve alıcı tarafında fiziksel katman parametreleri (hassas senkronizasyon, faz kilitleme) kullanılarak analiz edilmesini sağlar. Çift hatlı alıcı mimarisi sayesinde hem anlık donanım verileri üzerinden hata analizi yapılmakta hem de yakalanan sinyale sentetik AWGN eklenerek sistemin teorik dayanıklılığı hesaplanmaktadır.

TEMEL İŞLEMLER VE ALGORİTMALAR:
1. Metin Verisi ve Paketleme: "Hello OTFS" mesajı bit dizisine dönüştürülür ve Delay-Doppler ızgarasındaki veri bölgelerine (Md) yerleştirilir.
2. Sürekli Donanım Yayını: Hazırlanan CP-OTFS çerçeveleri, USRP üzerinden kesintisiz bir döngüde iletilir.
3. Kaba ve Hassas Senkronizasyon (Fine-Timing): Zadoff-Chu dizisi ile yapılan kaba senkronizasyonun ardından, pilot sembolü enerjisi takip edilerek ±3 örneklemlik bir hassas zamanlama (fine-timing) düzeltmesi uygulanır.
4. Pilot Tabanlı Faz Kilitleme: Gecikme-Doppler ızgarasındaki özel pilot sembolü (np, mp) kullanılarak kanalın faz sapması hesaplanır ve Zero-Forcing (ZF) eşitlemesi ile faz kilidi sağlanır.
5. Şelale (Waterfall) Eğrisi Analizi: Donanımdan alınan veriler üzerinden BER hesaplanırken, eşzamanlı olarak sinyal üzerine sentetik gürültü eklenerek BER-SNR eğrisi gerçek zamanlı oluşturulur.
6. Otomatik Veri Kaydı: "Target_Frames" değerine ulaşıldığında sistem rapor (.txt), veri (.mat) ve grafik (.png) dosyalarını otomatik olarak kaydeder.

DOSYA YAPISI:
- otfs_tx.m: Ana verici betiği. Metin verisini hazırlar, DD ızgarasını oluşturur ve USRP üzerinden iletimi yönetir.
- otfs_rx.m: Ana alıcı betiği. Sinyali yakalar, hassas senkronizasyon yapar ve BER-SNR analizlerini görselleştirir.
- OTFS_define_params.m: Sistem boyutları, pilot yerleşimi ve SDR donanım parametrelerini içeren merkezi yapılandırma dosyası.
- OTFS_generate_data_bits.m: "Hello OTFS" mesajını bit dizisine dönüştüren veri üretim fonksiyonu.
- OTFS_modulation.m: ISFFT ve Heisenberg dönüşümleri ile modülasyonu gerçekleştirir.
- OTFS_demodulation.m: Wigner ve SFFT dönüşümleri ile demodülasyonu gerçekleştirir.

NOT:
"Target_Frames" değişkeni değiştirilerek analiz için gereken toplam Frame sayısı belirtilir. Belirtilen sayıya ulaşıldığında sistem veri kaydını tamamlar.


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

=================================================================
SISO CP-OTFS: REAL-TIME TEXT TRANSMISSION AND PERFORMANCE ANALYSIS (CONSTELLATION & BER-SNR)
=================================================================

[EN]
DESCRIPTION:
This project features a full MATLAB implementation of a Single-Input Single-Output (SISO) CP-OTFS communication system operating in real-time over Software Defined Radio (SDR - USRP B200) hardware. The system enables continuous transmission of text data, such as "Hello OTFS", mapped into the Delay-Doppler domain, and performs receiver-side analysis using physical layer parameters like fine-timing synchronization and phase locking. Utilizing a twin-pipeline receiver architecture, it evaluates error rates on live hardware data while simultaneously executing synthetic AWGN sweeps to validate theoretical performance.

CORE OPERATIONS AND ALGORITHMS:
1. Text Data & Packaging: The "Hello OTFS" message is converted into a bitstream and embedded into the data regions (Md) of the Delay-Doppler grid.
2. Continuous Hardware Streaming: Prepared CP-OTFS frames are broadcasted via the USRP in an infinite loop.
3. Coarse and Fine Synchronization (Fine-Timing): Following initial detection via Zadoff-Chu sequence, a fine-tuning search of ±3 samples is performed based on pilot symbol energy to minimize timing offsets.
4. Pilot-Based Phase Locking: Phase offset is estimated using a dedicated pilot symbol (np, mp) in the Delay-Doppler grid, followed by Zero-Forcing (ZF) equalization for phase locking.
5. Waterfall Curve Analysis: While calculating BER from live hardware data, synthetic noise is added to the signal in real-time to construct the BER-SNR waterfall curve.
6. Automatic Data Logging: Upon reaching the "Target_Frames" threshold, the system automatically exports analysis reports (.txt), data (.mat), and plots (.png).

FILE STRUCTURE:
- otfs_tx.m: Main transmitter script. Prepares text data, generates the DD grid, and manages continuous USRP transmission.
- otfs_rx.m: Main receiver script. Handles signal capture, fine-timing synchronization, and real-time BER-SNR visualization.
- OTFS_define_params.m: Central configuration file defining system dimensions, pilot positioning, and SDR hardware settings.
- OTFS_generate_data_bits.m: Data generation function that converts the "Hello OTFS" message into a bitstream.
- OTFS_modulation.m: Performs modulation utilizing ISFFT and Heisenberg transforms.
- OTFS_demodulation.m: Performs demodulation utilizing Wigner and SFFT transforms.

NOTE:
The "Target_Frames" variable specifies the total number of frames required for the analysis. The system automatically completes data logging once this threshold is met.