# progressBar
Matlab parfor work progress display program

## Example
> N = 10; \
> p = progressBar(N); \

> parfor i=1:N
>  pause(1); % Replace with real code
>  p.progress; %#ok<PFBNS> 
> end
> p.stop;

Run the above code, the command line window will display:
100%[===========] Executed in 1.5339s, finished.
