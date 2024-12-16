close all
clear all
clc
%Analisis de la correlaci髇 entre p韝eles vecinos de im醙enes en escala de grises.
%Lectura de las imagenes 01 y 02

[img_dbl, limx, limy] = figure2grey('img_01.jpg');
[img_dbl2, limx2, limy2] = figure2grey('img_02.jpg');

cant_muestras = (limx*limy)/2;
img_dbl = reshape(img_dbl,[2,cant_muestras]);

cant_muestras = (limx2*limy2)/2;
img_dbl2 = reshape(img_dbl2,[2,cant_muestras]);

figure()
subplot(2,1,1)
plot(img_dbl(1,:),img_dbl(2,:),'.b');
title("Grafico de correlacion figura 1");
xlabel("x0")
ylabel("x1")

subplot(2,1,2)
plot(img_dbl2(1,:),img_dbl2(2,:),'.r');
title("Grafico de correlacion figura 2");
xlabel("x0")
ylabel("x1")

%coeficientes de correlacion
corr_01 = corrcoef(img_dbl(1,:),img_dbl(2,:));
corr_02 = corrcoef(img_dbl2(1,:),img_dbl2(2,:));

%% Implementacion de la compresi髇 de im醙enes mediante PCA, calculando la matriz de covarianza y proyectando en un espacio reducido.
[img_dbl3, limx3, limy3] = figure2grey('img_03.jpg');
%Se elimina los bordes para que se pueda agrupar en bloques de 8x8
img_dbl3 = img_dbl3(1:(limy3-rem(limy3,8)),1:(limx3-rem(limx3,8)));

%obtencion de vectores x_i
cant_muestras = (limy3-rem(limy3,8))*(limx3-rem(limx3,8))/64;
X = zeros(64,cant_muestras);

bloqx = (limx3-rem(limx3,8))/8;
bloqy = (limy3-rem(limy3,8))/8;

k = 1;
for i = 0:(bloqy-1)
    for j = 0:(bloqx-1)
        muestra  = img_dbl3((1+i*8):(8+i*8),(1+j*8):(8+j*8));
        muestra = reshape(muestra,64,1);
        X(:,k) = muestra;
        k = k+1;
    end
end

%media y covarianza
ux = mean(X,2);
cx = cov(X');


%Aplicacion el metodo KTL.

% Como ux no es nulo se le debe restar a X ANTES DEL PROCESO DE COMPRESION.
%Xsm = restar_media(X); 

Cx = cov(X'); % Estimaci贸n de la matriz covarianza.

[V,D] = eig(Cx);% Diagonalizaci贸n: Cx = V D V'.
[V,D] = diag_sort(V,D);% Ordenar autovalores.

% CR = 20% -> Cantidad de datos almacenados 'por bloque' = 13
comp = 13;
Dc = D(:,1:comp);
Vc = V(:,1:comp);

y = Vc'*X;
%% Reconstruccion de las im醙enes comprimidas aplicando la transformaci髇 inversa y comparacion con las originales.
Xr = Vc * y; % Reconstruyo las muestras.

[sizeY, sizeX] = size(img_dbl3); % Tama駉 de la imagen procesada.
img_r = zeros(sizeY, sizeX); % Matriz donde se va a reconstruir la imagen.
tam_ori = sizeY*sizeX;

sizeVc = size(Vc);
sizeux = size(ux);
sizey = size(y);
tam_red = sizeVc(1)*sizeVc(2)+sizeux(1)*sizeux(2)+sizey(1)*sizey(2);

Aux = zeros(8,8); 
k = 1;
for i = 1:8:sizeY
    for j = 1:8:sizeX
        Aux = reshape(Xr(:,k),8,8);
        k = k + 1;
        img_r(i:(i+8-1),j:(j+8-1)) = Aux;
    end
end

img3_8bit = uint8(img_dbl3);
img_r8bit = uint8(img_r);

figure()
imshow(img3_8bit, 'InitialMagnification', 250, 'Border', 'tight')
title('Imagen 3 original')

figure()
imshow(img_r8bit, 'InitialMagnification', 250, 'Border', 'tight')
title('Imagen 3 reconstruida')


%% Evalucion del desempe駉 de la compresi髇 calculando el error cuadr醫ico medio (MSE) en funci髇 de la tasa de compresi髇 (CR).

[img_dbl4, limx4, limy4] = figure2grey('img_04.jpg');

%Se elimina los bordes para que se pueda agrupar en bloques de 8x8
img_dbl4 = img_dbl4(1:(limy4-rem(limy4,8)),1:(limx4-rem(limx4,8)));

%obtencion de vectores x_i
cant_muestras = (limy4-rem(limy4,8))*(limx4-rem(limx4,8))/64;
X = zeros(64,cant_muestras);

bloqx = (limx4-rem(limx4,8))/8;
bloqy = (limy4-rem(limy4,8))/8;

k = 1;
for i = 0:(bloqy-1)
    for j = 0:(bloqx-1)
        muestra  = img_dbl4((1+i*8):(8+i*8),(1+j*8):(8+j*8));
        muestra = reshape(muestra,64,1);
        X(:,k) = muestra;
        k = k+1;
    end
end

%media y covarianza
ux = mean(X,2);
cx = cov(X');

Cx = cov(X'); % Estimaci贸n de la matriz covarianza.

[V,D] = eig(Cx);% Diagonalizaci贸n: Cx = V D V'.
[V,D] = diag_sort(V,D);% Ordenar autovalores.

% CR = 5% -> Cantidad de datos almacenados 'por bloque' = 4
% comp = CR*64/100

mse = [];

img4_8bit = uint8(img_dbl4);
figure()
imshow(img4_8bit,'InitialMagnification',250,'Border',"tight")
title('Imagen 4 original')

for CR = 5:5:95
    comp = (CR*64-mod(CR*64,100))/100;
    Dc = D(:,1:comp);
    Vc = V(:,1:comp);

    y = Vc'*X;% Vc = U

    Xr = Vc * y; % Reconstruyo las muestras.
    
    mse = [mse, mean(sum((X-Xr).^2)) ];

    [sizeY, sizeX] = size(img_dbl4); % Tama駉 de la imagen procesada.
    img_r = zeros(sizeY, sizeX); % Matriz donde se va a reconstruir la imagen.
    
    Aux = zeros(8,8); 
    k = 1;
    for i = 1:8:sizeY
        for j = 1:8:sizeX
            Aux = reshape(Xr(:,k),8,8);
            k = k + 1;
            img_r(i:(i+8-1),j:(j+8-1)) = Aux;
        end
    end
    
    if(CR <= 25)
        figure()
        img_r8bit = uint8(img_r);
        imshow(img_r8bit,'InitialMagnification',250,'Border',"tight")
        title(['Imagen 4 CR% = ',num2str(CR),'%'])
    end
end

CR_str = 5:5:95;
min_mse = min(mse);
max_mse = max(mse);

figure()
plot(CR_str,mse)
title('MSE vs CR%','LineWidth',2)
xlabel('CR%');
ylabel('MSE');
axis([5  95  min_mse max_mse])
grid on

%Comentario: Lee un archivo de imagen y lo devuelve como matriz con formato
%double y en escala de grises. Tambien devuelve las dimensiones de dicha
%matriz.
function [img_dbl, limx, limy] = figure2grey(image)
    img_rgb = imread(image);
    img_gray = rgb2gray(img_rgb);
    img_dbl = double(img_gray);
    [limy,limx] = size(img_dbl);
end

%Comentario: Ordena los autovalores de la matriz D de forma descendente y
% de forma correspondiente reubica las columnas de la matriz V.
function [Vs, Ds] = diag_sort(V,D)
    [~, ind] = sort(diag(D),'descend');
    Ds = D(ind,ind);
    Vs = V(:,ind);
end