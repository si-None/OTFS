%% ========================================================================
%  SISO CP-OTFS Receiver - Fine-Timing & Phase Lock 
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
radio = comm.SDRuReceiver('Platform', connectedRadios(1).Platform, ...
    'SerialNum', connectedRadios(1).SerialNum, ...
    'MasterClockRate', MasterClockRate, 'CenterFrequency', rfTxFreq, ...
    'Gain', 50, 'DecimationFactor', MasterClockRate / Fs, ...
    'SamplesPerFrame', 4 * unitFrame, 'OutputDataType', 'double');
radio.EnableBurstMode = true; radio.NumFramesInBurst = 1;

%% ====================== Sayaçlar =======================================
matchedFilter = conj(preamble(end:-1:1));
halfLen = floor(pLen / 2);
preamble_h1 = preamble(1:halfLen);
preamble_h2 = preamble(halfLen+1:2*halfLen);

rxCount = 0; validCount = 0; totalBitErrors = 0; totalBits = 0;
berHistory = []; hFig = figure('Name', 'OTFS Precision RX', 'Position', [100 100 1200 800]);

while true
    [rxSig, len, ~] = radio();
    if len <= 0, continue; end
    rxCount = rxCount + 1;
    
    % 1. Kaba Senkronizasyon (Matched Filter)
    mfOut = abs(conv(rxSig, matchedFilter));
    [maxMF, bestPeak] = max(mfOut(1:length(rxSig)));
    if maxMF < 0.20 * max(abs(rxSig)) * pLen, continue; end 
    
    % 2. CFO Tahmini ve Düzeltme
    preambleStart = bestPeak - pLen + 1;
    if preambleStart < 1 || bestPeak > length(rxSig), continue; end
    rxPreamble = rxSig(preambleStart:bestPeak);
    phaseDiff = angle(sum(rxPreamble(halfLen+1:2*halfLen) .* conj(preamble_h2)) * ...
                conj(sum(rxPreamble(1:halfLen) .* conj(preamble_h1))));
    cfo_est = phaseDiff * Fs / (2 * pi * halfLen);
    t_vec = (0:length(rxSig)-1).' / Fs;
    rxSig_corr = rxSig .* exp(-1j * 2 * pi * cfo_est * t_vec);

    % 3. Fine-Timing Search (Zamanlama Kaymasını Bitirir)
    % Pilotun en güçlü olduğu noktayı ±3 sample aralığında arıyoruz
    best_y = []; best_h = 0; min_err = inf;
    search_range = -3:3; 
    
    for offset = search_range
        frameStart = bestPeak + params.Nzp + 1 + offset;
        if frameStart + cpOtfsLen - 1 > length(rxSig_corr), continue; end
        
        tempOTFS = rxSig_corr(frameStart + Ncp : frameStart + cpOtfsLen - 1);
        temp_y = OTFS_demodulation(N, M, tempOTFS); 
        
        % Pilot gücüne bak
        p_rx = temp_y(params.np, params.Mz + params.Md + params.mp);
        if abs(p_rx) > best_h
            best_h = abs(p_rx);
            best_y = temp_y;
        end
    end
    
    if isempty(best_y), continue; end
    
    % 4. Faz Kilitleme 
    % Pilotun anlık fazını bul ve tüm gridi o kadar döndür
    pilot_rx = best_y(params.np, params.Mz + params.Md + params.mp);
    h_est = pilot_rx / pilotValue;
    
    % ZF Eşitleme + Faz Düzeltme
    y_eq = best_y / h_est; 
    
    % 5. Veri ve BER
    x_est = y_eq(1:N, 1+Mz : Md+Mz);
    xr = reshape(x_est, [], 1);
    data_est_bit = qamdemod(xr, M_mod, 'OutputType', 'bit', 'UnitAveragePower', true);
    
    bitErrors = sum(xor(data_est_bit, data_info_bit));
    validCount = validCount + 1;
    totalBitErrors = totalBitErrors + bitErrors;
    totalBits = totalBits + N_bits_perfram;
    totalBER = totalBitErrors / totalBits; 
    berHistory(end+1) = bitErrors / N_bits_perfram;

    % Görselleştirme 
    if mod(validCount, 1) == 0 && isvalid(hFig)
        subplot(2,1,1); plot(xr, 'r.'); 
        hold on;
        ref = qammod((0:M_mod-1)', M_mod, 'UnitAveragePower', true);
        plot(ref, 'ko', 'LineWidth', 2);
        hold off;
        title(['Constellation | TotBER: ' num2str(totalBER, '%.3e')]);
        grid on; 
        axis([-2 2 -2 2]); 
        axis equal;
        
        subplot(2,1,2);
        plot(berHistory, 'b'); 
        title('BER Peak Kontrolü');
        grid on;
        ylim([0 0.15]); 
        drawnow;
    end
end