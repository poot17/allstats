function [R s]= allstats(A,varargin)
% [R s]= ALLSTATS(A) returns a structure R and integer s with several statistics of vector A.  Groups within the data can be defined in optional vector G using an alphanumeric value for each group: R= ALLSTATS(A,G), see examples below.  G can contain a second column for secondary grouping.
% In case a groups vector is provided all the statistics will be calculated independently for each group. Each statistic is returned as a field of structure R. Requires Statistics toolbox.
% 
% The stats calculated are:
% R.min= 	minimum 
% R.max= 	maximum 
% R.mean= 	mean
% R.std= 	standard deviation
% R.mode= 	mode (of freq. distribution produced by HIST), with fixed bucket size of 30
% R.q1= 	1 percentile
% R.q2p5= 	2.5 percentile
% R.q5=   	5 percentile
% R.q25=	25 percentile
% R.q50=	50 percentile (median)
% R.q75=	75 percentile
% R.q95= 	95 percentile
% R.q97p5= 	97.5 percentile
% R.q99= 	99 percentile
% R.kurt= 	Kurtosis
% R.skew= 	Skewness
% R.sampleSize= Sample size of group
% R.gname = Name of group 
% R.rows = a vector holding the set of row numbers relevant for this group
%
% Example without groups
%  x= rand(10,1);
%  R= allstats(x)
% 
% Example with 2 groups (coded as 1 and 2 in vector G)
%  G= [1;1;1;1;1;2;2;2;2;2];
%  R= allstats(x,G)

    A= shiftdim(A);

    [a b] = size(varargin{1,1});

    if b == 2  %grouping has 2 columns to allow for secondary groupings 
        secGrouping = varargin{1}(:,2);
        varargin{1}(:,2) = [];
    end

    % Some error checking
    if ~isempty(varargin)
        factors= shiftdim(varargin{1});

        if length(A) ~= length(factors)
            error('Length of first and second arguments must be the same'); 
        end
    end

    % We have groups
    if ~isempty(varargin)

    % Extract unique values for groups
        if isa(varargin{1,1}{1},'double')      % checks if grouping vector is a double or a string
            rowString= 'find(cell2mat(factors) == fval(k))';
            fval= unique(cell2mat(factors));    %this is assuming the grouping vector is a cell array of numbers. Could consider using uniquecell
        else
            rowString= 'find(strcmp(fval(k),factors))';        
            fval= unique(factors);              %this is assuming the grouping vector is a cell array of strings
        end

        s= length(fval);

        % Create the structure
        R= struct('min',zeros(s,1),'max',zeros(s,1),'mean',zeros(s,1),...
            'std',zeros(s,1),'q1',zeros(s,1),'q2p5',zeros(s,1),'q5',zeros(s,1),'q25',zeros(s,1),'q50',zeros(s,1),...
            'q75',zeros(s,1),'q95',zeros(s,1),'q97p5',zeros(s,1),'q99',zeros(s,1),'kurt',zeros(s,1),...
            'skew',zeros(s,1),'sampleSize',zeros(s,1),'gname',{},'rows',[]);

        % Do calculations for each value of the groups
        for k= 1:s
                rows = eval(rowString);  
                R(k).min=	nanmin(A(rows,:));
                R(k).max=	nanmax(A(rows,:));
                R(k).mean=	nanmean(A(rows,:));
                R(k).std=	nanstd(A(rows,:));
                [f,n]= hist(A(rows,:),30);  %30 buckets in this histogram / frequency counter
                R(k).mode=  n(find(f==max(f)));
                R(k).q1=	prctile(A(rows,:),1);
                R(k).q2p5=	prctile(A(rows,:),2.5);
                R(k).q5=	prctile(A(rows,:),5);
                R(k).q25=	prctile(A(rows,:),25);
                R(k).q50=	prctile(A(rows,:),50);
                R(k).q75=	prctile(A(rows,:),75);
                R(k).q95=	prctile(A(rows,:),95);
                R(k).q97p5=	prctile(A(rows,:),97.5);
                R(k).q99=	prctile(A(rows,:),99);
                R(k).kurt=	kurtosis(A(rows,:));
                R(k).skew=	skewness(A(rows,:));
                if b==2
                    R(k).sampleSize = length(unique(cell2mat(secGrouping(rows))));    %added in sample size
                else
                    R(k).sampleSize = length(rows);
                end
                R(k).gname= fval(k);
                R(k).rows = rows;
        end

    else % We have no groups
        R.min=	nanmin(A);
        R.max=	nanmax(A);
        R.mean=	nanmean(A);
        R.std=	nanstd(A);
        [f,n]= hist(A,30);
        R.mode=  n(find(f==max(f)));
        R(k).q1=	prctile(A(rows,:),1);
        R(k).q2p5=	prctile(A(rows,:),2.5);
        R(k).q5=	prctile(A(rows,:),5);
        R(k).q25=	prctile(A(rows,:),25);
        R(k).q50=	prctile(A(rows,:),50);
        R(k).q75=	prctile(A(rows,:),75);
        R(k).q95=	prctile(A(rows,:),95);
        R(k).q97p5=	prctile(A(rows,:),97.5);
        R(k).q99=	prctile(A(rows,:),99);
        R.kurt=	kurtosis(A);
        R.skew=	skewness(A);
    end
end