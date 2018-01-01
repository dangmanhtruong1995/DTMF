clear;
clc

Fs = 8000;
recObj = audiorecorder(Fs,16,1);
time_to_record = 45; % In seconds
recordblocking(recObj, time_to_record);
received_signal = getaudiodata(recObj);

filter_order = 1000;
one_band = [[((2*696)/Fs) ((2*698)/Fs)] [((2*1208)/Fs) ((2*1210)/Fs)]];
one_dtmf_filter = fir1(filter_order, one_band);
zero_band = [[((2*940)/Fs) ((2*942)/Fs)] [((2*1335)/Fs) ((2*1337)/Fs)]];
zero_dtmf_filter = fir1(filter_order, zero_band);

zero_received = conv(received_signal, zero_dtmf_filter,'same');
one_received = conv(received_signal, one_dtmf_filter,'same');
subplot(2,1,1)
plot(zero_received)
hold on
[nstart_list, nstop_list] = dtmfcut(zero_received, Fs);
for i = 1 : length(nstart_list)
    nstart = nstart_list(i);
    nstop = nstop_list(i);      
    stem(nstart, zero_received(nstart), 'MarkerFaceColor','red');
    stem(nstop, zero_received(nstop), 'MarkerFaceColor', 'cyan'); 
    xx_tone = zero_received(nstart:nstop);  
    [row, col, energy_list] = decode_tone(xx_tone, Fs)
    % pause
end
'HIHIHEHE'
subplot(2,1,2)
plot(one_received)
hold on
[nstart_list, nstop_list] = dtmfcut(one_received, Fs);
for i = 1 : length(nstart_list)
    nstart = nstart_list(i);
    nstop = nstop_list(i);
    stem(nstart, one_received(nstart), 'MarkerFaceColor','red');
    stem(nstop, one_received(nstop), 'MarkerFaceColor', 'cyan'); 
    xx_tone = one_received(nstart:nstop);  
    [row, col, energy_list] = decode_tone(xx_tone, Fs)
    % pause
end

[nstart_list_zero, nstop_list_zero] = dtmfcut(zero_received, Fs);
[nstart_list_one, nstop_list_one] = dtmfcut(one_received, Fs);
idx_zero = 1;
idx_one = 1;
symbols = zeros(1, length(nstart_list_zero) + length(nstart_list_one));
symbol_pos = 1;
while 1
    if (idx_zero > length(nstart_list_zero)) && (idx_one > length(nstart_list_one))
        break;
    end
    if (idx_zero > length(nstart_list_zero)) && (idx_one <= length(nstart_list_one))
        while idx_one <= length(nstart_list_one)
            symbols(symbol_pos) = 1;
            symbol_pos = symbol_pos + 1;
            idx_one = idx_one + 1;
        end
        break;
    end
    if (idx_zero <= length(nstart_list_zero)) && (idx_one > length(nstart_list_one))
        while idx_zero <= length(nstart_list_zero)            
            symbols(symbol_pos) = 0;
            symbol_pos = symbol_pos + 1;
            idx_zero = idx_zero + 1;
        end
        break;
    end
    if nstart_list_zero(idx_zero) < nstart_list_one(idx_one)        
        symbols(symbol_pos) = 0;
        symbol_pos = symbol_pos + 1;
        idx_zero = idx_zero + 1;
    else   
        if nstart_list_one(idx_one) < nstart_list_zero(idx_zero)
            symbols(symbol_pos) = 1;
            symbol_pos = symbol_pos + 1;
            idx_one = idx_one + 1;            
        end
    end
end

% Find header and end sequence to extract data
seq_header = [1 1 1 0 0 0 1 0 0 1 0]; % Barker code length 11
seq_end = [1 1 1 1 1 0 0 1 1 0 1 0 1];
temp = symbols;
temp(temp == 0) = -1;
seq_header(seq_header == 0) = -1;
seq_end(seq_end == 0) = -1;
y = xcorr(seq_header, temp);
[m, ind] = max(y);
start_index = length(temp) - ind + 1;
z = xcorr(seq_end, temp);
[m, ind] = max(z);
end_index = length(temp) - ind + 1;
symbols = symbols(start_index + 11:end_index - 1);


digital_output = symbols;
total_num_of_bits = numel(digital_output);
total_num_of_characters = total_num_of_bits / 8;
first_idx = 0;
last_idx = 0;
output_str = '';
for i = 1:total_num_of_characters
    first_idx = last_idx + 1;
    last_idx = first_idx + 7;
    binary_repr = digital_output(first_idx:last_idx); 
    ascii_value = bi2de(binary_repr(:)', 'left-msb');  
    character = char(ascii_value);
    output_str = [output_str character];    
end
output_str
