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
 *******************************************************************************
 * File: primme.i
 * 
 * Purpose - SWIG description of PYTHON interface to PRIMME.
 * 
 ******************************************************************************/

%define DOCSTRING
"Find a few eigenvectors and eigenvalues of a matrix.
Uses PRIMME: https://github.com/primme/primme

Example
-------
>>> import Primme, numpy as np
>>> from scipy.sparse import *
>>> 
>>> # A = [ 2  1  0 ...
>>> #      -1  2 -1 0 ...
>>> #       0 -1  2 -1 0 ... ]
>>> a = np.ones(10)
>>> A = spdiags(np.array([a*(-1.), a*2., a*(-1.)]), np.array([-1, 0, 1]), 10, 10)
>>> 
>>> class PPd(Primme.PrimmeParams):
... 	def __init__(self):
... 		Primme.PrimmeParams.__init__(self)
... 	def matvec(self, X):
... 		return A*X
>>> pp = PPd()
>>> pp.n = A.shape[0]
>>> pp.maxBasisSize = 3
>>> pp.minRestartSize = 1
>>> pp.numEvals = 3
>>> pp.restartingParams.maxPrevRetain = 1
>>> pp.set_method(Primme.DYNAMIC)
>>> pp.display()
>>> evals = np.zeros(pp.numEvals)
>>> evecs = np.zeros((pp.n, pp.numEvals))
>>> norms = np.zeros(pp.numEvals)
>>> print Primme.dprimme(evals, evecs, norms, pp)
>>> print pp.initSize, evals, norms
>>> 
>>> class PPz(Primme.PrimmeParams):
... 	def __init__(self, matrix=None):
... 		Primme.PrimmeParams.__init__(self)
... 		self.mymatrix = matrix
... 	def matvec(self):
... 		return self.mymatrix*X
>>> 
>>> a = np.ones(10, complex)
>>> A = spdiags(np.array([a*(-1.), a*2., a*(-1.)]), np.array([-1, 0, 1]), 10, 10)
>>> pp = PPz(A)
>>> pp.n = A.shape[0]
>>> pp.maxBasisSize = 3
>>> pp.minRestartSize = 1
>>> pp.numEvals = 3
>>> pp.set_method(Primme.DYNAMIC)
>>> pp.display()
>>> evals = np.zeros(pp.numEvals)
>>> evecs = np.zeros((pp.n, pp.numEvals), complex)
>>> norms = np.zeros(pp.numEvals)
>>> print Primme.zprimme(evals, evecs, norms, pp)
>>> print pp.initSize, evals, norms, pp.stats.numMatvecs"
%enddef

%module(docstring=DOCSTRING,directors="1") Primme

%pythoncode %{
__all__ = ['PrimmeParams', 'dprimme', 'zprimme', 'eigsh', 'PRIMMEError', 'PRIMMENoConvergence', 'Arnoldi', 'DEFAULT_METHOD', 'DEFAULT_MIN_MATVECS', 'DEFAULT_MIN_TIME', 'DYNAMIC', 'GD', 'GD_Olsen_plusK', 'GD_plusK', 'JDQMR', 'JDQMR_ETol', 'JDQR', 'JD_Olsen_plusK', 'LOBPCG_OrthoBasis', 'LOBPCG_OrthoBasis_Window', 'RQI', 'SUBSPACE_ITERATION', 'primme_adaptive', 'primme_adaptive_ETolerance', 'primme_closest_abs', 'primme_closest_geq', 'primme_closest_leq', 'primme_decreasing_LTolerance', 'primme_dtr', 'primme_full_LTolerance', 'primme_init_default', 'primme_init_krylov', 'primme_init_random', 'primme_init_user', 'primme_largest', 'primme_largest_abs', 'primme_proj_RR', 'primme_proj_default', 'primme_proj_harmonic', 'primme_proj_refined', 'primme_smallest', 'primme_thick', 'PrimmeSvdsParams', 'primme_svds_augmented', 'primme_svds_closest_abs', 'primme_svds_default', 'primme_svds_hybrid', 'primme_svds_largest', 'primme_svds_normalequations', 'primme_svds_op_AAt', 'primme_svds_op_AtA', 'primme_svds_op_augmented', 'primme_svds_op_none', 'primme_svds_smallest', 'dprimme_svds', 'zprimme_svds']
%}
%{
#define SWIG_FILE_WITH_INIT
#include "primmew.h"
%}

// Get the NumPy typemaps
%include "numpy.i"

// Handle standard exceptions
%include "exception.i"
%exception
{
  try
  {
    $action
  }
  catch (const std::invalid_argument& e)
  {
    SWIG_exception(SWIG_ValueError, e.what());
  }
  catch (const std::out_of_range& e)
  {
    SWIG_exception(SWIG_IndexError, e.what());
  }
  catch (Swig::DirectorException &e)
  {
     SWIG_fail;
  }
}
%init %{
  import_array();
%}

// Global ignores
%ignore PRIMME_MAX_NAME_LENGTH;
%ignore stackTraceNode;
%ignore primme_valloc;
%ignore primme_calloc;
%ignore primme_malloc;
%ignore primme_display_params;
%ignore primme_set_method;
%ignore primme_initialize;
%ignore primme_seq_globalSumDouble;
%ignore primme_PushErrorMessage;
%ignore primme_PrintStackTrace;
%ignore primme_DeleteStackTrace;
%ignore primme_Free;

%ignore primme_svds_display_params;
%ignore primme_svds_set_method;
%ignore primme_svds_initialize;
%ignore primme_svds_seq_globalSumDouble;
%ignore primme_svds_Free;


%rename (dprimme) my_dprimme;
%exception my_dprimme {
    $action
    if (PyErr_Occurred()) SWIG_fail;
}
%rename (zprimme) my_zprimme;
%exception my_zprimme {
    $action
    if (PyErr_Occurred()) SWIG_fail;
}
%rename (dprimme_svds) my_dprimme_svds;
%exception my_dprimme_svds {
    $action
    if (PyErr_Occurred()) SWIG_fail;
}
%rename (zprimme_svds) my_zprimme_svds;
%exception my_zprimme_svds {
    $action
    if (PyErr_Occurred()) SWIG_fail;
}

%fragment("NumPy_Array_Requirements_extra",
          "header",
          fragment="NumPy_Array_Requirements")
{
  /* Require the given PyArrayObject to to be Fortran ordered.  If the
   * the PyArrayObject is already Fortran ordered, do nothing.  Else,
   * set the Fortran ordering flag and recompute the strides.
   * NOTE: based on require_fortran in numpy.i
   */
  int require_fortran2(PyArrayObject* ary, int ld)
  {
    int success = 1;
    if (array_numdims(ary) != 2) return 0;
    int single_dim = (array_size(ary, 0) == 1 || array_size(ary, 1) == 1);
    npy_intp * strides = array_strides(ary);
    if (!array_is_fortran(ary)) {
      strides[0] = strides[1];
      strides[1] = single_dim ? strides[0] : strides[0]*ld;
    } else {
      strides[1] = single_dim ? strides[0] : strides[0]*ld;
    }
    /* Set the Fortran ordered flag */
    /* Note that this should be done after strides change */
    PyArray_UpdateFlags(ary, NPY_ARRAY_FARRAY);
    return success;
  }
}
 
%define %numpy_typemaps_ext(DATA_TYPE, DATA_TYPECODE, DIM_TYPE)

/* Typemap suite for (DIM_TYPE DIM1, DIM_TYPE DIM2, DATA_TYPE* IN_FARRAY2D)
   See description of ARGOUTVIEW_FARRAY2 in numpy.i
 */
%typemap(directorin,
         fragment="NumPy_Backward_Compatibility,NumPy_Array_Requirements_extra,NumPy_Fragments")
  (DIM_TYPE DIM1, DIM_TYPE DIM2, DIM_TYPE LD, DATA_TYPE* IN_FARRAY2D)
{
  npy_intp dims[2] = { $1, $2 };
  PyObject* obj = PyArray_SimpleNewFromData(2, dims, DATA_TYPECODE, (void*)($4));
  PyArrayObject* array = (PyArrayObject*) obj;

  if (!array || !require_fortran2(array, $3))
        throw Swig::DirectorMethodException();
  $input = obj;
}

/* Typemap suite for (DIM_TYPE DIM1, DIM_TYPE DIM2, DATA_TYPE* INPLACE_ARRAY2)
 */
%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY,
           fragment="NumPy_Macros")
  (DIM_TYPE DIM1, DIM_TYPE DIM2, DIM_TYPE LD, DATA_TYPE* OUT_FARRAY2D)
{
  $1 = is_array($input) && PyArray_EquivTypenums(array_type($input),
                                                 DATA_TYPECODE);
}
%typemap(in,numinputs=0)
  (DIM_TYPE DIM1, DIM_TYPE DIM2, DIM_TYPE LD, DATA_TYPE* OUT_FARRAY2D)
{}

%typemap(directorargout,
         fragment="NumPy_Fragments")
  (DIM_TYPE DIM1, DIM_TYPE DIM2, DIM_TYPE LD, DATA_TYPE* OUT_FARRAY2D)
  (PyArrayObject* array=NULL, PyObject* o=NULL)
{
  o = $result;
  if (!is_array(o) || !PyArray_EquivTypenums(array_type(o), DATA_TYPECODE))
     Swig::DirectorMethodException::raise("No valid type for $3_name");
  array = obj_to_array_no_conversion(o, DATA_TYPECODE);
  if (!array || !require_dimensions(array,2) || !require_contiguous(array) ||
      !require_native(array))
          Swig::DirectorMethodException::raise("No valid type for $3_name");
  if (($1) != (DIM_TYPE) array_size(array,0) ||
      ($2) != (DIM_TYPE) array_size(array,1))
          {Swig::DirectorMethodException::raise("No valid dimensions for $3_name");}
  npy_intp * strides = array_strides(array);
  if (array_is_fortran(array)) {
    copy_matrix((DATA_TYPE*)array_data(array), ($1), ($2), strides[1]/strides[0], ($4), ($3));
  } else {
      DATA_TYPE *x = (DATA_TYPE*)array_data(array);
      int ldx = strides[0]/strides[1];
      for (int i=0; i<($1); i++)
         for (int j=0; j<($2); j++)
            ($4)[i+j*($3)] = x[i*ldx+j];
  }
}
%enddef    /* %numpy_typemaps_ext() macro */

%numpy_typemaps_ext(double            , NPY_DOUBLE   , int)
%numpy_typemaps_ext(std::complex<double>, NPY_CDOUBLE, int)


%apply (int DIM1, double* INPLACE_ARRAY1) {
   (int lenEvals, double* evals),
   (int lenSvals, double* svals),
   (int lenResNorms, double* resNorms)};
%apply (int DIM1, int DIM2, double* INPLACE_FARRAY2) {
   (int len1Evecs, int len2Evecs, double* evecs),
   (int len1SvecsLeft, int len2SvecsLeft, double* svecsLeft),
   (int len1SvecsRight, int len2SvecsRight, double* svecsRight)};
%apply (int DIM1, int DIM2, std::complex<double>* INPLACE_FARRAY2) {
   (int len1Evecs, int len2Evecs, std::complex<double>* evecs),
   (int len1SvecsLeft, int len2SvecsLeft, std::complex<double>* svecsLeft),
   (int len1SvecsRight, int len2SvecsRight, std::complex<double>* svecsRight)};
%apply (int* DIM1, int* DIM2, double** ARGOUTVIEW_FARRAY2) {
   (int *len1X, int *len2X, double **x)};
%apply (int* DIM1, int* DIM2, std::complex<double>** ARGOUTVIEW_FARRAY2) {
   (int *len1X, int *len2X, std::complex<double> **x)};
%apply (int DIM1, int DIM2, double* IN_FARRAY2) {
   (int len1Y, int len2Y, double* y)};
%apply (int DIM1, int DIM2, std::complex<double>* IN_FARRAY2) {
   (int len1Y, int len2Y, std::complex<double>* y)};

%apply (int DIM1, int DIM2, int LD, double* IN_FARRAY2D) {
   (int len1YD, int len2YD, int ldYD, double* yd)};
%apply (int DIM1, int DIM2, int LD, double* OUT_FARRAY2D) {
   (int len1XD, int len2XD, int ldXD, double* xd)};
%apply (int DIM1, int DIM2, int LD, std::complex<double>* IN_FARRAY2D) {
   (int len1YD, int len2YD, int ldYD, std::complex<double>* yd)};
%apply (int DIM1, int DIM2, int LD, std::complex<double>* OUT_FARRAY2D) {
   (int len1XD, int len2XD, int ldXD, std::complex<double>* xd)};


%inline %{
template <typename T>
static void copy_matrix(T *x, int m, int n, int ldx, T *y, int ldy) {
   int i,j;

   assert(ldx >= m && ldy >= m);

   /* Do nothing if x and y are the same matrix */
   if (x == y && ldx == ldy) return;

   /* Copy a contiguous memory region */
   if (ldx == ldy && ldx == m) {
      memmove(y, x, sizeof(T)*m*n);
   }

   /* Copy matrix some rows down or up */
   else if (ldx == ldy && (y > x ? y-x : x-y) < ldx) {
      for (i=0; i<n; i++)
         memmove(&y[i*ldy], &x[i*ldx], sizeof(T)*m);
   }

   /* Copy matrix some columns forward */
   else if (ldx == ldy && y > x && y-x > ldx) {
      for (i=n-1; i>=0; i--)
         for (j=0; j<m; j++)
            y[i*ldy+j] = x[i*ldx+j];
   }

   /* Copy matrix some columns backward and the general case */
   else {
      /* TODO: assert x and y don't overlap */
      for (i=0; i<n; i++)
         for (j=0; j<m; j++)
            y[i*ldy+j] = x[i*ldx+j];
   }

}


int my_dprimme(int lenEvals, double *evals,
            int len1Evecs, int len2Evecs, double *evecs,
            int lenResNorms, double *resNorms, 
            PrimmeParams *primme) {
   if (lenEvals < primme->numEvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `evals' should be at least %d",
                     primme->numEvals);
        return -30;
   }
   if (len1Evecs < primme->nLocal || len2Evecs < primme->numEvals) {
        PyErr_Format(PyExc_ValueError,
                     "Size of `evecs' should be at least (%d, %d)",
                     primme->nLocal, primme->numEvals);
        return -31;
   }
   if (lenResNorms < primme->numEvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `resNorms' should be at least %d",
                     primme->numEvals);
        return -32;
   }
   primme->__kind = 1;
   int ret = dprimme(evals, evecs, resNorms, static_cast<primme_params*>(primme));
   return ret;
}

int my_zprimme(int lenEvals, double *evals,
            int len1Evecs, int len2Evecs, std::complex<double> *evecs,
            int lenResNorms, double *resNorms, 
            PrimmeParams *primme) {
   if (lenEvals < primme->numEvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `evals' should be at least %d",
                     primme->numEvals);
        return -30;
   }
   if (len1Evecs < primme->nLocal || len2Evecs < primme->numEvals) {
        PyErr_Format(PyExc_ValueError,
                     "Size of `evecs' should be at least (%d, %d)",
                     primme->nLocal, primme->numEvals);
        return -31;
   }
   if (lenResNorms < primme->numEvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `resNorms' should be at least %d",
                     primme->numEvals);
        return -32;
   }
   primme->__kind = 3;
   int ret = zprimme(evals, (Complex_Z*)evecs, resNorms, static_cast<primme_params*>(primme));
   return ret;
}

int my_dprimme_svds(int lenSvals, double *svals,
            int len1SvecsLeft, int len2SvecsLeft, double *svecsLeft,
            int len1SvecsRight, int len2SvecsRight, double *svecsRight,
            int lenResNorms, double *resNorms, 
            PrimmeSvdsParams *primme_svds) {
   if (lenSvals < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `svals' should be at least %d",
                     primme_svds->numSvals);
        return -30;
   }
   if (len1SvecsLeft < primme_svds->mLocal || len2SvecsLeft < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Size of `svecsleft' should be at least (%d, %d)",
                     primme_svds->mLocal, primme_svds->numSvals);
        return -31;
   }
   if (len1SvecsRight < primme_svds->nLocal || len2SvecsRight < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Size of `svecsright' should be at least (%d, %d)",
                     primme_svds->nLocal, primme_svds->numSvals);
        return -31;
   }
   if (lenResNorms < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `resNorms' should be at least %d",
                     primme_svds->numSvals);
        return -32;
   }
   primme_svds->__kind = 1;
   double *svecs = new double[(primme_svds->nLocal+primme_svds->mLocal)*(primme_svds->numOrthoConst+primme_svds->numSvals)];
   copy_matrix(svecsLeft, primme_svds->mLocal, primme_svds->numOrthoConst,
         len1SvecsLeft, svecs, primme_svds->mLocal);
   copy_matrix(svecsRight, primme_svds->nLocal, primme_svds->numOrthoConst,
         len1SvecsRight, &svecs[primme_svds->numOrthoConst*primme_svds->mLocal],
         primme_svds->nLocal);
   int ret = dprimme_svds(svals, svecs, resNorms, static_cast<primme_svds_params*>(primme_svds));
   copy_matrix(&svecs[primme_svds->mLocal*primme_svds->numOrthoConst],
         primme_svds->mLocal, primme_svds->numSvals,
         primme_svds->mLocal, &svecsLeft[len1SvecsLeft*primme_svds->numOrthoConst], len1SvecsLeft);
   copy_matrix(&svecs[primme_svds->mLocal*(primme_svds->numOrthoConst
            +primme_svds->initSize)
         + primme_svds->nLocal*primme_svds->numOrthoConst], primme_svds->nLocal,
         primme_svds->initSize, primme_svds->nLocal, &svecsRight[len1SvecsRight*primme_svds->numOrthoConst], len1SvecsRight);
    return ret;
}

int my_zprimme_svds(int lenSvals, double *svals,
            int len1SvecsLeft, int len2SvecsLeft, std::complex<double> *svecsLeft,
            int len1SvecsRight, int len2SvecsRight, std::complex<double> *svecsRight,
            int lenResNorms, double *resNorms, 
            PrimmeSvdsParams *primme_svds) {
   if (lenSvals < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `svals' should be at least %d",
                     primme_svds->numSvals);
        return -30;
   }
   if (len1SvecsLeft < primme_svds->mLocal || len2SvecsLeft < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Size of `svecsleft' should be at least (%d, %d)",
                     primme_svds->mLocal, primme_svds->numSvals);
        return -31;
   }
   if (len1SvecsRight < primme_svds->nLocal || len2SvecsRight < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Size of `svecsright' should be at least (%d, %d)",
                     primme_svds->nLocal, primme_svds->numSvals);
        return -31;
   }
   if (lenResNorms < primme_svds->numSvals) {
        PyErr_Format(PyExc_ValueError,
                     "Length of `resNorms' should be at least %d",
                     primme_svds->numSvals);
        return -32;
   }
   primme_svds->__kind = 3;
   std::complex<double> *svecs = new std::complex<double>[(primme_svds->nLocal
         +primme_svds->mLocal)*(primme_svds->numOrthoConst
            +primme_svds->numSvals)];
   copy_matrix(svecsLeft, primme_svds->mLocal, primme_svds->numOrthoConst,
         len1SvecsLeft, svecs, primme_svds->mLocal);
   copy_matrix(svecsRight, primme_svds->nLocal, primme_svds->numOrthoConst,
         len1SvecsRight, &svecs[primme_svds->numOrthoConst*primme_svds->mLocal],
         primme_svds->nLocal);
   int ret = zprimme_svds(svals, (Complex_Z*)svecs, resNorms, static_cast<primme_svds_params*>(primme_svds));
   copy_matrix(&svecs[primme_svds->mLocal*primme_svds->numOrthoConst],
         primme_svds->mLocal, primme_svds->numSvals,
         primme_svds->mLocal, &svecsLeft[len1SvecsLeft*primme_svds->numOrthoConst], len1SvecsLeft);
   copy_matrix(&svecs[primme_svds->mLocal*(primme_svds->numOrthoConst
            +primme_svds->initSize)
         + primme_svds->nLocal*primme_svds->numOrthoConst], primme_svds->nLocal,
         primme_svds->initSize, primme_svds->nLocal, &svecsRight[len1SvecsRight*primme_svds->numOrthoConst], len1SvecsRight);
    return ret;
}
%}


%feature("director") PrimmeParams;
%feature("director") PrimmeSvdsParams;
%feature("director:except") {
    if ($error != NULL) {
        throw Swig::DirectorMethodException();
    }
}
%include "../PRIMMESRC/COMMONSRC/primme.h"
%include "../PRIMMESRC/SVDS/COMMONSRC/primme_svds.h"
%include "primmew.h"

%pythoncode "wrappers.py"
