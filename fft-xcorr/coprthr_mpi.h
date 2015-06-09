/* coprthr_mpi.h
 *
 * Copyright (c) 2014-2015 Brown Deer Technology, LLC.  All Rights Reserved.
 *
 * This software was developed by Brown Deer Technology, LLC.
 * For more information contact info@browndeertechnology.com
 *
 * This software is a preview licensed for non-commercial use only, may not be 
 * redistributed, and may not be reverse-engineered for the purpose of creating
 * software of similar functionality.  The full terms and conditions of the 
 * license may be found in 'LICENSE.txt' accompanying this file.  Licensing 
 * questions may be directed to info@browndeertechnology.com
 * 
 */

/* DAR */

#ifndef __coprthr_mpi
#define __coprthr_mpi

/* Hack so fft-demo knows it included the right header */
#define __coprthr_mpi_fft

#include <coprthr.h>

#if defined(__coprthr_device__)

#ifdef __cplusplus
extern "C" {
#endif

extern int _local_mem_base;

int coprthr_tls_brk( void* addr);

void* coprthr_tls_sbrk( intptr_t increment );

typedef struct {
	int rank;
	int size;
	int ndims;
	int dims[2];
	int coords[2];
	int m_id;
	void* m_mtx;
	int m_src;
	int m_tag;
	int m_count;
	void* m_adr;
	void* m_buf;
	size_t m_bufsize;
	e_coreid_t coreid;
	int row,col;
} _mpi_comm;

typedef _mpi_comm* mpi_comm_t;

int __mpi_init( _mpi_comm* comm, size_t bufsize );

#define mpi_init( pargc, bufsize ) \
	_mpi_comm _MPI_COMM_THREAD; \
	_mpi_comm* MPI_COMM_THREAD = &_MPI_COMM_THREAD; \
	do { __mpi_init( MPI_COMM_THREAD, bufsize ); } while(0)


int __mpi_finalize( _mpi_comm* comm );

#define mpi_finalize() \
	do { __mpi_finalize(MPI_COMM_THREAD); } while(0)
	
typedef int mpi_datatype_t;
#define MPI_CHAR	1
#define MPI_INT		4
#define MPI_FLOAT	4
#define MPI_DOUBLE	8


typedef int mpi_status_t;


int mpi_comm_rank( mpi_comm_t comm, int* rank);


int mpi_comm_size( mpi_comm_t comm, int* size);


int mpi_recv( void* buf, int count, mpi_datatype_t datatype, int source,
	int tag, mpi_comm_t comm, mpi_status_t* status );


int mpi_send( void* buf, int count, mpi_datatype_t datatype, int dest,
	int tag, mpi_comm_t comm );

int mpi_bcast( void* buf, int count, mpi_datatype_t datatype, int root,
	mpi_comm_t comm );

int mpi_cart_create(mpi_comm_t comm_old, int ndims, const int dims[],
   const int periods[], int reorder, mpi_comm_t* comm_cart
);


int mpi_comm_free( mpi_comm_t* comm);


int mpi_cart_coords( mpi_comm_t comm, int rank, int maxdims, int* coords);


int mpi_cart_shift( mpi_comm_t comm, int dir, int disp, int* rank_source, 
	int* rank_dest );

int mpi_sendrecv_replace( void* buf, int count, mpi_datatype_t datatype, 
	int dest, int sendtag, int source, int recvtag, mpi_comm_t comm, 
	mpi_status_t* status );


#define coprthr_mpi_init( pargc, bufsize ) mpi_init( pargc, bufsize )
#define coprthr_mpi_finalize() mpi_finalize()

typedef mpi_comm_t coprthr_mpi_comm_t;
typedef mpi_status_t coprthr_mpi_status_t;
typedef mpi_datatype_t coprthr_mpi_datatype_t;

int coprthr_mpi_comm_rank( coprthr_mpi_comm_t comm, int* rank);

int coprthr_mpi_comm_size( coprthr_mpi_comm_t comm, int* size);

int coprthr_mpi_recv( void* buf, int count, coprthr_mpi_datatype_t datatype, 
	int source, int tag, coprthr_mpi_comm_t comm, 
	coprthr_mpi_status_t* status );

int coprthr_mpi_send( void* buf, int count, coprthr_mpi_datatype_t datatype,
	int dest, int tag, coprthr_mpi_comm_t comm );

int coprthr_mpi_bcast( void* buf, int count, coprthr_mpi_datatype_t datatype,
	int root, coprthr_mpi_comm_t comm );

int coprthr_mpi_cart_create(coprthr_mpi_comm_t comm_old, int ndims, 
	const int dims[], const int periods[], int reorder, 
	coprthr_mpi_comm_t* comm_cart);

int coprthr_mpi_comm_free( coprthr_mpi_comm_t* comm);

int coprthr_mpi_cart_coords( coprthr_mpi_comm_t comm, int rank, 
	int maxdims, int* coords);

int coprthr_mpi_cart_shift( coprthr_mpi_comm_t comm, int dir, int disp, 
	int* rank_source, int* rank_dest );

int coprthr_mpi_sendrecv_replace( void* buf, int count, 
	coprthr_mpi_datatype_t datatype, 
	int dest, int sendtag, int source, int recvtag, 
	coprthr_mpi_comm_t comm, coprthr_mpi_status_t* status );

#ifdef COPRTHR_MPI_COMPAT

#define MPI_Init( pargc, bufsize ) mpi_init( pargc, bufsize )
#define MPI_Finalize() mpi_finalize()

typedef mpi_comm_t MPI_Comm;
typedef mpi_status_t MPI_Status;
typedef mpi_datatype_t MPI_Datatype;

int MPI_Comm_rank( MPI_Comm comm, int* rank);

int MPI_Comm_size( MPI_Comm comm, int* size);

int MPI_Recv( void* buf, int count, MPI_Datatype datatype, int source,
	int tag, MPI_Comm comm, MPI_Status* status );

int MPI_Send( void* buf, int count, MPI_Datatype datatype, int dest,
	int tag, MPI_Comm comm );

int MPI_Bcast( void* buf, int count, MPI_Datatype datatype, int root,
	MPI_Comm comm );

int MPI_Cart_create(MPI_Comm comm_old, int ndims, const int dims[],
	const int periods[], int reorder, MPI_Comm* comm_cart);

int MPI_Comm_free( MPI_Comm* comm);

int MPI_Cart_coords( MPI_Comm comm, int rank, int maxdims, int* coords);

int MPI_Cart_shift( MPI_Comm comm, int dir, int disp, int* rank_source, 
	int* rank_dest );

int MPI_Sendrecv_replace( void* buf, int count, MPI_Datatype datatype, 
	int dest, int sendtag, int source, int recvtag, MPI_Comm comm, 
	MPI_Status* status );

#endif

#ifdef __cplusplus
}
#endif

#else

#ifndef __free
#define __free free
#endif

int coprthr_mpiexec( 
	int dd, unsigned int nthr, 
	coprthr_sym_t thrfunc, void* parg, size_t argsz,
	int flag 
)
{
        coprthr_event_t ev;

	coprthr_mem_t argmem = coprthr_dmalloc(dd,argsz,0);
	ev = coprthr_dwrite(dd,argmem,0,parg,argsz,COPRTHR_E_NOW);
	__coprthr_free_event(ev);
        free(ev);
	coprthr_attr_t attr;
	coprthr_td_t td;
	void* status;
	coprthr_attr_init( &attr );
	coprthr_attr_setdetachstate(&attr,COPRTHR_CREATE_JOINABLE);
	coprthr_attr_setdevice(&attr,dd);
	coprthr_ncreate( nthr, &td, &attr, thrfunc, (void*)&argmem );
	/* TODO: td seems to leak too */
	coprthr_attr_destroy( &attr);
	coprthr_join(td,&status);
	ev = coprthr_dread(dd,argmem,0,parg,argsz,COPRTHR_E_NOW);
	__coprthr_free_event(ev);
	free(ev);
	coprthr_dfree(dd,argmem);
}


#endif

#endif

