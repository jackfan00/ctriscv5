.global _Reset
_Reset:
 la sp, _stack_top
 call main
 j .
