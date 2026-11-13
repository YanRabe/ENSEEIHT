% fonction edges pour afficher les contours
    function edges = computeBoundaries(labels)
        [H,W] = size(labels);
        edges = zeros(H,W);
        edges(:,1:end-1) = (labels(:,1:end-1) ~= labels(:,2:end));
        edges(1:end-1,:) = edges(1:end-1,:) | (labels(1:end-1,:) ~= labels(2:end,:)); 
    end