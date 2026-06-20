%% ========================================================================
%  SISO CP-OTFS Transmitter - Continuous Mode 
%  ========================================================================
clear; clc; close all;

params = OTFS_define_params(); 
data_info_bit = OTFS_generate_data_bits(params); 

% Modülasyon ve Grid Oluşturma
x = qammod(data_info_bit, params.M_mod, 'InputType', 'bit', 'UnitAveragePower', true);
x_DD = zeros(params.N, params.M);
x_DD(:, params.Mz + 1 : params.Mz + params.Md) = reshape(x, params.N, params.Md);
x_DD(params.np, params.Mz + params.Md + params.mp) = params.pilotValue;

% Zaman Sinyali
s_otfs = OTFS_modulation(params.N, params.M, x_DD);
cp = s_otfs(end - params.Ncp + 1 : end);
cpOtfsFrame = [cp; s_otfs];

% Frame Yapısı: [Pre | ZP | Frame | Frame]
TxWave = [params.preamble; zeros(params.Nzp, 1); cpOtfsFrame; cpOtfsFrame];
TxWave = TxWave / max(abs(TxWave)) * 0.7; % Peak power scaling

%% ====================== USRP Transmission ==============================
connectedRadios = findsdru;
radio = comm.SDRuTransmitter('Platform', 'B200', ...
    'SerialNum', '31C47B7', ...
    'MasterClockRate', params.MasterClockRate, ...
    'CenterFrequency', params.rfTxFreq, ...
    'Gain', 60, ...
    'InterpolationFactor', params.MasterClockRate / params.Fs);

fprintf('Yayın başladı... Durdurmak için Ctrl+C\n');

try
    while true
        % Kesintisiz gönderim için pause kaldırıldı
        step(radio, TxWave); 
    end
catch
    release(radio);
    fprintf('Yayın durduruldu.\n');
end