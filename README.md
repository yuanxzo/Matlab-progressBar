# progressBar
Matlab parfor work progress display program

## Example
> N = 10; \
> p = progressBar(N); \
> parfor i=1:N \
>   pause(1); % Replace with real code \
>   p.progress; \
> end \
> p.stop; 

Run the above code, the command line window will display: \
> 100%[===========] Executed in 1.5339s, finished.

## Note:
> The program is compatible with for loops
  
> The display of work progress will increase the program time to a certain extent
  
> When the input N is less than or equal to 1, the program will not display the progress, so as to reduce the time cost of the program itself. This design can make it easier to meet the programming requirements of various users.
