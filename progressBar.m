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
    %   PROGRESSBAR works by using queue (if 'parallel.pool.DataQueue' is
    %   available) or creating a file called progressbar.temp in your
    %   working directory to keep track of the loop's progress.
    %   This workaround is necessary because parfor workers cannot
    %   communicate with one another so there is no simple way to know
    %   which iterations have finished and which haven't.
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
    %              pause(0.1);             % Replace with real code
    %              p.progress; %#ok<PFBNS> % Also percent = p.progress;
    %           end
    %           p.stop; % Also percent = p.stop;
    %
    % To suppress running of this class and output with input N<=1:
    %       p = progressBar(N);
    %
    % To get percentage numbers from progress and stop methods call them like:
    %       percent = p.progress;
    %       percent = p.stop;
    %
    % By: Bo Yang (seism.yang@foxmail.com; https://github.com/yuanxzo/Matlab-progressBar)
    %
    % Based on: ProgressBar written by Stefan Doerr;
    %           parfor_progress written by Jeremy Scheff    

    properties
        pname
        width
        times
        state
        
        N
        UseQueue
        Queue
    end
    
    properties (SetAccess = private, GetAccess = public)
        Completed = 0
        Percent   = 0
    end
    
    properties (SetAccess = immutable, GetAccess = private, Transient)
        Listener = []
    end
    
    methods
        function obj = progressBar(N,varargin)
            if N<=1
                obj.state=-1;
                return
            end
            p = inputParser;
            addOptional(p,'pname','UNNAMED PROGRESS')  % progress name, must be a string, default is 'UNNAMED PROGRESS'
            p.parse(varargin{:});
            obj.pname=[p.Results.pname,'. Expected (s): ???', repmat(' ',1,27)];
            
            obj.width = 10; % Width of progress bar
            obj.N=N;
            obj.UseQueue = ~isempty(which('parallel.pool.DataQueue'));
            if obj.UseQueue==1
                % Initialize queue with listener.
                obj.Queue = parallel.pool.DataQueue;
                obj.Listener = obj.Queue.afterEach(@(x) obj.advance(x));
            else
                % Create temporary file that stores the number of completed tasks.
                f = fopen('progressbar.temp', 'w');
                if f<0
                    error('Do you have write permissions for %s?', pwd);
                end
                fprintf(f, '%d\n', N);
                fclose(f);
            end
            obj.times=tic;
            disp(['  0.00%[>', repmat(' ', 1, obj.width), ']',obj.pname]); 
        end
        
        function percent = progress(obj)
            if obj.state==-1
                percent=[];
                return
            end

            if obj.UseQueue==1
                obj.Queue.send('');
            else
                if ~exist('progressbar.temp', 'file')
                    error('progressbar.temp not found. It must have been deleted.');
                end
                
                f = fopen('progressbar.temp', 'a');
                fprintf(f, '1\n');
                fclose(f);
                f = fopen('progressbar.temp', 'r');
                progress = fscanf(f, '%d');
                fclose(f);
                
                percent = (length(progress)-1)/progress(1)*100;
                perc = sprintf('%6.2f%%', percent); % 4 characters wide, percentage
                etime=toc(obj.times);etime=num2str(etime./obj.Percent*(1-obj.Percent));
                obj.pname((end-29):(end-30+length(etime)))=etime;
                disp([repmat(char(8), 1, (obj.width+12+length(obj.pname))), newline, perc,'[', repmat('=', 1, round(percent*obj.width/100)), '>', repmat(' ', 1, obj.width - round(percent*obj.width/100)), ']',obj.pname]); 
            end
        end
        
        function advance(obj,~)
            % Increment the number of completed tasks.
            obj.Completed = obj.Completed+1;
            obj.Percent = obj.Completed/obj.N;
            
            percent = obj.Percent*100;
            perc = sprintf('%6.2f%%', percent); % 4 characters wide, percentage

            etime=toc(obj.times);etime=num2str(etime./obj.Percent*(1-obj.Percent));
            obj.pname((end-29):(end-30+length(etime)))=etime;
            disp([repmat(char(8), 1, (obj.width+12+length(obj.pname))), newline, perc,'[', repmat('=', 1, round(percent*obj.width/100)), '>', repmat(' ', 1, obj.width - round(percent*obj.width/100)), ']',obj.pname]); 
        end
        
        function percent = stop(obj)
            if obj.state==-1
                percent=[];
                return
            end
            
            percent = 100;
            etime=num2str(toc(obj.times));
            obj.pname((end-43):(end-30+length(etime)))=['Executed (s): ',etime];
            disp([repmat(char(8), 1, (obj.width+12+length(obj.pname))), newline, '100.00%[', repmat('=', 1, obj.width+1), ']',obj.pname]);
            
            if obj.UseQueue==1
                delete(obj);
            else
                delete('progressbar.temp');
            end
        end
    end
end
