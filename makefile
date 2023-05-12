FLAGS= -DDEBUG
LIBS= -lm
ALWAYS_REBUILD=makefile

nbody: nbody.o compute.o
	gcc $(FLAGS) $^ -o $@ $(LIBS)
nbody.o: nbody.c planets.h config.h vector.h $(ALWAYS_REBUILD)
	gcc $(FLAGS) -c $< 
compute.o: compute.c config.h vector.h $(ALWAYS_REBUILD)
	gcc $(FLAGS) -c $< 
clean:
	rm -f *.o nbody 
parallel_compute.o: parallel_compute.cu config.h vector.h $(ALWAYS_REBUILD)
	nvcc -c parallel_compute.cu -o parallel_compute.o
parallel_nbody: nbody.o parallel_compute.o
	# gcc $(FLAGS) $^ -o $@ $(LIBS)
	nvcc -c nbody.o parallel_compute.o -o parallel_nbody
