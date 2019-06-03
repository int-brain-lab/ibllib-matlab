function [S] = get_top_bottom(V, cs)
% extract surfaces of the top and bottom of the brain
[S.top, S.bottom] = deal(zeros(cs.ny, cs.nx));
for s=1:cs.ny
    [i1,i2] = find(diff(V.lab(:,:,s)==0,1,1));
    S.top(s,:) = accumarray(i2, i1, [cs.nx 1], @min, NaN);
    S.bottom(s,:) = accumarray(i2, i1, [cs.nx 1], @max, NaN);
end
% hold on
% figure
%  hold on, surf(S.top, 'EdgeColor', 'none'),
%  hold on, surf(S.bottom, 'EdgeColor', 'none'),