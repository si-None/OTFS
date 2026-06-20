%% ========================================================================
%  SISO CP-OTFS Transmitter - Continuous Mode (V2.1)
%  ========================================================================
clear; clc; close all;

params = OTFS_define_params(); %[cite: 4]
data_info_bit = OTFS_generate_data_bits(params); %[cite: 6]

% Modülasyon ve Grid Oluşturma[cite: 3]
x = qammod(data_info_bit, params.M_mod, 'InputType', 'bit', 'UnitAveragePower', true);
x_DD = zeros(params.N, params.M);
x_DD(:, params.Mz + 1 : params.Mz + params.Md) = reshape(x, params.N, params.Md);
x_DD(params.np, params.Mz + params.Md + params.mp) = params.pilotValue;

% Zaman Sinyali[cite: 1]
s_otfs = OTFS_modulation(params.N, params.M, x_DD);
cp = s_otfs(end - params.Ncp + 1 : end);
cpOtfsFrame = [cp; s_otfs];

% Frame Yapısı: [Pre | ZP | Frame | Frame][cite: 3]
TxWave = [params.preamble; zeros(params.Nzp, 1); cpOtfsFrame; cpOtfsFrame];
TxWave = TxWave / max(abs(TxWave)) * 0.9; % Peak power scaling

%% ====================== USRP Transmission ==============================
connectedRadios = findsdru;
radio = comm.SDRuTransmitter('Platform', 'B200', ...
    'SerialNum', '31C47B7', ...
    'MasterClockRate', params.MasterClockRate, ...
    'CenterFrequency', params.rfTxFreq, ...
    'Gain', 50, ...
    'InterpolationFactor', params.MasterClockRate / params.Fs);

fprintf('Yayın başladı... Durdurmak için Ctrl+C\n');

try
    while true
        % Kesintisiz gönderim için pause kaldırıldı[cite: 3]
        step(radio, TxWave); 
    end
catch
    release(radio);
    fprintf('Yayın durduruldu.\n');
end