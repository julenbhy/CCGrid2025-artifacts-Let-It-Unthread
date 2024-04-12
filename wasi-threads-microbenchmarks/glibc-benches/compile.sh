#call make with TARGET=bench-pthread-lock-base
clear
make TARGET=bench-pthread-locks
make TARGET=bench-pthread-mutex-lock
make TARGET=bench-pthread-mutex-trylock
make TARGET=bench-pthread-spin-lock
make TARGET=bench-pthread-spin-trylock
