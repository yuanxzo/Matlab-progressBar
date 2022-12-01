% Copyright (c) 2022, Bo Yang
% Copyright (c) 2014, Stefan
% Copyright (c) 2011, Jeremy Scheff
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

classdef progressBar < handle
    %PROGRESSBAR Progress bar class for matlab loops which also works with parfor.
    %   PROGRESSBAR works by creating a file called progressbar.temp in
    %   your working directory, and then keeping track of the loop's
    %   progress within that file. This workaround is necessary because parfor
    %   workers cannot communicate with one another so there is no simple way
    %   to know which iterations have finished and which haven't.
    %
    % METHODS:  progressBar(N); constructs an object and initializes the progress monitor 
    %                           for a set of N upcoming calculations.
    %           progress(); updates the progress inside your loop and
    %                       displays an updated progress bar.
    %           stop(); deletes progressbar.temp and finalizes the 
    %                   progress bar.
    %
    % EXAMPLE: 
    %           N = 100;
    %           p = progressBar(N);
    %           parfor i=1:N
    %              pause(0.1);            % Replace with real code
    %              p.progress; %#ok<PFBNS> % Also percent = p.progress;
    %           end
    %           p.stop; % Also percent = p.stop;
    %
    % To suppress output call constructor with optional parameter 'verbose':
    %       p = progressbar(N,'verbose',0);
    %
    % To get percentage numbers from progress and stop methods call them like:
    %       percent = p.progress;
    %       percent = p.stop;
    %
    % By: Bo Yang
    %
    % Based on: ProgressBar written by Stefan Doerr;
    %           parfor_progress written by Jeremy Scheff    

    properties
        fname
        width
        verbose
        times
        state
    end
    
    methods
        function obj = progressBar(N, varargin)
            if N<=1
                obj.state=-1;
                return
            end
            p = inputParser;
            p.addParameter('verbose',1,@isscalar);
            p.parse(varargin{:});
            obj.verbose = p.Results.verbose;
    
            obj.width = 10; % Width of progress bar

            obj.fname = 'progressbar.temp';
            
            f = fopen(obj.fname, 'w');
            if f<0
                error('Do you have write permissions for %s?', pwd);
            end
            fprintf(f, '%d\n', N); % Save N at the top of progress.txt
            fclose(f);
            obj.times=tic;
            if obj.verbose; disp(['  0%[>', repmat(' ', 1, obj.width), ']']); end
        end
        
        function percent = progress(obj)
            if obj.state==-1
                return
            end
            if ~exist(obj.fname, 'file')
                error([obj.fname ' not found. It must have been deleted.']);
            end

            f = fopen(obj.fname, 'a');
            fprintf(f, '1\n');
            fclose(f);

            f = fopen(obj.fname, 'r');
            progress = fscanf(f, '%d');
            fclose(f);
            percent = (length(progress)-1)/progress(1)*100;

            if obj.verbose
                perc = sprintf('%3.0f%%', percent); % 4 characters wide, percentage
                disp([repmat(char(8), 1, (obj.width+9)), newline, perc, '[', repmat('=', 1, round(percent*obj.width/100)), '>', repmat(' ', 1, obj.width - round(percent*obj.width/100)), ']']);
            end           
        end
        
        function percent = stop(obj)
            if obj.state==-1
                return
            end
            delete(obj.fname);     
            percent = 100;

            if obj.verbose
                disp([repmat(char(8), 1, (obj.width+9)), newline, '100%[', repmat('=', 1, obj.width+1), ']',' Executed in ',num2str(toc(obj.times)),'s, finished.']);
            end
        end
    end
end
