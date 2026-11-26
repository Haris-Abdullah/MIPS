# MIPS Programs

The included MIPS programs are intended to run on the MARS simulator.

They are written to demonstrate a few ideas rather than to be optimized. At times I may have chosen a much more complicated way of doing something that would otherwise have been fairly straightforward, just for the sake of learning.

For example, the merge sort program uses indexes instead of moving pointers because I wanted to force myself to run out of temporary registers and figure out how to deal with stack memory in that situation.

Similarly, one could pass arguments in `$a0-$a3` and return values in `$v0` and `$v1`, but I wanted to know what to do when I have to pass and return a lot of values. The solution I came up with was to put them on the stack: the passed values become part of the callee's stack frame, and the returned values become part of the caller's stack frame.
