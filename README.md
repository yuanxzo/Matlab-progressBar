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

Run the above code, the command line window will display: 
> 100%[===========]UNNAMED PROGRESS. Executed in 1.2536s.


With the optional parameter 'pname', you can add a name for each work process you want to see, for example
> N = 10; \
> p = progressBar(N,'pname','This is a test program'); \
> parfor i=1:N \
>   pause(1); % Replace with real code \
>   p.progress; \
> end \
> p.stop; 

Run the above code, the command line window will display: 
> 100%[===========]This is a test program. Executed in 1.0536s.




## Note:
> The program is compatible with for loops
  
> The display of work progress will increase the program time to a certain extent
  
> When the input N is less than or equal to 1, the program will not display the progress, so as to reduce the time cost of the program itself. This design can make it easier to meet the programming requirements of various users.


