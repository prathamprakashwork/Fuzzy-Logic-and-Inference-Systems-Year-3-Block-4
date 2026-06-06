# Please run on MATLAB 

clc;
clear;
close all;

%% ============================================================
% HUMAN-AI AUTHORITY ALLOCATION SYSTEM
% IMAT3722 - Fuzzy Logic and Inference Systems
%
% INPUTS:
% 1. Human Readiness
% 2. AI Readiness
% 3. Mission Severity
%
% OUTPUT:
% Authority Allocation
%
% 0-30   = Human Led
% 30-70  = Shared Control
% 70-100 = AI Led
%% ============================================================

%% Create FIS

fis = mamfis( ...
    'Name','HumanAIAuthoritySystem', ...
    'AndMethod','min', ...
    'OrMethod','max', ...
    'ImplicationMethod','min', ...
    'AggregationMethod','max', ...
    'DefuzzificationMethod','centroid');

%% ============================================================
% HUMAN READINESS
%% ============================================================

fis = addInput(fis,[0 100],'Name','HumanReadiness');

fis = addMF(fis,'HumanReadiness','trapmf',...
    [0 0 20 40],'Name','Low');

fis = addMF(fis,'HumanReadiness','trimf',...
    [30 50 70],'Name','Medium');

fis = addMF(fis,'HumanReadiness','trapmf',...
    [60 80 100 100],'Name','High');

%% ============================================================
% AI READINESS
%% ============================================================

fis = addInput(fis,[0 100],'Name','AIReadiness');

fis = addMF(fis,'AIReadiness','trapmf',...
    [0 0 20 40],'Name','Low');

fis = addMF(fis,'AIReadiness','trimf',...
    [30 50 70],'Name','Medium');

fis = addMF(fis,'AIReadiness','trapmf',...
    [60 80 100 100],'Name','High');

%% ============================================================
% MISSION SEVERITY
%% ============================================================

fis = addInput(fis,[0 100],'Name','MissionSeverity');

fis = addMF(fis,'MissionSeverity','trapmf',...
    [0 0 15 35],'Name','Low');

fis = addMF(fis,'MissionSeverity','trimf',...
    [30 50 70],'Name','Medium');

fis = addMF(fis,'MissionSeverity','trapmf',...
    [65 85 100 100],'Name','High');

%% ============================================================
% OUTPUT
%% ============================================================

fis = addOutput(fis,[0 100],'Name','AuthorityAllocation');

fis = addMF(fis,'AuthorityAllocation','trapmf',...
    [0 0 15 35],'Name','HumanLed');

fis = addMF(fis,'AuthorityAllocation','trimf',...
    [35 50 65],'Name','SharedControl');

fis = addMF(fis,'AuthorityAllocation','trapmf',...
    [65 85 100 100],'Name','AILed');

%% ============================================================
% RULE BASE
%
% Rule format:
% [Human AI Severity Output Weight Operator]
%
% Low=1 Medium=2 High=3
%
% Output:
% HumanLed=1
% Shared=2
% AILed=3
%% ============================================================

ruleList = [

% HUMAN LOW
1 1 1 1 1 1
1 1 2 1 1 1
1 1 3 2 1 1

1 2 1 2 1 1
1 2 2 2 1 1
1 2 3 3 1 1

1 3 1 3 1 1
1 3 2 3 1 1
1 3 3 3 1 1

% HUMAN MEDIUM
2 1 1 1 1 1
2 1 2 2 1 1
2 1 3 2 1 1

2 2 1 2 1 1
2 2 2 2 1 1
2 2 3 2 1 1

2 3 1 3 1 1
2 3 2 3 1 1
2 3 3 3 1 1

% HUMAN HIGH
3 1 1 1 1 1
3 1 2 1 1 1
3 1 3 1 1 1

3 2 1 1 1 1
3 2 2 2 1 1
3 2 3 2 1 1

3 3 1 2 1 1
3 3 2 2 1 1
3 3 3 3 1 1

];

fis = addRule(fis,ruleList);

%% ============================================================
% DISPLAY RULES
%% ============================================================

disp('=========================================')
disp('HUMAN-AI AUTHORITY SYSTEM CREATED')
disp('=========================================')

showrule(fis)

%% ============================================================
% MEMBERSHIP FUNCTION PLOTS
%% ============================================================

figure('Name','Human Readiness');
plotmf(fis,'input',1);
grid on

figure('Name','AI Readiness');
plotmf(fis,'input',2);
grid on

figure('Name','Mission Severity');
plotmf(fis,'input',3);
grid on

figure('Name','Authority Allocation');
plotmf(fis,'output',1);
grid on

%% ============================================================
% RULE VIEWER
%% ============================================================

ruleview(fis)

%% ============================================================
% SCENARIO TESTING
%% ============================================================


testData = [

% Original Scenarios
20 30 80
20 90 90
90 20 20
60 90 95
70 70 50
15 95 85
95 15 40
50 50 50
40 85 95
90 20 50

% Boundary Cases
0   0   0
0   0   100
0   100 0
0   100 100

100 0   0
100 0   100
100 100 0
100 100 100

% Additional Evaluation Cases
25 25 25
25 25 75
25 75 25
25 75 75

75 25 25
75 25 75
75 75 25
75 75 75

50 20 80
50 80 20
20 50 80
80 50 20

];

ScenarioNames = strcat("Case_", string(1:size(testData,1)))';

results = evalfis(fis,testData);

HumanLedCount = sum(results < 35);

SharedCount = sum(results >= 35 & results < 65);

AILedCount = sum(results >= 65);

%% ============================================================
% PERFORMANCE METRICS
%% ============================================================

MeanAuthority = mean(results);
MaxAuthority = max(results);
MinAuthority = min(results);
StdAuthority = std(results);

fprintf('\n');
fprintf('=========== PERFORMANCE METRICS ===========\n');

fprintf('Mean Authority Allocation = %.2f\n',MeanAuthority);
fprintf('Maximum Authority Allocation = %.2f\n',MaxAuthority);
fprintf('Minimum Authority Allocation = %.2f\n',MinAuthority);
fprintf('Standard Deviation = %.2f\n',StdAuthority);

AuthorityCategory = strings(length(results),1);

for i = 1:length(results)

    if results(i) < 35
        AuthorityCategory(i) = "Human Led";

    elseif results(i) < 65
        AuthorityCategory(i) = "Shared Control";

    else
        AuthorityCategory(i) = "AI Led";
    end

end

%% ============================================================
% CREATE RESULTS TABLE
%% ============================================================

ResultsTable = table( ...
    ScenarioNames,...
    testData(:,1),...
    testData(:,2),...
    testData(:,3),...
    results,...
    AuthorityCategory,...
    'VariableNames',...
    {'Scenario',...
     'HumanReadiness',...
     'AIReadiness',...
     'MissionSeverity',...
     'AuthorityAllocation',...
     'AuthorityCategory'});

disp(ResultsTable)

%% ============================================================
% RESULTS SUMMARY
%% ============================================================

disp(' ')
disp('========== CATEGORY SUMMARY ==========')

fprintf('Human Led Cases    : %d\n', HumanLedCount);
fprintf('Shared Control     : %d\n', SharedCount);
fprintf('AI Led Cases       : %d\n', AILedCount);

%% ============================================================
% EXPORT CSV
%% ============================================================

writetable(ResultsTable,...
    'AuthorityAllocationResults.csv');

writetable(ResultsTable,...
    'Table1_TestResults.xlsx');

MetricsTable = table( ...
    MeanAuthority,...
    MaxAuthority,...
    MinAuthority,...
    StdAuthority);

writetable(MetricsTable,...
    'PerformanceMetrics.csv');

%% ============================================================
% BAR CHART
%% ============================================================

figure('Name','Scenario Authority Allocation');

bar(results)

ylim([0 100])

yline(35,'--','Human Led Threshold')
yline(65,'--','AI Led Threshold')

xticks(1:length(results))
xticklabels([])

xtickangle(45)

ylabel('Authority Allocation Score')
xlabel('Scenario')

title('Authority Allocation Across Test Scenarios')

grid on

%% ============================================================
% AUTHORITY CATEGORY DISTRIBUTION
%% ============================================================



figure('Name','Authority Category Distribution');

bar([HumanLedCount SharedCount AILedCount])

xticklabels({'Human Led',...
    'Shared Control',...
    'AI Led'})

ylabel('Number of Test Cases')

title('Distribution of Authority Categories')

grid on

%% ============================================================
% INTERPRETATION OUTPUT
%% ============================================================

fprintf('\n');
fprintf('================ RESULTS ================\n');

for i = 1:length(results)

    fprintf('\nScenario: %s\n', ScenarioNames{i});

    fprintf('Human=%g | AI=%g | Severity=%g\n',...
        testData(i,1),...
        testData(i,2),...
        testData(i,3));

    fprintf('Authority Allocation = %.2f (%s)\n',...
        results(i),...
        AuthorityCategory(i));
end

%% ============================================================
% SAVE FIS
%% ============================================================

try
    writeFIS(fis,'HumanAIAuthoritySystem');
catch
    writefis(fis,'HumanAIAuthoritySystem.fis');
end

disp(' ')
disp('CSV Results Saved')
disp('FIS Saved')
disp('Project Complete')

