function [ avg_acc, err, prec, rec, ot_rate ] = calcQuality( est_labels, labels, classes )
%function [ avg_acc, err, prec, rec ] = calcQuality( est_labels, labels, classes )
%
% Calculates different quality mesurements from estimates and ground truths
%
% Arguments:
%   est_labels    = detected tones [1 x M]
%   labels        = true tones [1 x M]
%   classes       = vector with all different classes [1 x N]
%
% Output:
%   avg_acc       = Average accuracy of detection
%   err           = Avergage error of detection
%   prec          = Precision of detection
%   rec           = Recall of detecion
%   ot_rate       = Over tone error rate

%% Initialization
N = size(classes,2);
confusions = zeros(2,2,N);
over_tones = 0;
allowed_octaves = 1; % Number of allowed octaves in the over tones error rate

%% Zero padding if necessary
[est_labels, labels] = sameLength(est_labels,labels);

[est_labels' labels'];

%% Calculate confusion matrix per class
for j = 1:N
    % Create temporary arrays
    temp_labels1 = est_labels;
    temp_labels2 = labels;
    
    % Find indices of non relevant classes
    I = find(est_labels ~= classes(j));
    i = find(temp_labels2 ~= classes(j));
    
    % Find and calculate possible over tones
    for k = 1:allowed_octaves
        over_tones = over_tones + length(find(abs(est_labels(find(labels==classes(j)))-classes(j)) == 12*k));
    end
    
    % Set non relevant classes to -1 (not a class label)
    temp_labels1(I) = -1;
    temp_labels2(i) = -1;
    
    % Remove redundant classes from vectors
    [M idx] = unique(sort([i I])); % find unique indices
    counts = diff([0 idx]); % count indices occurance
    idx = M(find(counts == 2)); % remove indices that occur twice, i.e. idx are the indices in the label vectors where both labels are -1
   
    % Remove indices
    temp_labels1(idx) = [];
    temp_labels2(idx) = [];
    
    % Create confusion matrix for class
    if size(temp_labels1,2) > 0
        temp = confusionmat(temp_labels2,temp_labels1,'ORDER',[classes(j) -1]);
        if size(temp,1) == 1;
            confusions(1,1,j) = confusionmat(temp_labels2,temp_labels1,'ORDER',[classes(j) -1]);
            continue;
        end
        confusions(:,:,j) = confusionmat(temp_labels2,temp_labels1,'ORDER',[classes(j) -1]);
    end
end

%% Calculate outputs
% Accuracy
acc = (confusions(1,1,:)+confusions(2,2,:))./(confusions(1,1,:)+confusions(2,2,:)+confusions(2,1,:)+confusions(1,2,:));
avg_acc = sum(acc,3)/N;

% Error rate
err = (confusions(2,1,:)+confusions(1,2,:))./(confusions(1,1,:)+confusions(2,2,:)+confusions(2,1,:)+confusions(1,2,:));
err = sum(err,3)/N;

% Precision
prec = sum(confusions(1,1,:),3)/sum(confusions(1,1,:)+confusions(1,2,:),3);

% Recall
rec = sum(confusions(1,1,:),3)/sum(confusions(1,1,:)+confusions(2,1,:),3);

% Over tone rate
tot_errors = sum(confusions(1,2,:)+confusions(2,1,:),3);
if tot_errors == 0
    ot_rate = 0;
else
    ot_rate = over_tones/tot_errors;
end

end

