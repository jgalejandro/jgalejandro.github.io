clear all
close all
clc
[audio, Fs] = audioread('estaba_la.wav');
info = audioinfo('estaba_la.wav');
t = 0:seconds(1/Fs):seconds(info.Duration);
t = t(1:end-1);

step_25m = 1103;
step_10m = 441;

hold on
figure(1)
plot(t,audio)
title('Señal de audio en funcion del tiempo')
hold off

lpc_coeff = zeros(122,21);
largo_audio = size(audio);
%calculo de lpc
for x = 1:1:122
    lim_inferior = (x-1)*step_10m;
    lim_superior = lim_inferior + step_25m;
    if lim_superior > largo_audio(1)
        lim_superior = largo_audio(1);
    end
    lpc_coeff(x,:)= lpc(audio((lim_inferior+1:lim_superior),1),20);
end

%tomo la ventana que contiene la ultima 'a'
lpc_vocal = lpc_coeff(80,:);
%polos y ceros
a = 1;
b = [1 -1*lpc_vocal(2:21)];
[z,p,k] = tf2zpk(a,b);
hold on
figure(2)
zplane(z,p)
grid
title('Diagrama de polos y ceros para la vocal "a" ')
hold off

%calculo del error.
audio_error = zeros(122,1103);
error = zeros(1, largo_audio(1));
predicted_audio = zeros(1, largo_audio(1));
for z = 1:1:122
    lim_inferior = (z-1)*step_10m;
    lim_superior = lim_inferior + step_25m;
    lim_audio = 1103;
    if lim_superior > largo_audio(1)
        lim_superior = largo_audio(1);
        lim_audio = lim_superior-lim_inferior;
    end
    audio_error(z,1:lim_audio) = audio(lim_inferior+1:lim_superior)- filter([0 -lpc_coeff(z,2:end)],1,audio(lim_inferior+1:lim_superior));
    error(lim_inferior+1:lim_superior) = audio_error(z,1:lim_audio);
    predicted_audio(lim_inferior+1:lim_superior) = filter([0 -lpc_coeff(z,2:end)],1,audio(lim_inferior+1:lim_superior));
end

hold on
figure(3)
plot(t,error)
grid
xlabel('Tiempo')
ylabel('Error')
title('Error entre la señal original y la predecida mediante LPC')
hold off

%generacion del audio
audiowrite('signal_error.wav',error, 44100);
%comparaciones entre error obtenido y señal original
hold on
figure(4)
subplot(3,1,1)
plot(t,audio)
grid
title('Señal original')
subplot(3,1,3)
plot(t,error)
grid
title('Error estimado')
xlabel('Tiempo')
subplot(3,1,2)
plot(t,predicted_audio)
grid
title('Señal predicha')
hold off

hold on
figure(5)
subplot(2,3,1)
plot(t(988:4443), audio(988:4443))
title('Fonema /e/')
subplot(2,3,4)
plot(t(988:4443),error(988:4443))
subplot(2,3,2)
plot(t(5060:8627),audio(5060:8627))
title('Fonema /s/')
subplot(2,3,5)
plot(t(5060:8627), error(5060:8627))
subplot(2,3,3)
plot(t(14340:15140), audio(14340:15140))
title('Fonema /t/')
subplot(2,3,6)
plot(t(14340:15140), error(14340:15140))
hold off
hold on
figure(6)
subplot(2,3,1)
plot(t(15250:22770),audio(15250:22770))
title('Fonema /a/')
subplot(2,3,4)
plot(t(15250:22770), error(15250:22770))
subplot(2,3,2)
plot(t(23110:25520),audio(23110:25520))
title('Fonema /b/')
subplot(2,3,5)
plot(t(23110:25520),error(23110:25520))
subplot(2,3,3)
plot(t(31390:35020),audio(31390:35020))
title('Fonema /l/')
subplot(2,3,6)
plot(t(31390:35020),error(31390:35020))
hold off
%espectrogramas de las señales
hold on
figure(7)
subplot(2,1,2)
specgram(error,[],Fs)
ylabel('Frecuency (Hz)')
title('Espectrograma de la secuencia de error obtenida')
subplot(2,1,1)
specgram(audio,[],Fs)
ylabel('Frecuency (Hz)')
title('Espectrograma de la señal original')
hold off

%reconstruccion de la señal con la mayor resolucion
audio_reconstruido = zeros(1,54272);
for z = 1:1:122
    lim_inferior = (z-1)*step_10m;
    lim_superior = lim_inferior + step_25m;
    lim_audio = 1103;
    if lim_superior > largo_audio(1)
        lim_superior = largo_audio(1);
        lim_audio = lim_superior-lim_inferior;
    end
    audio_reconstruido(lim_inferior+1:lim_superior) = filter(1,[1 lpc_coeff(z,2:end)],error(lim_inferior+1:lim_superior));
end

%escritura del audio
audiowrite('estaba_la_reconstruido.wav', audio_reconstruido,Fs);
[new_audio, Fs] = audioread('estaba_la_reconstruido.wav');
hold on
figure(8)
plot(t,new_audio);
grid
title('Audio reconstruido mediante LPC')
xlabel('Tiempo')
hold off

%reconstruccion de la señal en distintos niveles
eightb_array_error = [min(error):(max(error)-min(error))/255:max(error)];
fourb_array_error = [min(error):(max(error)-min(error))/15:max(error)];
twob_array_error = [min(error):(max(error)-min(error))/3:max(error)];

eightb_array_signal = [min(audio_reconstruido):(max(audio_reconstruido)-min(audio_reconstruido))/255:max(audio_reconstruido)];
fourb_array_signal = [min(audio_reconstruido):(max(audio_reconstruido)-min(audio_reconstruido))/15:max(audio_reconstruido)];
twob_array_signal = [min(audio_reconstruido):(max(audio_reconstruido)-min(audio_reconstruido))/3:max(audio_reconstruido)];

%cuantifico la señal de error
error_8bits = cuantificacion(error, eightb_array_error);
error_4bits = cuantificacion(error, fourb_array_error);
error_2bits = cuantificacion(error, twob_array_error);


%reconstruccion de la señal en distintos niveles
signal_8bits = reconstruccion(error_8bits, lpc_coeff);
signal_4bits = reconstruccion(error_4bits, lpc_coeff);
signal_2bits = reconstruccion(error_2bits, lpc_coeff);

hold on
figure(9)
subplot(3,1,1)
plot(t,error_8bits)
title('Señal de error a 8 bits')
subplot(3,1,2)
plot(t, error_4bits)
title('Señal de error a 4 bits')
subplot(3,1,3)
plot(t, error_2bits)
title('Señal de error a 2 bits')
xlabel('Tiempo')
hold off

hold on
figure(10)
subplot(3,1,1)
plot(t,signal_8bits)
title('Señal reconstruida a 8 bits')
subplot(3,1,2)
plot(t, signal_4bits)
title('Señal reconstruida a 4 bits')
subplot(3,1,3)
plot(t, signal_2bits)
title('Señal reconstruida a 2 bits')
xlabel('Tiempo')

hold off


audiowrite('error8bits.wav', error_8bits, Fs);
audiowrite('error4bits.wav', error_4bits, Fs);
audiowrite('error2bits.wav', error_2bits, Fs);
audiowrite('reconstruccion_8bits.wav',signal_8bits,Fs);
audiowrite('reconstruccion_4bits.wav',signal_4bits,Fs);
audiowrite('reconstruccion_2bits.wav',signal_2bits,Fs);

%secuencia de transferencias IIR
transferencia = [];

for z = 1:1:122
    a = lpc_coeff(z,:);
    [h,w] = freqz(1, [1 a(2:21)]); %arreglo de 512 elementos
    segmento_h = abs(h);
    transferencia = [transferencia, segmento_h];
end

matrix_size = size(transferencia);
hold on
figure(11)
colormap jet
waterfall([1:matrix_size(2)],[1:matrix_size(1)], 20*log10(transferencia))
title('Superficie de las secuencias de transferencias')
hold off


%reemplazo de coeficientes: reemplazo la ultima 'o' por la 'e' de "estaba
%la" y luego reconstruyo.
[audio_ao, Fs] = audioread('aaaooo.wav');
lpc_coeff_ao = zeros(525,21);
largo_audio2 = size(audio_ao);

%calculo de lpc
for x = 1:1:525
    lim_inferior = (x-1)*step_10m;
    lim_superior = lim_inferior + step_25m;
    if lim_superior > largo_audio2(1)
        lim_superior = largo_audio2(1);
    end
    lpc_coeff_ao(x,:)= lpc(audio_ao((lim_inferior+1:lim_superior),1),20);
end

lpc_a = lpc_coeff_ao(15,:);

%calculo error de la otra señal
audio_error2 = zeros(526,1103);
error2 = zeros(1, largo_audio2(1));
predicted_audio2 = zeros(1, largo_audio2(1));
for z = 1:1:525
    lim_inferior = (z-1)*step_10m;
    lim_superior = lim_inferior + step_25m;
    lim_audio = 1103;
    if lim_superior > largo_audio2(1)
        lim_superior = largo_audio2(1);
        lim_audio = lim_superior-lim_inferior;
    end
    audio_error2(z,1:lim_audio) = audio_ao(lim_inferior+1:lim_superior)- filter([0 -lpc_coeff_ao(z,2:end)],1,audio_ao(lim_inferior+1:lim_superior));
    error2(lim_inferior+1:lim_superior) = audio_error2(z,1:lim_audio);
    predicted_audio2(lim_inferior+1:lim_superior) = filter([0 -lpc_coeff_ao(z,2:end)],1,audio_ao(lim_inferior+1:lim_superior));
end



lpc_coeff2 = lpc_coeff;
for i = (1:10)
    lpc_coeff2(i,:) = lpc_a;
end

audio_modificado = zeros(1,54272);
for z = 1:1:122
    lim_inferior = (z-1)*step_10m;
    lim_superior = lim_inferior + step_25m;
    lim_audio = 1103;
    if z <= 10
        audio_modificado(lim_inferior+1:lim_superior) = filter(1,[1 lpc_coeff2(z,2:end)],error2(lim_inferior+1:lim_superior));
    else
        if lim_superior > largo_audio(1)
            lim_superior = largo_audio(1);
            lim_audio = lim_superior-lim_inferior;
        end
        audio_modificado(lim_inferior+1:lim_superior) = filter(1,[1 lpc_coeff2(z,2:end)],error(lim_inferior+1:lim_superior));
    end
end

audiowrite('estaba_la_modificado.wav', audio_modificado,Fs);

hold on
figure(12)
subplot(2,1,1)
plot(t, audio_reconstruido)
title('Audio reconstruido')
subplot(2,1,2)
plot(t,audio_modificado)
xlabel('Tiempo')
title('Audio modificado')
hold off


function signal = cuantificacion(audio, level_array)
    largo = size(audio);
    signal = zeros(largo);
    for x = 1:54272
    [~, pos] = min(abs(level_array - audio(x)));
    signal(1,x) = level_array(pos);
    end
end    

function audio_recontruido2 = reconstruccion(error,lpc_coeff)
    largo_audio = size(error);
    step_25m = 1103;
    step_10m = 441;
    audio_recontruido2 = zeros(1,54272);
    for z = 1:1:122
        lim_inferior = (z-1)*step_10m;
        lim_superior = lim_inferior + step_25m;
        lim_audio = 1103;
        if lim_superior > largo_audio(2)
            lim_superior = largo_audio(2);
            lim_audio = lim_superior-lim_inferior;
        end
        audio_recontruido2(lim_inferior+1:lim_superior) = filter(1,[1 lpc_coeff(z,2:end)],error(lim_inferior+1:lim_superior));
    end
end

