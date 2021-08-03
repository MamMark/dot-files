;;;
;;; you may or may not need the source of .environment_bash
;;; not sure what is going on there.
;;;

(setq make-command ". ~/.environment_bash; make -k -Wall")
(setq make-command "gcc -o align -ggdb -Wall -m32 align.c")

(setq gud-gdb-command-name "gdb -i=mi")
(setq make-command "make -k")

(setq make-command "make mm7")
(setq gud-gdb-command-name "arm-none-eabi-gdb-py -i=mi -iex \"target extended-remote localhost:2331\" -cd build/mm6a/ main.exe")

(setq make-command "make dev7")
(setq gud-gdb-command-name "arm-none-eabi-gdb-py -i=mi -iex \"target extended-remote localhost:2331\" -cd build/dev6a/ main.exe")

(setq make-command "make exp_msp432")
(setq gud-gdb-command-name "arm-none-eabi-gdb-py -i=mi -iex \"target extended-remote localhost:2331\" -cd build/exp_msp432/ main.exe")
