clear;
close all;

%% Group number 3
p = 0;

%% Surnames (in reverse alphabetic order): Khan, Danish, Ahmed
x = length('Khan');
y = length('Danish');

%% Calculate filter order (N) and number of bits (nb)
N = 2^0 * mod(x, 2 + 1) + 6 * 0;
nb = mod(y, 7) + 8;

%% Implement the filter

fs=10000;                               % sampling frequency
f1=500;                                 % first sinewave freq (in band)
f2=4500;                                % second sinnewave freq (out band)

T=1/500;                                % maximum period
tt=0:1/fs:10*T;                         % time samples

x1=sin(2*pi*f1*tt);                     % first sinewave
x2=sin(2*pi*f2*tt);                     % second sinewave

x=(x1+x2)/2;                            % input signal

[bi, ai, bq, aq]=myiir_design(N, nb)   % filter design

y=filter(bq, aq, x);                    % apply filter

%% calculate thd of the result y

thd_value = thd(y);
disp(['THD of the output signal: ' num2str(thd_value) ' dB']);

%% plots
figure
plot(tt,x1,'--d');
hold on
plot(tt,x2,'r--s');
plot(tt,x, 'g--+');
plot(tt, y, 'c--o');

legend('x1', 'x2', 'x', 'y')

%% quantize input and output
xq=floor(x*2^(nb-1));
idx=find(xq==2^(nb-1));
xq(idx)=2^(nb-1)-1;

yq=floor(y*2^(nb-1));
idy=find(yq==2^(nb-1));
yq(idy)=2^(nb-1)-1;

%% save input and output
fp=fopen('samples.txt','w');
fprintf(fp,'%d\n', xq);
fclose(fp);

fp=fopen('resultsm.txt', 'w');
fprintf(fp, '%d\n', yq);
fclose(fp);
