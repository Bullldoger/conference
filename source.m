clc;
clear;

file = xlsread('table.xlsx');
set = xlsread('set.xlsx');

SPT = file(1:end, 4:5);
L = file(1:end, 14);

test = zeros(1115, 2);

for i = 1:1115
    test(i, 1) = set(i, 4) / set(i, 5);
    test(i, 2) = set(i, 14);
end

S = zeros(10, 1);

format longG;

for i = 1:10
   S(i) = SPT(i, 1) / SPT(i, 2);
end

ellipse = zeros(1, 3);
elongated = zeros(1, 3);
strellongated = zeros(1, 3);

rounded = zeros(1, 3);
semirounded = zeros(1, 3);
nonrounded = zeros(1, 3);

for i=1:3
    ellipse(1, i) = S(i, 1);
    elongated(1, i) = S(i + 3, 1);
    strellongated(1, i) = S(i + 6, 1);
end

for i=1:3
    rounded(1, i) = L(3 * (i - 1) + 1, 1);
    semirounded(1, i) = L(3 * (i - 1) + 2, 1);
    nonrounded(1, i) = L(3 * (i - 1) + 3, 1);
end

rounded = sort(rounded);
semirounded = sort(semirounded);
nonrounded = sort(nonrounded);

ellipse = sort(ellipse);
elongated = sort(elongated);
strellongated = sort(strellongated);

fis = newfis('cluster');

fis = addvar(fis, 'input', 'S/P', [0 0.015]);
fis = addvar(fis, 'input', 'L', [0 10]);

fis = addvar(fis, 'output', 'result', [0 10]);

maxR = max(rounded);
maxSR = max(semirounded);
minSR = min(semirounded);
minNR = min(nonrounded);

r = [0 maxR minSR];
sr = [maxR minSR minNR];
nr = [minSR minNR nonrounded(3) * 3];

maxE = max(strellongated);
minEL = min(elongated);
maxEL = max(elongated);
minSTRE = min(ellipse);

e = [0 minEL maxE];
el = [minEL maxE minSTRE];
stre = [maxE minSTRE strellongated(3) * 3];

fis = addmf(fis, 'input', 2, '������������','trimf', r);
fis = addmf(fis, 'input', 2, '����������','trimf', sr);
fis = addmf(fis, 'input', 2, '����� ����������','trimf', nr);

fis = addmf(fis, 'input', 1, '�����', 'trimf', e);
fis = addmf(fis, 'input', 1, '�������', 'trimf', el);
fis = addmf(fis, 'input', 1, '�������', 'trimf', stre);

rule1 = [3 1 1 1 1];
rule2 = [3 2 2 1 1];
rule3 = [3 3 3 1 1];
rule4 = [2 1 4 1 1];
rule5 = [2 2 5 1 1];
rule6 = [2 3 6 1 1];
rule7 = [1 1 7 1 1];
rule8 = [1 2 8 1 1];
rule9 = [1 3 9 1 1];

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

out = evalfis(test, fis)

gensurf(fis);
