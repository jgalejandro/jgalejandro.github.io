clc
clear all
close all

% DEFINICION DE SEÑALES
N = 20000;
SNR_db = 20; %SNR entre s(n) y v(n)

var_r = 5e-4;
r = sqrt(var_r) * randn(N,1); % r(n)

b = 1;
a = [1 .9 .5 .45 .35 .25];
s = filter(b,a,r); % s(n) 

%CALCULO TEORICO
%var_s = (1+ 0.9^2 + 0.5^2 + 0.45^2 + 0.35^2 + 0.25^2) * var_r;
%CALCULO POR ESTIMACIÓN
var_s = var(s);

var_v = var_s * inv(10^(SNR_db/10));
v = sqrt(var_v) * randn(N,1); % v(n)

x = s + v; % x(n)

b = 1;
a = [.8 .2 -.1];
u = filter(b,a,v); % u(n)

%--------------------------------------------------------------------------
% Implementación filtro LMS

% Parametros
paso = 50; % Paso
M = 3; % Cantidad de muestras
wo = [5; 5; 5]; % Condición inicial
error = [];
w = []; % Matriz de coeficientes


w_nuevo = wo;

% u(n) Señal de entrada al filtro.
% v(n) Señal deseada
% v_est(n) Señal estimada
v_est = [];
for i = 1:N-M+1
    
    w_anterior = w_nuevo;
    
    u_vent = fliplr(u(i:M+i-1)); % Conj. de muestras
    
    v_est(i) = ctranspose(u_vent) * w_anterior;
    error(i) = x(i+M-1) - v_est(i); 
    w_nuevo = w_anterior + paso*u_vent.*error(i);
    w(i,:) = w_nuevo;
end

% Gráfico: Evolución de las constantes en el tiempo.
figure()
hold on
for i = 1:M
    plot(w(:,i));
    %hold on
end
title("Evolucion de los coeficientes en funcion de las iteraciones")
xlabel("iteracion")
legend("w1","w2","w3")
hold off
figure()
hold on
plot(v_est)
plot(v)
xlabel("iteracion")
title("Comparacion de ruidos blancos")
legend("Ruido blanco estimado","Ruido blanco del ambiente")
hold off
figure()
hold on
plot(x)
plot(error)
xlabel("iteracion")
title("Comparacion de señales deseadas")
legend("Señal del MIC-1","Señal filtrada")
hold off
%%
% Curva de crecimiento + Error:
m_it = 500;% Número de realizaciones.
%J = [];
error_hist = zeros(m_it,N-M+1);
error_hist_s = zeros(m_it,N-M+1);
for j = 1:m_it
    
    r = sqrt(var_r) * randn(N,1); % r(n)
    s = filter(b,a,r); % s(n)
    v = sqrt(var_v) * randn(N,1); % v(n)
    x = s + v; % x(n)
    u = filter(b,a,v); % u(n)
    
    paso = 50; % Paso
    M = 3; % Cantidad de muestras
    wo = [5; 5; 5]; % Condición inicial
    error = zeros(1,N-M+1);
    error_s = zeros(1,N-M+1);
    w = zeros(N-M+1,M); % Matriz de coeficientes
    w_nuevo = wo;
    s_est = zeros(1,N-M+1);
    v_est = zeros(1,N-M+1);
    for i = 1:N-M+1
    
        w_anterior = w_nuevo;
    
        u_vent = fliplr(u(i:M+i-1)); % Conj. de muestras
    
        v_est(i) = ctranspose(u_vent) * w_anterior;
        error(i) = x(i+M-1) - v_est(i); 
        w_nuevo = w_anterior + paso*u_vent.*error(i);
        w(i,:) = w_nuevo;
    
        %Para el cálculo del error
        s_est(i) = x(i+M-1) - v_est(i);
        error_s(i) = s_est(i) - s(i+M-1);
    end
    
    error_hist_s(j,:) = error_s;
    error_hist(j,:) = error;
end
%%
% CURVA APRENDIZAJE
J = zeros(1,N-M+1);
E = zeros(1,N-M+1);
%ver este error
for n = 1:length(error_hist)
    J(n) = 1/m_it * sum(error_hist(:,n).^2);
    E(n) = 1/m_it * sum(error_hist_s(:,n).^2);
end
figure()
hold on
plot(J)
title("Curva de aprendizaje")
hold off

figure()
hold on
plot(E)
title("Curva de error")
hold off

mu = 50; % Paso
M_vect = [1; 2; 3; 4; 5];
m_it = 600;% Número de realizaciones.
E_prom = zeros(1,5); % Promedio error, después de la convergencia.


N = 20000;
SNR_db = 20; %SNR entre s(n) y v(n)
var_r = 5e-4;

for k = 1:length(M_vect)
    M = int32(M_vect(k));
    %J = [];
    error_hist = [];
    error_hist_s = [];
    for j = 1:m_it
    
        r = sqrt(var_r) * randn(N,1); % r(n)
        
        b = 1;
        a = [1 .9 .5 .45 .35 .25];
        s = filter(b,a,r); % s(n)
        
        var_s = var(s);
        var_v = var_s * inv(10^(SNR_db/10));
        v = sqrt(var_v) * randn(N,1); % v(n)
        x = s + v; % x(n)

        b = 1;
        a = [.8 .2 -.1];
        u = filter(b,a,v); % u(n)
    
        paso = 50; % Paso
        M = M_vect(k); % Cantidad de muestras
        wo = 5*ones(M,1); % Condición inicial
        error = [];
        error_s = [];
        w = []; % Matriz de coeficientes
        w_nuevo = wo;
        s_est = [];
        v_est = [];
        for i = 1:N-M+1
    
            w_anterior = w_nuevo;
    
            u_vent = fliplr(u(i:M+i-1)); % Conj. de muestras
    
            v_est(i) = ctranspose(u_vent) * w_anterior;
            error(i) = x(i+M-1) - v_est(i); 
            w_nuevo = w_anterior + paso*u_vent.*error(i);
            w(i,:) = w_nuevo;
    
            %Para el cálculo del error
            s_est(i) = x(i+M-1) - v_est(i);
            error_s(i) = s_est(i) - s(i+M-1);
        end
    
        error_hist_s(:,j) = error_s;
    end
    
    E = [];
    for n = 1:length(error_hist_s)
        E(n) = 1/m_it * sum(error_hist_s(n,:).^2);
    end
    
    L = 500; % Cantidad de elementos a tomar
    dim_E = length(E);
    error_aux = E(dim_E-L:dim_E);
    E_prom(k) = 1/length(error_aux) * sum(error_aux);
    
end
%%
figure(4)
hold on
stem(M_vect,E_prom)
title("Error en funcion de la cantidad parametros")
ylabel("E(n)")
xlabel("M")
hold off
%%
clc
clear all

M = 2; % Orden del filtro.
mu_vector = [30; 40; 50; 60; 70; 80; 100]; % Vector de pasos.
wo = [5; 5]; % Condición inicial propuesto.

% OBJETIVO del inciso: Graficar E(inf) vs. mu
E_inf = zeros(1,7); % Vector para almacenar E(inf).

N = 20000;
SNR_db = 20; %SNR entre s(n) y v(n)
var_r = 5e-4;
n_realizaciones = 500;
for k = 1:length(mu_vector)
    %J = [];
    error_hist = zeros(N-M+1,n_realizaciones);
    error_hist_s = zeros(N-M+1,n_realizaciones);
    
    for j = 1:n_realizaciones
    
        r = sqrt(var_r) * randn(N,1); % r(n)
        
        b = 1;
        a = [1 .9 .5 .45 .35 .25];
        s = filter(b,a,r); % s(n)
        
        var_s = var(s);
        var_v = var_s * inv(10^(SNR_db/10));
        v = sqrt(var_v) * randn(N,1); % v(n)
        x = s + v; % x(n)

        b = 1;
        a = [.8 .2 -.1];
        u = filter(b,a,v); % u(n)
    
        paso = mu_vector(k); % Paso
        %M = M_vect(k); % Cantidad de muestras
        %wo = 5*ones(M,1); % Condición inicial
        error = zeros(1,N-M+1);
        error_s = zeros(1,N-M+1);
        w = []; % Matriz de coeficientes
        w_nuevo = wo;
        s_est = zeros(1,N-M+1);
        v_est = zeros(1,N-M+1);
        for i = 1:N-M+1
    
            w_anterior = w_nuevo;
    
            u_vent = fliplr(u(i:M+i-1)); % Conj. de muestras
    
            v_est(i) = ctranspose(u_vent) * w_anterior;
            error(i) = x(i+M-1) - v_est(i); 
            w_nuevo = w_anterior + paso*u_vent.*error(i);
            w(i,:) = w_nuevo;
    
            %Para el cálculo del error
            s_est(i) = x(i+M-1) - v_est(i);
            error_s(i) = s_est(i) - s(i+M-1);
        end
    
        error_hist_s(:,j) = error_s;
        %error_hist(:,j) = error;
    end
    
    E = zeros(1,N-M+1);
    for n = 1:length(error_hist_s)
        E(n) = 1/n_realizaciones * sum(error_hist_s(n,:).^2);
    end
    
    L = 500; % Cantidad de elementos a tomar
    dim_E = length(E);
    error_aux = E(dim_E-L:dim_E);
    E_inf(k) = 1/length(error_aux) * sum(error_aux);
    
end
%%    
figure(5)
hold on
stem(mu_vector,E_inf)
title("Error en funcion del paso")
xlabel("mu")
ylabel("E(inf)")
hold off
%%
clc
clear all
close all
[y, Fs] = audioread('Pista_01.wav');
SNR_db = 20;
var_s_deseada = 0.0012;
s = sqrt(var_s_deseada/var(y)) * y + (mean(y)*(1-sqrt(var_s_deseada/var(y)))); % Transformación lineal
N = length(s);
var_s = var(s);
var_v = var_s * inv(10^(SNR_db/10));
v = sqrt(var_v) * randn(N,1); % v(n)

x = s + v; % x(n)

b = 1;
a = [.8 .2 -.1];
u = filter(b,a,v); % u(n)

% Aplicación Filtro LMS:
% Parametros
paso = 25; % Paso
M = 5; % Cantidad de muestras
wo = [5; 5; 5; 5; 5]; % Condición inicial
error = zeros(1,N-M+1);
w = zeros(N-M+1,M); % Matriz de coeficientes


w_nuevo = wo;

% u(n) Señal de entrada al filtro.
% v(n) Señal deseada
% v_est(n) Señal estimada
v_est = zeros(1,N-M+1);
s_est = zeros(1,N-M+1);
for i = 1:N-M+1
    
    w_anterior = w_nuevo;
    
    u_vent = fliplr(u(i:M+i-1)); % Conj. de muestras
    
    v_est(i) = ctranspose(u_vent) * w_anterior;
    error(i) = x(i+M-1) - v_est(i);
    w_nuevo = w_anterior + paso*u_vent.*error(i);
    w(i,:) = w_nuevo;
    
    %Para el cálculo del error
    s_est(i) = x(i+M-1) - v_est(i);
    error_s(i) = s_est(i) - s(i+M-1);
end
%%
figure()
hold on
plot(v_est)
plot(v)
title("Comparacion de ruidos blancos")
xlabel("n")
legend("Ruido blanco estimado por el filtro LMS","Ruido blanco 'original 'captado por MIC-1")
hold off
figure()
hold on
plot(abs(error_s).^2)
title("Error de una sola realizacion")
xlabel("n")
ylabel("E(n)")
hold off
%%
audiowrite('Audio_Contaminado.wav',x,Fs);
audiowrite('Audio_estimado.wav',s_est,Fs);
audiowrite('Audio_Original.wav',s,Fs);

