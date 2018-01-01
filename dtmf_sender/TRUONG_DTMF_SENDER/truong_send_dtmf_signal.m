clear all; clc; close all;

%% User Settings
% input_str = 'Cong hoa xa hoi chu nghia Viet Nam. Doc lap tu do hanh phuc.';
% input_str = 'Cong hoa xa hoi chu nghia Viet Nam';
input_str = 'Xin chao';
% input_str = 'ABC';
ascii_list = double(input_str); % https://www.mathworks.com/matlabcentral/answers/298215-how-to-get-ascii-value-of-characters-stored-in-an-array
bits = [];
for i = 1:numel(ascii_list)
    bit = de2bi(ascii_list(i), 8, 'left-msb');
    bits = [bits bit];
end
% input = [1 1 0 0 0 1 0 0]; % input sequence ('*' = 10, '0' = 11, '#' = 12)
seq_header = [1 1 1 0 0 0 1 0 0 1 0]; % Barker code length 11
seq_end = [1 1 1 1 1 0 0 1 1 0 1 0 1]; % Barker code length 13
bits = [seq_header bits seq_end];
input = bits;



%% Parameters
toneDuration = .3; % minimum length of tone duration, sec
pauseDuration  = .2; % minimum length of pause between tones, sec
rowfreq = [697 770 852 941]; % row frequencies, Hz
colfreq = [1209 1336 1477 1633]; % column frequencies, Hz
Fs = 8e3; % sampling frequency, 8 kHz
nbits = 16; % 16-bit linear audio format
A = 1; % amplitude for lower frequency
B = 10^((20*log10(A)+2)/20); % amplitude for the higher frequency (2 dB louder)
pause = zeros(1,pauseDuration*Fs); % a vector that will be used to add pauses
y = [];

%% Input numbers
for k = 1:numel(input)
    % Determine the location of the button pressed: [row column]
    switch(input(k))
        case 0
            location = [4 2];
        case 1
            location = [1 1];
        case 2
            location = [1 2];
        case 3
            location = [1 3];
        case 4
            location = [2 1];
        case 5
            location = [2 2];
        case 6
            location = [2 3];
        case 7
            location = [3 1];
        case 8
            location = [3 2];
        case 9
            location = [3 3];
        case 10
            location = [4 1];
        case 11
            location = [4 3];
        otherwise
            error('There is an error in the input');
    end
    
    % Generate tone
    temp = generateTone(rowfreq(location(1)),Fs,toneDuration,A) + ...
        generateTone(colfreq(location(2)),Fs,toneDuration,B);
    y = [y temp pause]; % add new tone and pause to signal
    clear temp; % just in case    
end

% Scale output and convert to 16-bit linear audio
y = y./max(max(y),abs(min(y))); % scales y to be within +/- 1
y = int16(y.*32767); % converts the tone to a 16 bit signal
fprintf('Begin transmission \n');
sound_obj = audioplayer(y, Fs);
playblocking(sound_obj);
fprintf('End transmission \n');
