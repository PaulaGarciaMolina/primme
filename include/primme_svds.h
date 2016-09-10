/*******************************************************************************
 *   PRIMME PReconditioned Iterative MultiMethod Eigensolver
 *   Copyright (C) 2015 College of William & Mary,
 *   James R. McCombs, Eloy Romero Alcalde, Andreas Stathopoulos, Lingfei Wu
 *
 *   This file is part of PRIMME.
 *
 *   PRIMME is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License, or (at your option) any later version.
 *
 *   PRIMME is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 **********************************************************************
 * File: primme_svds.h
 *
 * Purpose - Main header with the PRIMME SVDS C interface functions.
 *
 ******************************************************************************/


#ifndef PRIMME_SVDS_H
#define PRIMME_SVDS_H

#include "primme_eigs.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
   primme_svds_largest,
   primme_svds_smallest,
   primme_svds_closest_abs
} primme_svds_target;

typedef enum {
   primme_svds_default,
   primme_svds_hybrid,
   primme_svds_normalequations, /* At*A or A*At */
   primme_svds_augmented
} primme_svds_preset_method;

typedef enum {
   primme_svds_op_none,
   primme_svds_op_AtA,
   primme_svds_op_AAt,
   primme_svds_op_augmented
} primme_svds_operator;

typedef struct primme_svds_stats {
   PRIMME_INT numOuterIterations;
   PRIMME_INT numRestarts;
   PRIMME_INT numMatvecs;
   PRIMME_INT numPreconds;
   double elapsedTime;
} primme_svds_stats;

typedef struct primme_svds_params {
   /**** Low interface: configuration for the eigensolver */
   primme_params primme;  /* Keep it as first field to access primme_svds_params from
                             primme_params */
   primme_params primmeStage2; /* other primme_params, used by hybrid */

   /* Specify the size of the rectangular matrix A */
   PRIMME_INT m; /* number of rows */ 
   PRIMME_INT n; /* number of columns */

   /***** High interface: these values are transferred to primme and primmeStage2 properly */
   void (*matrixMatvec) 
      (void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
       int *transpose, struct primme_svds_params *primme_svds, int *ierr);
   void (*applyPreconditioner)
      (void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
       int *transpose, struct primme_svds_params *primme_svds, int *ierr);

   /* Input for the following is only required for parallel programs */
   int numProcs;
   int procID;
   PRIMME_INT mLocal;
   PRIMME_INT nLocal;
   void *commInfo;
   void (*globalSumReal)
      (void *sendBuf, void *recvBuf, int *count,
       struct primme_svds_params *primme_svds, int *ierr);

   /* Though primme_svds_initialize will assign defaults, most users will set these */
   int numSvals;
   primme_svds_target target;
   int numTargetShifts;    /* For primme_svds_augmented method, user has to */ 
   double *targetShifts;   /* make sure  at least one shift must also be set */
   primme_svds_operator method; /* one of primme_svds_AtA, primme_svds_AAt or primme_svds_augmented */
   primme_svds_operator methodStage2; /* hybrid second stage method; accepts the same values as method */

   /* These pointers are not for users but for d/zprimme_svds function */
   int intWorkSize;
   size_t realWorkSize;
   int *intWork;
   void *realWork;

   /* These pointers may be used for users to provide matrix/preconditioner */
   void *matrix;
   void *preconditioner;

   /* The following will be given default values depending on the method */
   int locking;
   int numOrthoConst;
   double aNorm;
   double eps;

   int precondition;
   int initSize;
   int maxBasisSize;
   int maxBlockSize;
   PRIMME_INT maxMatvecs;
   PRIMME_INT iseed[4];
   int printLevel;
   FILE *outputFile;
   struct primme_svds_stats stats;

} primme_svds_params;

int sprimme_svds(float *svals, float *svecs, float *resNorms,
      primme_svds_params *primme_svds);
int cprimme_svds(float *svals, PRIMME_COMPLEX_FLOAT *svecs, float *resNorms,
      primme_svds_params *primme_svds);
int dprimme_svds(double *svals, double *svecs, double *resNorms,
      primme_svds_params *primme_svds);
int zprimme_svds(double *svals, PRIMME_COMPLEX_DOUBLE *svecs, double *resNorms,
      primme_svds_params *primme_svds);
void primme_svds_initialize(primme_svds_params *primme_svds);
int primme_svds_set_method(primme_svds_preset_method method,
      primme_preset_method methodStage1, primme_preset_method methodStage2,
      primme_svds_params *primme_svds);
void primme_svds_display_params(primme_svds_params primme_svds);
void primme_svds_Free(primme_svds_params *primme_svds);

#ifdef __cplusplus
}
#endif

#endif /* PRIMME_SVDS_H */  
