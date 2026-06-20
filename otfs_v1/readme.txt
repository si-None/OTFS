=================================================================
SISO CP-OTFS: GERÇEK ZAMANLI PERFORMANS ANALİZİ (CONSTELLATION & BER-SNR)
=================================================================

[TR]
AÇIKLAMA:
Bu proje, Yazılım Tanımlı Radyo (SDR - USRP B200) donanımları üzerinden gerçek zamanlı çalışan Tek Giriş Tek Çıkışlı (SISO) CP-OTFS (Orthogonal Time Frequency Space) tabanlı bir haberleşme sisteminin tam MATLAB uygulamasını içermektedir. Sistem, Gecikme-Doppler (Delay-Doppler) domeninde kanal kestirimi, hassas senkronizasyon ve faz kilitleme algoritmalarını kullanarak donanımın fiziksel katman performansını ölçmek üzere tasarlanmıştır. Gerçek donanım verileri üzerinden anlık Constellation (Takımyıldızı) ve Bit Hata Oranı (BER) grafikleri eşzamanlı olarak dinamik bir arayüz üzerinde takip edilebilmektedir.

TEMEL İŞLEMLER VE ALGORİTMALAR:
1. Kesintisiz Donanım İletimi: Verici betiği, USRP üzerinden CP-OTFS çerçevelerini fiziksel katman testleri için sürekli bir döngüde yayınlar.
2. Kaba ve Hassas Senkronizasyon (Fine-Timing): Alınan sinyalin başlangıcı Zadoff-Chu dizisi ile tespit edildikten sonra, pilot sembolü gücü üzerinden ±3 örneklemlik bir arama yapılarak zamanlama kaymaları (timing offset) minimize edilir.
3. CFO Düzeltme ve Faz Kilitleme: Preamble üzerinden Taşıyıcı Frekans Kayması (CFO) giderilir. Delay-Doppler ızgarasındaki pilot sembolü ile anlık faz sapmaları hesaplanarak Zero-Forcing (ZF) tabanlı faz kilitleme uygulanır.
4. Delay-Doppler Dönüşümleri: ISFFT ve Heisenberg dönüşümleri ile modülasyon; Wigner ve SFFT dönüşümleri ile demodülasyon işlemleri yapılarak sinyal Gecikme-Doppler domeninde analiz edilir.
5. Dinamik Performans İzleme: Donanımdan akan verinin kalitesi, gerçek zamanlı Constellation diyagramı ve zaman içindeki BER değişimi üzerinden anlık olarak gözlemlenir.

DOSYA YAPISI:
- otfs_tx.m: Ana verici betiği. Fiziksel katman testleri için DD ızgarasını hazırlar ve USRP üzerinden sürekli iletim sağlar.
- otfs_rx.m: Ana alıcı betiği. Sinyali yakalar, hassas zamanlama ve faz kilidini uygular, BER ve Constellation analizlerini görselleştirir.
- OTFS_define_params.m: Sistem boyutları, koruma bantları, pilot yerleşimi ve SDR donanım parametrelerini içeren merkezi yapılandırma dosyası.
- OTFS_modulation.m: Sembolleri Gecikme-Doppler domeninden zaman domenine taşıyan modülasyon motoru.
- OTFS_demodulation.m: Zaman domeni sinyalini analiz için tekrar Gecikme-Doppler domenine çeviren demodülasyon motoru.
- OTFS_generate_data_bits.m: Performans analizlerinde kullanılacak referans bit dizilerini üretir.


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

=================================================================
SISO CP-OTFS: REAL-TIME PERFORMANCE ANALYSIS (CONSTELLATION & BER-SNR)
=================================================================


[EN]
DESCRIPTION:
This project features a full MATLAB implementation of a Single-Input Single-Output (SISO) CP-OTFS (Orthogonal Time Frequency Space) communication system operating in real-time over Software Defined Radio (SDR - USRP B200) hardware. The system is specifically designed to evaluate physical layer performance using channel estimation, fine-timing synchronization, and phase locking algorithms in the Delay-Doppler domain. Real-time Constellation diagrams and Bit Error Rate (BER) metrics derived from live hardware data are monitored simultaneously on a dynamic interface.

CORE OPERATIONS AND ALGORITHMS:
1. Continuous Hardware Streaming: The transmitter script broadcasts CP-OTFS frames in a continuous loop via the USRP for physical layer validation.
2. Coarse and Fine Synchronization: After detecting the frame start with a Zadoff-Chu sequence, a fine-timing search of ±3 samples is conducted based on pilot power to minimize timing offsets.
3. CFO Correction and Phase Locking: Carrier Frequency Offset (CFO) is corrected via the preamble. Phase locking is achieved using Zero-Forcing (ZF) equalization based on the instantaneous phase of the pilot symbol in the Delay-Doppler grid.
4. Delay-Doppler Transforms: Modulation is performed using ISFFT and Heisenberg transforms, while demodulation utilizes Wigner and SFFT transforms to analyze the signal in the Delay-Doppler domain.
5. Dynamic Performance Monitoring: The quality of the live hardware stream is observed through real-time Constellation diagrams and temporal BER fluctuation tracking.

FILE STRUCTURE:
- otfs_tx.m: Main transmitter script. Prepares the DD grid for physical layer testing and manages continuous USRP transmission.
- otfs_rx.m: Main receiver script. Captures the signal, applies fine-timing and phase locking, and visualizes BER/Constellation analysis.
- OTFS_define_params.m: Central configuration file defining system dimensions, guard bands, pilot positioning, and SDR hardware settings.
- OTFS_modulation.m: The modulation engine that transforms symbols from the Delay-Doppler domain to the time domain.
- OTFS_demodulation.m: The demodulation engine that restores the received signal back to the Delay-Doppler domain for analysis.
- OTFS_generate_data_bits.m: Generates reference bitstreams used for performance evaluation.