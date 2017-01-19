function [] = start()
clc;
format longG;
%Подготовленные данные и границы
[k L r] = init('table.xlsx');
%Система нечеткого вывода
sys = prepareSystem(r);
plotmf(sys, 'input', 1);

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

end

function [k, L, ranges] = init(initFile)
file = xlsread(initFile);
k = file(1:9, 12);
L = file(1:9, 14);

sub_k_1 = zeros(1, 3);
sub_k_2 = zeros(1, 3);
sub_k_3 = zeros(1, 3);
for i=1:3
    sub_k_1(1, i) = k(i * 3 - 2);
    sub_k_2(1, i) = k(i * 3 - 1);
    sub_k_3(1, i) = k(i * 3);
end

sub_L_1 = zeros(1, 3);
sub_L_2 = zeros(1, 3);
sub_L_3 = zeros(1, 3);
for i=1:3
    sub_L_1(1, i) = L(i * 3 - 2);
    sub_L_2(1, i) = L(i * 3 - 1);
    sub_L_3(1, i) = L(i * 3);
end

ranges = [(max(sub_k_1) + min(sub_k_2)) / 2 ((max(sub_k_1) + min(sub_k_2)) / 2 + (max(sub_k_2) + min(sub_k_3)) / 2) / 2 (max(sub_k_2) + min(sub_k_3)) / 2;
          (max(sub_L_1) + min(sub_L_2)) / 2 ((max(sub_L_1) + min(sub_L_2)) / 2 + (max(sub_L_2) + min(sub_L_3)) / 2) /2 (max(sub_L_2) + min(sub_L_3)) / 2];

end

function system = prepareSystem(r)
    system = newfis('cluster');
    system = addvar(system, 'input', 'k', [0 55]);
    system = addvar(system, 'input', 'L', [0.85 4.8]);
    system = addmf(system, 'input', 2, 'изометричный', 'trapmf', [0 0 r(2, 1) r(2, 2)]);
    system = addmf(system, 'input', 2, 'удлиненный', 'trimf', [r(2, 1) r(2, 2) r(2, 3)]);
    system = addmf(system, 'input', 2, 'резко удлиненный','trapmf', [r(2, 2) r(2, 3) 5 10]);
    system = addmf(system, 'input', 1, 'малый','trapmf', [0 0 r(1, 1) r(1, 2)]);
    system = addmf(system, 'input', 1, 'средний','trimf',  [r(1, 1) r(1, 2) r(1, 3)]);
    system = addmf(system, 'input', 1, 'большой','trapmf',  [r(1, 2) r(1, 3) 55 55]);
end