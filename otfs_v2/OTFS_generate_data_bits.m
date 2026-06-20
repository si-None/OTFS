function data_info_bit = OTFS_generate_data_bits(params)
% OTFS_GENERATE_DATA_BITS İletilecek bitleri üretir (örnek mesaj).
%   params: OTFS_define_params'ten alınan yapı.
%   data_info_bit: N_bits_perfram uzunluğunda sütun vektör.

N_bits_perfram = params.N_bits_perfram;

% Örnek mesaj (vericideki ile aynı)
Message = 'Hello OTFS';
MessageLength = length(Message) + 5;  % Örn: "Hello OTFS 001\n"
MessageBitsLength = MessageLength * 7;
MessageNum = floor(N_bits_perfram / MessageBitsLength);

Mest = zeros(MessageNum * MessageLength, 1);
for i = 0:MessageNum - 1
    Mest(i * MessageLength + (1:MessageLength)) = ...
        sprintf('%s %03d\n', Message, i);
end
MessageBits = de2bi(Mest, 7, 'left-msb');

txBitStream = MessageBits(:);
% Tam çerçeve boyutuna tamamla veya kırp
txBitStream = [txBitStream; zeros(N_bits_perfram - length(txBitStream), 1)];
data_info_bit = txBitStream(1:N_bits_perfram);
end