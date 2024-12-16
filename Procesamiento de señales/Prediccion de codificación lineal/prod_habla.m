clear all
close all
clc

[audio, Fs] = audioread('aaaooo.wav');
info = audioinfo('aaaooo.wav');
t = 0:seconds(1/Fs):seconds(info.Duration);
t = t(1:end-1);

%longitud de la ventana
L = 1024;
%numero de puntos de la DFT
N = 2048;

%grafico de la señal de audio
hold on
figure(1)
plot(t,audio)
title('Señal de audio en funcion del tiempo')
xlabel('Tiempo')
ylabel('Señal de audio')
hold off

%espectrograma de la señal
hold on
figure(2)
nexttile
specgram(audio,[], Fs)
ylabel('Frecuency (Hz)')
title('Espectrograma de la señal con valores de default')
nexttile
specgram(audio,N,Fs, rectwin(L))
ylabel('Frecuency (Hz)')
title('Espectrograma de la señal con parametros modificados')
hold off
%-------------------------------------------------------------------------%
%creacion de ruido blanco
uwn = rand(250000,1);
audiowrite('white_noise_uniform2.wav',uwn,Fs)
[wn, wn_fs] = audioread('white_noise_uniform2.wav');
info2 = audioinfo('white_noise_uniform2.wav');
L = info2.TotalSamples;
T = 1/Fs;
t = (0:L-1)*T;

hold on
figure(3)
plot(xcorr(wn-0.5,'coeff'))
title('Autocorrelacion del ruido blanco');
xlabel('Numero de muestra [n]')
ylabel('Autocorrelacion')
hold off

%calculo de la ecuacion en diferencias: y[n] = x[n] + 0.75y[n-1]
%H()
b = 1;
a = [1 -0.75];
[h,w] = freqz(b,a);
hold on
figure(4)
plot(w/(2*pi),20*log10(abs(h)))
title('Respuesta en frecuencia del filtro')
xlabel('Frecuencia (Hz)')
ylabel('Magnitud (dB)');
hold off

fourier_wn = fft(wn-0.5);
fourier_output = fft(filter(b,a,wn-0.5));
in_P2 = abs(fourier_wn/L);
in_P1 = in_P2(1:L/2+1);
in_P1(2:end-1) = 2*in_P1(2:end-1);

out_P2 = abs(fourier_output/L);
out_P1 = out_P2(1:L/2+1);
out_P1(2:end-1) = 2*out_P1(2:end-1);


f = Fs*(0:(L/2))/L;


hold on
figure(5)
nexttile
plot(f,in_P1);
title('Espectro del ruido blanco de entrada');
ylabel('Magnitud (dB)');
xlabel('Frecuencia (Hz)');
nexttile
plot(f,out_P1);
title('Espectro ruido blanco filtrado');
ylabel('Magnitud (dB)');
xlabel('Frecuencia (Hz)');
hold off
%creacion ruido blanco filtrado
audiowrite('white_noise_filter_uniform.wav',filter(b,a,wn-0.5), Fs);


%-------------------------------------------------------------------------%

[fantasia, fan_fs] = audioread('fantasia.wav');
info3 = audioinfo('fantasia.wav');
t2 = 0:seconds(1/Fs):seconds(info3.Duration);
t2 = t2(1:end-1);
%tiempo = seconds(t2);

hold on
figure(6)
subplot(3,2,1)
plot(t2(6392:8780),fantasia(6392:8780))
title('Fonema /f/')
subplot(3,2,2)
plot(t2(9031:12574),fantasia(9031:12574))
title('Fonema /a/')
subplot(3,2,4)
plot(t2(12922:16397),fantasia(12922:16397))
title('Fonema /n/')
subplot(3,2,3)
plot(t2(18221:18970),fantasia(18221:18970))
title('Fonema /t/')
subplot(3,2,5)
plot(t2(23670:30018),fantasia(23670:30018))
title('Fonema /s/')
subplot(3,2,6)
plot(t2(30017:36778),fantasia(30017:36778))
title('Fonema /i/')
hold off


hold on
figure(8)
subplot(3,2,1)
plot(abs(fft(fantasia(6392:8780))))
title('Espectro del Fonema /f/')
subplot(3,2,2)
plot(abs(fft(fantasia(9031:12574))))
title('Espectro del Fonema /a/')
subplot(3,2,4)
plot(abs(fft(fantasia(12922:16397))))
title('Espectro del Fonema /n/')
subplot(3,2,3)
plot(abs(fft(fantasia(18221:18970))))
title('Espectro del Fonema /t/')
subplot(3,2,5)
plot(abs(fft(fantasia(23670:30018))))
title('Espectro del Fonema /s/')
subplot(3,2,6)
plot(abs(fft(fantasia(30017:36778))))
title('Espectro del Fonema /i/')
hold off


hold on 
figure(7)
subplot(2,1,1)
plot(t2, fantasia)
title('Señal de audio en funcion del tiempo')
xlabel('Tiempo')
ylabel('Señal de audio')
subplot(2,1,2)
specgram(fantasia,1024,Fs, rectwin(630))
ylabel('Frecuency (Hz)')
title('Espectrograma de la señal de audio')
hold off


%-------------------------------------------------------------------------%
