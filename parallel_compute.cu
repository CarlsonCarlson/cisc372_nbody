#include <stdio.h>
#include "vector.h"
#include "config.h"
#include <cuda_runtime.h>
// #include <device_launch_parameters.h>

__global__ void make_accel_matrix(vector3** accels, vector3* values) {
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	accels[idx] = &values[idx*NUMENTITIES];
	// #if __CUDA_ARCH__ >= 200
	// printf("thread %d: %d\n", idx, accels[idx]);
	// #endif
}

//compute: Updates the positions and locations of the objects in the system based on gravity.
//Parameters: None
//Returns: None
//Side Effect: Modifies the hPos and hVel arrays with the new positions and accelerations after 1 INTERVAL
void compute(){
	//make an acceleration matrix which is NUMENTITIES squared in size;
	int i,j,k;
	vector3* values=(vector3*)malloc(sizeof(vector3)*NUMENTITIES*NUMENTITIES);
	vector3** accels=(vector3**)malloc(sizeof(vector3*)*NUMENTITIES);

    // initialize the execution config
    int nProcesses = NUMENTITIES;
    int threadsPerBlock = 1;
    int blocksPerGrid = (nProcesses + threadsPerBlock - 1) / threadsPerBlock;

    // launch kernel (I guess each type of parallelism will have its own kernel)
    // run_kernel<<<gridDimensions, blockDimensions>>>(kernel_args);
    make_accel_matrix<<<blocksPerGrid, threadsPerBlock>>>(accels, values);

    // wait for kernel to finish
    cudaDeviceSynchronize();

	//first compute the pairwise accelerations.  Effect is on the first argument.
	// for (i=0;i<NUMENTITIES;i++){
	// 	for (j=0;j<NUMENTITIES;j++){
	// 		// same entity, no acceleration
	// 		if (i==j) {
	// 			FILL_VECTOR(accels[i][j],0,0,0);
	// 		}
	// 		else{
	// 			// compute distance using distance formula, then acceleration due to gravity
	// 			vector3 distance;
	// 			for (k=0;k<3;k++) distance[k]=hPos[i][k]-hPos[j][k];
	// 			double magnitude_sq=distance[0]*distance[0]+distance[1]*distance[1]+distance[2]*distance[2];
	// 			double magnitude=sqrt(magnitude_sq);
	// 			double accelmag=-1*GRAV_CONSTANT*mass[j]/magnitude_sq;
	// 			FILL_VECTOR(accels[i][j],accelmag*distance[0]/magnitude,accelmag*distance[1]/magnitude,accelmag*distance[2]/magnitude);
	// 		}
	// 	}
	// }
    printf("accel matrix: \n");
	// print the acceleration matrix
	for (i=0;i<NUMENTITIES;i++){
		for (j=0;j<NUMENTITIES;j++){
			printf("%f %f %f\n", accels[i][j][0], accels[i][j][1], accels[i][j][2]);
		}
		printf("\n");
	}

	//sum up the rows of our matrix to get effect on each entity, then update velocity and position.
	// for (i=0;i<NUMENTITIES;i++){
	// 	vector3 accel_sum={0,0,0};
	// 	for (j=0;j<NUMENTITIES;j++){
	// 		for (k=0;k<3;k++)
	// 			accel_sum[k]+=accels[i][j][k];
	// 	}
	// 	//compute the new velocity based on the acceleration and time interval
	// 	//compute the new position based on the velocity and time interval
	// 	for (k=0;k<3;k++){
	// 		hVel[i][k]+=accel_sum[k]*INTERVAL;
	// 		hPos[i][k]=hVel[i][k]*INTERVAL;
	// 	}
	// }
	free(accels);
	free(values);
}
