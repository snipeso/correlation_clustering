function clusters = cluster_corr(R, threshold)
% Cluster elements based on their correlation, such that avery pair in a
% cluster has a minimum (threshold) value.
% Inputs:
% R = correlation matrix (produced by functions corr or corrcoef)
% threshold = minimum correlation needed to be a part of the cluster
%
% Output:
% clusters = struct with field "nodes", a list of the indexes of the
% original R matrix included in the cluster.

nNodes = size(R, 1);
nodes_left = 1:nNodes; % start with complete list of indexes

diagonal = 1:nNodes+1:numel(R);
R(diagonal) = nan; % ignore values on the diagonal

clusters = struct();
indx_c = 0; % keep track of number of clusters

while numel(nodes_left) > 1 % once all nodes are clustered, you're done!
    
    % get R values for remaining nodes
    R_left = nan(size(R));
    R_left(nodes_left, nodes_left) = R(nodes_left, nodes_left);
    
    % find largest correlation
    [max_R, max_indx] = max(R_left);
    
    % if there are no nodes above threshold, save remaing 1 node clusters
    if max_R < threshold
        for node = nodes_left
            indx_c = indx_c+1;
            clusters(indx_c).nodes = node;
        end
        break
    end
    
    % get indices involved in the highest correlation
    [row, col] = ind2sub(size(R), max_indx);
    
    % start lists of nodes to keep or not in this cluster
    keep = [row; col];
    discard = [];
    
    % assign all remaining nodes to either keep or discard
    while numel(keep) + numel(discard) < numel(nodes_left)
        
        R_keep = nan(size(R));
        R_keep(:, keep) = R_left(:, keep); % get columns of kept Rs
        
        % discard nodes that are below threshold
        d = find(R_keep<threshold);
        [rows, ~] = ind2sub(size(R), d); 
        discard = unique(cat(1, discard, rows));
        
        % proceed to only consider correlations with unassigned nodes
        R_keep(discard, :) = nan;
        R_keep(keep, :) = nan;
        
        if ~any(R_keep(:)>=threshold)
            break % leave while loop if there are no more above-threshold nodes
        end
        
        % pick the most highly correlated node left
        [~, max_indx] = max(R_keep(:));
        [row, ~] = ind2sub(size(R), max_indx);
        keep = unique(cat(1, keep, row));
    end
    
    % add cluster to struct
    indx_c = indx_c+1;
    clusters(indx_c).nodes = keep;
    
    nodes_left(ismember(nodes_left, keep)) = []; % remove cluster from remaing nodes
end