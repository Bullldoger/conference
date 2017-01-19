function [] = start()    %Главная функция
clc;
clear;
format longG;

%Получение колонок S, P и L из таблицы
[k, L, S] = init('table.xlsx');   
%Инициализация таблиц для классификации в системе нчл
%Получение обрабатываемой выборки, нахождение min\max для каждой переменной
%Получение границ для функций принадлежности
[firstVar, secondVar] = paramsForMF();
%Получение настроенной системы нечеткого вывода
fis = fis(firstVar, secondVar);
%Получение обученной нейросети

figure
hold on;
title('Окатанность', 'FontSize', 20)
for i=1:9
    plot([S(i) S(i)], [0 0], 'or')
end
legend('Эталонные объекты', 'Location', 'southwest')
plotmf(fis, 'input', 1)
yl = ylabel('Степень принадлежности');
xl = xlabel('S/P');
set(yl, 'FontSize', 12);
set(gca, 'FontSize', 9);
hold off;

%{
figure
hold on;

plot([1.516486555 1.516486555], [0 50]);
plot([3.102078465 3.102078465], [0 50]);



title('Эталонная выборка', 'FontSize', 20)
for i=1:9
    plot([L(i) L(i)], [k(i) k(i)], 'or')
end
legend('Эталонные объекты', 'Location', 'southwest');
yl = ylabel('Форм фактор');
xl = xlabel('Удлинение');
set(yl, 'FontSize', 12);
set(xl, 'FontSize', 12);
set(gca, 'FontSize', 9);
hold off;
%}
%Тест на обучающей выборке
%Функции принадлежности(графики)

%Ответы от нчл и нейросети

%Вывод и сравнение на экране



function [k, L, S] = init(initFile)   %Функция инициализации
file = xlsread(initFile);   %Читаем файл
SP = file(1:9, 4:5);
k = file(1:9, 12);     %Загрузка данных площади и периметра
L = file(1:9, 14);
S = zeros(9)
for i=1:9
    S(i) = SP(i, 1) / SP(i, 2);
end

%Подготовка данных для настройки системы нечеткого вывода
function [initFirstVar, initSecondVar] = preload(S, L) 
ellipse = zeros(1, 3);  %Инициализация матриц
elongated = zeros(1, 3);
strellongated = zeros(1, 3);
rounded = zeros(1, 3);
semirounded = zeros(1, 3);
nonrounded = zeros(1, 3);
S = sort(S);
L = sort(L);
for i=0:2
    ellipse(1, i) = S(i + 2, 1);        %Формирование матрицы ellipse
    elongated(1, i) = S(i + 4, 1);      %..                   elongated
    strellongated(1, i) = S(i + 7, 1);  %..                   strellongated
end
for i=0:2
    rounded(1, i) = L(i, 1);            %..                   rounded
    semirounded(1, i) = L(i + 3, 1);    %..                   semirounded
    nonrounded(1, i) = L(i + 6, 1);     %..                   nonrounded
end
initFirstVar = [strellongated; elongated; ellipse];
initSecondVar = [rounded; semirounded; nonrounded];

%Получение максимальных границ переменных и тестовой выборки
function [test, rFirstVar, rSecondVar] = getRanges(path)    
file = xlsread(path);
test = zeros(1115, 2);
for i = 1:1115
    test(i, 1) = file(i, 4) / file(i, 5);
    test(i, 2) = file(i, 14);
end
maxFirstVar = max(test(1 : end, 1)) * 1.1;    %Максимум первой переменной
maxSecondVar = max(test(1 : end, 2)) * 1.1;   %Максимум второй переменной

minFirstVar = min(test(1 : end, 1)) * 0.9;    %Минимум первой переменной
minSecondVar = min(test(1 : end, 2)) * 0.9;   %Минимум второй переменной

rFirstVar = [minFirstVar, maxFirstVar];
rSecondVar = [minSecondVar, maxSecondVar];


function [firstVar, secondVar] = paramsForMF()

leftFirstVar = [0 0 0.00829 0.0085];
middleFirstVar = [0.00829 0.0085 0.01 0.0105];
rightFirstVar = [0.01 0.0105 1 1];
firstVar = [leftFirstVar; middleFirstVar; rightFirstVar];

leftSecondVar = [0 0 1.3 1.73];
middleSecondVar = [1.3 1.73 2.225433526 3.85];
rightSecondVar = [2.225433526 3.85 10 10];
secondVar = [leftSecondVar; middleSecondVar; rightSecondVar]; %Готовые границы для функции второй переменной

%Создание и настройка системы нечеткого вывода, и его возврат
function fis = fis(rangeVar1, rangeVar2)
fis = newfis('cluster');
fis = addvar(fis, 'input', 'S/P', [0.0075 0.012]);
fis = addvar(fis, 'input', 'L', [0.85 4.8]);
fis = addvar(fis, 'output', 'result', [0 10]);
fis = addmf(fis, 'input', 2, 'изометричный','trapmf', rangeVar2(1, :));
fis = addmf(fis, 'input', 2, 'удлиненный','trapmf', rangeVar2(2, :));
fis = addmf(fis, 'input', 2, 'резко удлиненный','trapmf', rangeVar2(3, :));
fis = addmf(fis, 'input', 1, 'окатанный','trapmf', rangeVar1(1, :));
fis = addmf(fis, 'input', 1, 'полуокатанный','trapmf', rangeVar1(2, :));
fis = addmf(fis, 'input', 1, 'неокатанный','trapmf', rangeVar1(3, :));
rule1 = [1 1 1 1 1];
rule2 = [1 2 2 1 1];
rule3 = [1 3 3 1 1];
rule4 = [2 1 4 1 1];
rule5 = [2 2 5 1 1];
rule6 = [2 3 6 1 1];
rule7 = [3 1 7 1 1];
rule8 = [3 2 8 1 1];
rule9 = [3 3 9 1 1];
rulelist = [rule1; rule2; rule3; rule4; rule5; rule6; rule7; rule8; rule9];
fis = addmf(fis, 'output', 1, '1', 'trimf', [0 1 2]);
fis = addmf(fis, 'output', 1, '2', 'trimf', [1 2 3]);
fis = addmf(fis, 'output', 1, '3', 'trimf', [2 3 4]);
fis = addmf(fis, 'output', 1, '4', 'trimf', [3 4 5]);
fis = addmf(fis, 'output', 1, '5', 'trimf', [4 5 6]);
fis = addmf(fis, 'output', 1, '6', 'trimf', [5 6 7]);
fis = addmf(fis, 'output', 1, '7', 'trimf', [6 7 8]);
fis = addmf(fis, 'output', 1, '8', 'trimf', [7 8 9]);
fis = addmf(fis, 'output', 1, '9', 'trimf', [8 9 10]);


fis = addrule(fis, rulelist);

%Получение обучающей выборки, настройка для нейронной сети, инициализация
%сети и её обучение
%Итог - готовый объект нейронной сети для классификации
function net = initNet(S, L)
T = 1:1:9;
P = [S(1:9) L(1:9)];
P = P';
net=newff(minmax(P),[2, 9, 9, 1],{'logsig' 'logsig' 'logsig' 'purelin'}, 'trainlm');
net.performFcn='sse';
net.trainParam.goal=0.01;
net.trainParam.epochs=1000;
net = train(net, P, T);