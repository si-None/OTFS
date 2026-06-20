%% ========================================================================
%  SISO CP-OTFS Receiver - Constellation & BER Analysis
%  ========================================================================
clear; clc; close all;

params = OTFS_define_params(); 
N = params.N;
M = params.M;
Ncp = params.Ncp;
Mz = params.Mz;
Md = params.Md; 
Mp = params.Mp;
pilotValue = params.pilotValue; 
M_mod = params.M_mod;
N_bits_perfram = params.N_bits_perfram; 
preamble = params.preamble;
rfTxFreq = params.rfTxFreq;
Fs = params.Fs;
MasterClockRate = params.MasterClockRate;
cpOtfsLen = params.cpOtfsLen;
unitFrame = params.unitFrame;
pLen = length(preamble);

data_info_bit = OTFS_generate_data_bits(params); 

%% ====================== SDRu Ayarları ==================================
connectedRadios = findsdru;
if ~isempty(connectedRadios) && ~isempty(connectedRadios(1).Platform)
    rxPlat = connectedRadios(1).Platform; rxSerial = connectedRadios(1).SerialNum;
else
    rxPlat = 'B200'; rxSerial = '31C47B7'; 
end
radio = comm.SDRuReceiver('Platform', rxPlat, 'SerialNum', rxSerial, ...
    'MasterClockRate', MasterClockRate, 'CenterFrequency', rfTxFreq, ...
    'Gain', 50, 'DecimationFactor', MasterClockRate / Fs, ...  
    'SamplesPerFrame', 4 * unitFrame, 'OutputDataType', 'double');
radio.EnableBurstMode = true; radio.NumFramesInBurst = 1;

%% ====================== Değişkenler ve Sayaçlar ========================
matchedFilter = conj(preamble(end:-1:1));
halfLen = floor(pLen / 2);
preamble_h1 = preamble(1:halfLen);
preamble_h2 = preamble(halfLen+1:2*halfLen);

Target_Frames = 2000; % Hedeflenen Frame Sayısı
frameCount = 0;
snr_vec_dB = 0:5:40; 
total_bit_errors_awgn = zeros(size(snr_vec_dB)); 
total_bits_awgn = 0; 

% Donanım Toplam İstatistikleri
global_hw_errors = 0;
global_hw_bits = 0;

hFig = figure('Name', 'OTFS Performans Analizi', 'Position', [100 100 1200 500], 'Color', 'k');
set(hFig, 'InvertHardcopy', 'off'); 

fprintf('====== OTFS Veri Toplama Başlıyor (Hedef: %d Frame) ======\n', Target_Frames);

%% ====================== ANA DÖNGÜ ======================================
while frameCount < Target_Frames
    [rxSig, len, ~] = radio();
    if len <= 0, continue; end
    
    mfOut = abs(conv(rxSig, matchedFilter));
    [maxMF, bestPeak] = max(mfOut(1:length(rxSig)));
    if maxMF < 0.2 * max(abs(rxSig)) * pLen, continue; end 
    
    preambleStart = bestPeak - pLen + 1;
    if preambleStart < 1 || bestPeak > length(rxSig), continue; end
    rxPreamble = rxSig(preambleStart:bestPeak);
    phaseDiff = angle(sum(rxPreamble(halfLen+1:2*halfLen) .* conj(preamble_h2)) * ...
                conj(sum(rxPreamble(1:halfLen) .* conj(preamble_h1))));
    cfo_est = phaseDiff * Fs / (2 * pi * halfLen);
    t_vec = (0:length(rxSig)-1).' / Fs;
    rxSig_corr = rxSig .* exp(-1j * 2 * pi * cfo_est * t_vec);
    
    best_offset = 0; best_h = 0; 
    for offset = -3:3
        frameStart = bestPeak + params.Nzp + 1 + offset;
        if frameStart + cpOtfsLen - 1 > length(rxSig_corr), continue; end
        tempOTFS = rxSig_corr(frameStart + Ncp : frameStart + cpOtfsLen - 1);
        temp_y = OTFS_demodulation(N, M, tempOTFS); 
        p_rx = temp_y(params.np, params.Mz + params.Md + params.mp);
        if abs(p_rx) > best_h, best_h = abs(p_rx); best_offset = offset; end
    end
    if best_h == 0, continue; end
    
    frameStart = bestPeak + params.Nzp + 1 + best_offset;
    clean_tempOTFS = rxSig_corr(frameStart + Ncp : frameStart + cpOtfsLen - 1);
    
    %% --- BÖLÜM A: DONANIM İŞLEME VE TOPLAM BER ---
    clean_y = OTFS_demodulation(N, M, clean_tempOTFS); 
    h_est_hw = clean_y(params.np, params.Mz + params.Md + params.mp) / pilotValue;
    y_eq_hw = clean_y / h_est_hw;
    x_est_hw = y_eq_hw(1:N, 1+Mz : Md+Mz); 
    xr_hw = reshape(x_est_hw, [], 1);
    
    data_est_bit_hw = qamdemod(xr_hw, M_mod, 'OutputType', 'bit', 'UnitAveragePower', true);
    
    % İstatistik Güncelleme
    hw_bitErrors = sum(xor(data_est_bit_hw, data_info_bit));
    global_hw_errors = global_hw_errors + hw_bitErrors;
    global_hw_bits = global_hw_bits + N_bits_perfram;
    total_hw_ber = global_hw_errors / global_hw_bits; % Toplam BER
    
    frameCount = frameCount + 1; 
    
    %% --- BÖLÜM B: AWGN DÖNGÜSÜ (Şelale Grafiği) ---
    for snr_idx = 1:length(snr_vec_dB)
        noisy_tempOTFS = awgn(clean_tempOTFS, snr_vec_dB(snr_idx), 'measured');
        noisy_y = OTFS_demodulation(N, M, noisy_tempOTFS); 
        h_est_n = noisy_y(params.np, params.Mz + params.Md + params.mp) / pilotValue;
        y_eq_n = noisy_y / h_est_n;
        x_est_n = y_eq_n(1:N, 1+Mz : Md+Mz); 
        xr_n = reshape(x_est_n, [], 1);
        data_est_n = qamdemod(xr_n, M_mod, 'OutputType', 'bit', 'UnitAveragePower', true);
        total_bit_errors_awgn(snr_idx) = total_bit_errors_awgn(snr_idx) + sum(xor(data_est_n, data_info_bit));
    end
    total_bits_awgn = total_bits_awgn + N_bits_perfram;
    current_ber_curve = total_bit_errors_awgn / total_bits_awgn;
    
    %% --- BÖLÜM C: GÖRSELLEŞTİRME (Panel Üzerinde İstatistikler) ---
    if isvalid(hFig)
        % 1. Constellation
        subplot(1, 2, 1);
        plot(xr_hw, 'y.', 'MarkerSize', 6); hold on;
        ref = qammod((0:M_mod-1)', M_mod, 'UnitAveragePower', true);
        plot(ref, 'ro', 'LineWidth', 2); hold off;
        title(sprintf('Constellation Diagram\nAnlık BER: %.2e', hw_bitErrors/N_bits_perfram), 'Color', 'w');
        grid on; set(gca, 'Color', [0.1 0.1 0.1], 'XColor', 'w', 'YColor', 'w');
        axis([-2 2 -2 2]); axis equal;
        
        % 2. BER-SNR ve Toplam İstatistikler
        subplot(1, 2, 2);
        semilogy(snr_vec_dB, current_ber_curve, '-ys', 'LineWidth', 2, 'MarkerFaceColor', 'r');
        grid on; set(gca, 'Color', [0.1 0.1 0.1], 'XColor', 'w', 'YColor', 'w');
        % Ekranda Frame ve Toplam BER görünür.
        title(sprintf('BER-SNR | Frames: %d/%d\nToplam BER: %.3e', ...
            frameCount, Target_Frames, total_hw_ber), 'Color', 'w', 'FontSize', 12);
        xlabel('SNR (dB)', 'Color', 'w'); ylabel('BER', 'Color', 'w');
        ylim([1e-6 1]); xlim([0 40]); 
        
        drawnow;
    end
    fprintf('Frame[%03d/%03d] | Anlık BER: %.2e | Toplam BER: %.2e\n', ...
        frameCount, Target_Frames, hw_bitErrors/N_bits_perfram, total_hw_ber);
end

%% ====================== VERİ KAYIT VE FİNAL RAPORU =====================
fprintf('\n====== SİMÜLASYON TAMAMLANDI. RAPOR HAZIRLANIYOR... ======\n');

% Klasörleme
parent_dir = 'Received_Data'; if ~exist(parent_dir, 'dir'), mkdir(parent_dir); end
timestamp = datestr(now, 'dd.mm.yyyy_HH.MM');
folderName = fullfile(parent_dir, sprintf('OTFS_Sonuclar_%s', timestamp)); mkdir(folderName);

% Konsolda detaylı özet raporu
final_hw_ber = global_hw_errors / global_hw_bits;
fprintf('\n------------------------------------------------\n');
fprintf('GÖNDERİLEN TOPLAM BİT : %d\n', global_hw_bits);
fprintf('TOPLAM HATA SAYISI    : %d\n', global_hw_errors);
fprintf('TOPLANAN FRAME SAYISI : %d\n', frameCount);
fprintf('NİHAİ DONANIM BER     : %.3e\n', final_hw_ber);
fprintf('------------------------------------------------\n');

% TXT Raporu Yazımı
fid = fopen(fullfile(folderName, 'OTFS_Verileri.txt'), 'w');
fprintf(fid, '====== OTFS PERFORMANS RAPORU (%s) ======\n', timestamp);
fprintf(fid, 'Toplam Frame Sayisi   : %d\n', frameCount);
fprintf(fid, 'Gonderilen Toplam Bit : %d\n', global_hw_bits);
fprintf(fid, 'Toplam Hata Sayisi    : %d\n', global_hw_errors);
fprintf(fid, 'Toplam BER    : %.3e\n', final_hw_ber);
fprintf(fid, '\nSNR(dB)\tBER(AWGN Sweep)\n');
for i = 1:length(snr_vec_dB), fprintf(fid, '%d\t\t%.2e\n', snr_vec_dB(i), current_ber_curve(i)); end
fclose(fid);

% MAT ve PNG Kaydı
save(fullfile(folderName, 'OTFS_BER_Verileri.mat'), 'snr_vec_dB', 'current_ber_curve', 'Target_Frames', 'final_hw_ber');

if isvalid(hFig)
    drawnow;
    % getframe() sayesinde ekranda ne görüyorsan (yazılar dahil) resme işlenir
    f = getframe(hFig); 
    imwrite(f.cdata, fullfile(folderName, 'OTFS_BER_Grafik.png'));
    saveas(hFig, fullfile(folderName, 'OTFS_BER_Grafik.fig'));
end

fprintf('\nTüm sonuçlar "%s" klasörüne kaydedildi.\n', folderName);