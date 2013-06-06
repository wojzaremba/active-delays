#ifndef MOSEK_H
#define MOSEK_H

/******************************************************************************
 ** Module : mosek.h
 **
 ** Generated 2012
 **
 ** Copyright (c) 1998-2012 MOSEK ApS, Denmark.
 **
 ** All rights reserved
 **
 ******************************************************************************/


#include <stdlib.h>
#include <stdio.h>

#define MSK_VERSION_MAJOR    6
#define MSK_VERSION_MINOR    0
#define MSK_VERSION_BUILD    0
#define MSK_VERSION_REVISION 137
#define MSK_VERSION_STATE    ""


#ifndef MSKCONST
#define MSKCONST
#endif


#define MSK_INFINITY 1.0e30

/* BEGIN PLATFORM SPECIFIC DEFINITIONS (linux64x86) */
#define MSKAPI   
#define MSKAPIVA 
/* END   PLATFORM SPECIFIC DEFINITIONS (linux64x86) */


/* Enums and constants */
/* namespace mosek { */
enum MSKsolveform_enum {
  MSK_SOLVE_BEGIN  = 0,
  MSK_SOLVE_END    = 3,

  MSK_SOLVE_FREE   = 0,
  MSK_SOLVE_PRIMAL = 1,
  MSK_SOLVE_DUAL   = 2
};

enum MSKaccmode_enum {
  MSK_ACC_BEGIN = 0,
  MSK_ACC_END = 2,

  MSK_ACC_VAR = 0,
  MSK_ACC_CON = 1
};

enum MSKsensitivitytype_enum {
  MSK_SENSITIVITY_TYPE_BEGIN             = 0,
  MSK_SENSITIVITY_TYPE_END               = 2,

  MSK_SENSITIVITY_TYPE_BASIS             = 0,
  MSK_SENSITIVITY_TYPE_OPTIMAL_PARTITION = 1
};

enum MSKqreadtype_enum {
  MSK_Q_READ_BEGIN      = 0,
  MSK_Q_READ_END        = 3,

  MSK_Q_READ_ADD        = 0,
  MSK_Q_READ_DROP_LOWER = 1,
  MSK_Q_READ_DROP_UPPER = 2
};

enum MSKiparam_enum {
  MSK_IPAR_BEGIN                              = 0,
  MSK_IPAR_END                                = 211,

  MSK_IPAR_ALLOC_ADD_QNZ                      = 0,
  MSK_IPAR_ANA_SOL_BASIS                      = 1,
  MSK_IPAR_ANA_SOL_PRINT_VIOLATED             = 2,
  MSK_IPAR_AUTO_SORT_A_BEFORE_OPT             = 3,
  MSK_IPAR_AUTO_UPDATE_SOL_INFO               = 4,
  MSK_IPAR_BASIS_SOLVE_USE_PLUS_ONE           = 5,
  MSK_IPAR_BI_CLEAN_OPTIMIZER                 = 6,
  MSK_IPAR_BI_IGNORE_MAX_ITER                 = 7,
  MSK_IPAR_BI_IGNORE_NUM_ERROR                = 8,
  MSK_IPAR_BI_MAX_ITERATIONS                  = 9,
  MSK_IPAR_CACHE_LICENSE                      = 10,
  MSK_IPAR_CACHE_SIZE_L1                      = 11,
  MSK_IPAR_CACHE_SIZE_L2                      = 12,
  MSK_IPAR_CHECK_CONVEXITY                    = 13,
  MSK_IPAR_CHECK_TASK_DATA                    = 14,
  MSK_IPAR_CONCURRENT_NUM_OPTIMIZERS          = 15,
  MSK_IPAR_CONCURRENT_PRIORITY_DUAL_SIMPLEX   = 16,
  MSK_IPAR_CONCURRENT_PRIORITY_FREE_SIMPLEX   = 17,
  MSK_IPAR_CONCURRENT_PRIORITY_INTPNT         = 18,
  MSK_IPAR_CONCURRENT_PRIORITY_PRIMAL_SIMPLEX = 19,
  MSK_IPAR_CPU_TYPE                           = 20,
  MSK_IPAR_DATA_CHECK                         = 21,
  MSK_IPAR_FEASREPAIR_OPTIMIZE                = 22,
  MSK_IPAR_INFEAS_GENERIC_NAMES               = 23,
  MSK_IPAR_INFEAS_PREFER_PRIMAL               = 24,
  MSK_IPAR_INFEAS_REPORT_AUTO                 = 25,
  MSK_IPAR_INFEAS_REPORT_LEVEL                = 26,
  MSK_IPAR_INTPNT_BASIS                       = 27,
  MSK_IPAR_INTPNT_DIFF_STEP                   = 28,
  MSK_IPAR_INTPNT_FACTOR_DEBUG_LVL            = 29,
  MSK_IPAR_INTPNT_FACTOR_METHOD               = 30,
  MSK_IPAR_INTPNT_MAX_ITERATIONS              = 31,
  MSK_IPAR_INTPNT_MAX_NUM_COR                 = 32,
  MSK_IPAR_INTPNT_MAX_NUM_REFINEMENT_STEPS    = 33,
  MSK_IPAR_INTPNT_NUM_THREADS                 = 34,
  MSK_IPAR_INTPNT_OFF_COL_TRH                 = 35,
  MSK_IPAR_INTPNT_ORDER_METHOD                = 36,
  MSK_IPAR_INTPNT_REGULARIZATION_USE          = 37,
  MSK_IPAR_INTPNT_SCALING                     = 38,
  MSK_IPAR_INTPNT_SOLVE_FORM                  = 39,
  MSK_IPAR_INTPNT_STARTING_POINT              = 40,
  MSK_IPAR_LIC_TRH_EXPIRY_WRN                 = 41,
  MSK_IPAR_LICENSE_ALLOW_OVERUSE              = 42,
  MSK_IPAR_LICENSE_CACHE_TIME                 = 43,
  MSK_IPAR_LICENSE_CHECK_TIME                 = 44,
  MSK_IPAR_LICENSE_DEBUG                      = 45,
  MSK_IPAR_LICENSE_PAUSE_TIME                 = 46,
  MSK_IPAR_LICENSE_SUPPRESS_EXPIRE_WRNS       = 47,
  MSK_IPAR_LICENSE_WAIT                       = 48,
  MSK_IPAR_LOG                                = 49,
  MSK_IPAR_LOG_BI                             = 50,
  MSK_IPAR_LOG_BI_FREQ                        = 51,
  MSK_IPAR_LOG_CHECK_CONVEXITY                = 52,
  MSK_IPAR_LOG_CONCURRENT                     = 53,
  MSK_IPAR_LOG_CUT_SECOND_OPT                 = 54,
  MSK_IPAR_LOG_FACTOR                         = 55,
  MSK_IPAR_LOG_FEASREPAIR                     = 56,
  MSK_IPAR_LOG_FILE                           = 57,
  MSK_IPAR_LOG_HEAD                           = 58,
  MSK_IPAR_LOG_INFEAS_ANA                     = 59,
  MSK_IPAR_LOG_INTPNT                         = 60,
  MSK_IPAR_LOG_MIO                            = 61,
  MSK_IPAR_LOG_MIO_FREQ                       = 62,
  MSK_IPAR_LOG_NONCONVEX                      = 63,
  MSK_IPAR_LOG_OPTIMIZER                      = 64,
  MSK_IPAR_LOG_ORDER                          = 65,
  MSK_IPAR_LOG_PARAM                          = 66,
  MSK_IPAR_LOG_PRESOLVE                       = 67,
  MSK_IPAR_LOG_RESPONSE                       = 68,
  MSK_IPAR_LOG_SENSITIVITY                    = 69,
  MSK_IPAR_LOG_SENSITIVITY_OPT                = 70,
  MSK_IPAR_LOG_SIM                            = 71,
  MSK_IPAR_LOG_SIM_FREQ                       = 72,
  MSK_IPAR_LOG_SIM_MINOR                      = 73,
  MSK_IPAR_LOG_SIM_NETWORK_FREQ               = 74,
  MSK_IPAR_LOG_STORAGE                        = 75,
  MSK_IPAR_LP_WRITE_IGNORE_INCOMPATIBLE_ITEMS = 76,
  MSK_IPAR_MAX_NUM_WARNINGS                   = 77,
  MSK_IPAR_MIO_BRANCH_DIR                     = 78,
  MSK_IPAR_MIO_BRANCH_PRIORITIES_USE          = 79,
  MSK_IPAR_MIO_CONSTRUCT_SOL                  = 80,
  MSK_IPAR_MIO_CONT_SOL                       = 81,
  MSK_IPAR_MIO_CUT_LEVEL_ROOT                 = 82,
  MSK_IPAR_MIO_CUT_LEVEL_TREE                 = 83,
  MSK_IPAR_MIO_FEASPUMP_LEVEL                 = 84,
  MSK_IPAR_MIO_HEURISTIC_LEVEL                = 85,
  MSK_IPAR_MIO_HOTSTART                       = 86,
  MSK_IPAR_MIO_KEEP_BASIS                     = 87,
  MSK_IPAR_MIO_LOCAL_BRANCH_NUMBER            = 88,
  MSK_IPAR_MIO_MAX_NUM_BRANCHES               = 89,
  MSK_IPAR_MIO_MAX_NUM_RELAXS                 = 90,
  MSK_IPAR_MIO_MAX_NUM_SOLUTIONS              = 91,
  MSK_IPAR_MIO_MODE                           = 92,
  MSK_IPAR_MIO_NODE_OPTIMIZER                 = 93,
  MSK_IPAR_MIO_NODE_SELECTION                 = 94,
  MSK_IPAR_MIO_OPTIMIZER_MODE                 = 95,
  MSK_IPAR_MIO_PRESOLVE_AGGREGATE             = 96,
  MSK_IPAR_MIO_PRESOLVE_PROBING               = 97,
  MSK_IPAR_MIO_PRESOLVE_USE                   = 98,
  MSK_IPAR_MIO_ROOT_OPTIMIZER                 = 99,
  MSK_IPAR_MIO_STRONG_BRANCH                  = 100,
  MSK_IPAR_NONCONVEX_MAX_ITERATIONS           = 101,
  MSK_IPAR_OBJECTIVE_SENSE                    = 102,
  MSK_IPAR_OPF_MAX_TERMS_PER_LINE             = 103,
  MSK_IPAR_OPF_WRITE_HEADER                   = 104,
  MSK_IPAR_OPF_WRITE_HINTS                    = 105,
  MSK_IPAR_OPF_WRITE_PARAMETERS               = 106,
  MSK_IPAR_OPF_WRITE_PROBLEM                  = 107,
  MSK_IPAR_OPF_WRITE_SOL_BAS                  = 108,
  MSK_IPAR_OPF_WRITE_SOL_ITG                  = 109,
  MSK_IPAR_OPF_WRITE_SOL_ITR                  = 110,
  MSK_IPAR_OPF_WRITE_SOLUTIONS                = 111,
  MSK_IPAR_OPTIMIZER                          = 112,
  MSK_IPAR_PARAM_READ_CASE_NAME               = 113,
  MSK_IPAR_PARAM_READ_IGN_ERROR               = 114,
  MSK_IPAR_PRESOLVE_ELIM_FILL                 = 115,
  MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES  = 116,
  MSK_IPAR_PRESOLVE_ELIMINATOR_USE            = 117,
  MSK_IPAR_PRESOLVE_LEVEL                     = 118,
  MSK_IPAR_PRESOLVE_LINDEP_USE                = 119,
  MSK_IPAR_PRESOLVE_LINDEP_WORK_LIM           = 120,
  MSK_IPAR_PRESOLVE_USE                       = 121,
  MSK_IPAR_QO_SEPARABLE_REFORMULATION         = 122,
  MSK_IPAR_READ_ADD_ANZ                       = 123,
  MSK_IPAR_READ_ADD_CON                       = 124,
  MSK_IPAR_READ_ADD_CONE                      = 125,
  MSK_IPAR_READ_ADD_QNZ                       = 126,
  MSK_IPAR_READ_ADD_VAR                       = 127,
  MSK_IPAR_READ_ANZ                           = 128,
  MSK_IPAR_READ_CON                           = 129,
  MSK_IPAR_READ_CONE                          = 130,
  MSK_IPAR_READ_DATA_COMPRESSED               = 131,
  MSK_IPAR_READ_DATA_FORMAT                   = 132,
  MSK_IPAR_READ_KEEP_FREE_CON                 = 133,
  MSK_IPAR_READ_LP_DROP_NEW_VARS_IN_BOU       = 134,
  MSK_IPAR_READ_LP_QUOTED_NAMES               = 135,
  MSK_IPAR_READ_MPS_FORMAT                    = 136,
  MSK_IPAR_READ_MPS_KEEP_INT                  = 137,
  MSK_IPAR_READ_MPS_OBJ_SENSE                 = 138,
  MSK_IPAR_READ_MPS_QUOTED_NAMES              = 139,
  MSK_IPAR_READ_MPS_RELAX                     = 140,
  MSK_IPAR_READ_MPS_WIDTH                     = 141,
  MSK_IPAR_READ_Q_MODE                        = 142,
  MSK_IPAR_READ_QNZ                           = 143,
  MSK_IPAR_READ_TASK_IGNORE_PARAM             = 144,
  MSK_IPAR_READ_VAR                           = 145,
  MSK_IPAR_SENSITIVITY_ALL                    = 146,
  MSK_IPAR_SENSITIVITY_OPTIMIZER              = 147,
  MSK_IPAR_SENSITIVITY_TYPE                   = 148,
  MSK_IPAR_SIM_BASIS_FACTOR_USE               = 149,
  MSK_IPAR_SIM_DEGEN                          = 150,
  MSK_IPAR_SIM_DUAL_CRASH                     = 151,
  MSK_IPAR_SIM_DUAL_PHASEONE_METHOD           = 152,
  MSK_IPAR_SIM_DUAL_RESTRICT_SELECTION        = 153,
  MSK_IPAR_SIM_DUAL_SELECTION                 = 154,
  MSK_IPAR_SIM_EXPLOIT_DUPVEC                 = 155,
  MSK_IPAR_SIM_HOTSTART                       = 156,
  MSK_IPAR_SIM_HOTSTART_LU                    = 157,
  MSK_IPAR_SIM_INTEGER                        = 158,
  MSK_IPAR_SIM_MAX_ITERATIONS                 = 159,
  MSK_IPAR_SIM_MAX_NUM_SETBACKS               = 160,
  MSK_IPAR_SIM_NETWORK_DETECT                 = 161,
  MSK_IPAR_SIM_NETWORK_DETECT_HOTSTART        = 162,
  MSK_IPAR_SIM_NETWORK_DETECT_METHOD          = 163,
  MSK_IPAR_SIM_NON_SINGULAR                   = 164,
  MSK_IPAR_SIM_PRIMAL_CRASH                   = 165,
  MSK_IPAR_SIM_PRIMAL_PHASEONE_METHOD         = 166,
  MSK_IPAR_SIM_PRIMAL_RESTRICT_SELECTION      = 167,
  MSK_IPAR_SIM_PRIMAL_SELECTION               = 168,
  MSK_IPAR_SIM_REFACTOR_FREQ                  = 169,
  MSK_IPAR_SIM_REFORMULATION                  = 170,
  MSK_IPAR_SIM_SAVE_LU                        = 171,
  MSK_IPAR_SIM_SCALING                        = 172,
  MSK_IPAR_SIM_SCALING_METHOD                 = 173,
  MSK_IPAR_SIM_SOLVE_FORM                     = 174,
  MSK_IPAR_SIM_STABILITY_PRIORITY             = 175,
  MSK_IPAR_SIM_SWITCH_OPTIMIZER               = 176,
  MSK_IPAR_SOL_FILTER_KEEP_BASIC              = 177,
  MSK_IPAR_SOL_FILTER_KEEP_RANGED             = 178,
  MSK_IPAR_SOL_QUOTED_NAMES                   = 179,
  MSK_IPAR_SOL_READ_NAME_WIDTH                = 180,
  MSK_IPAR_SOL_READ_WIDTH                     = 181,
  MSK_IPAR_SOLUTION_CALLBACK                  = 182,
  MSK_IPAR_TIMING_LEVEL                       = 183,
  MSK_IPAR_WARNING_LEVEL                      = 184,
  MSK_IPAR_WRITE_BAS_CONSTRAINTS              = 185,
  MSK_IPAR_WRITE_BAS_HEAD                     = 186,
  MSK_IPAR_WRITE_BAS_VARIABLES                = 187,
  MSK_IPAR_WRITE_DATA_COMPRESSED              = 188,
  MSK_IPAR_WRITE_DATA_FORMAT                  = 189,
  MSK_IPAR_WRITE_DATA_PARAM                   = 190,
  MSK_IPAR_WRITE_FREE_CON                     = 191,
  MSK_IPAR_WRITE_GENERIC_NAMES                = 192,
  MSK_IPAR_WRITE_GENERIC_NAMES_IO             = 193,
  MSK_IPAR_WRITE_INT_CONSTRAINTS              = 194,
  MSK_IPAR_WRITE_INT_HEAD                     = 195,
  MSK_IPAR_WRITE_INT_VARIABLES                = 196,
  MSK_IPAR_WRITE_LP_LINE_WIDTH                = 197,
  MSK_IPAR_WRITE_LP_QUOTED_NAMES              = 198,
  MSK_IPAR_WRITE_LP_STRICT_FORMAT             = 199,
  MSK_IPAR_WRITE_LP_TERMS_PER_LINE            = 200,
  MSK_IPAR_WRITE_MPS_INT                      = 201,
  MSK_IPAR_WRITE_MPS_OBJ_SENSE                = 202,
  MSK_IPAR_WRITE_MPS_QUOTED_NAMES             = 203,
  MSK_IPAR_WRITE_MPS_STRICT                   = 204,
  MSK_IPAR_WRITE_PRECISION                    = 205,
  MSK_IPAR_WRITE_SOL_CONSTRAINTS              = 206,
  MSK_IPAR_WRITE_SOL_HEAD                     = 207,
  MSK_IPAR_WRITE_SOL_VARIABLES                = 208,
  MSK_IPAR_WRITE_TASK_INC_SOL                 = 209,
  MSK_IPAR_WRITE_XML_MODE                     = 210
};

enum MSKadopcode_enum {
  MSK_ADOP_BEGIN = 0,
  MSK_ADOP_END = 8,

  MSK_ADOP_ADD = 0,
  MSK_ADOP_SUB = 1,
  MSK_ADOP_MUL = 2,
  MSK_ADOP_DIV = 3,
  MSK_ADOP_POW = 4,
  MSK_ADOP_EXP = 5,
  MSK_ADOP_LOG = 6,
  MSK_ADOP_RET = 7
};

enum MSKsolsta_enum {
  MSK_SOL_STA_BEGIN                   = 0,
  MSK_SOL_STA_END                     = 16,

  MSK_SOL_STA_UNKNOWN                 = 0,
  MSK_SOL_STA_OPTIMAL                 = 1,
  MSK_SOL_STA_PRIM_FEAS               = 2,
  MSK_SOL_STA_DUAL_FEAS               = 3,
  MSK_SOL_STA_PRIM_AND_DUAL_FEAS      = 4,
  MSK_SOL_STA_PRIM_INFEAS_CER         = 5,
  MSK_SOL_STA_DUAL_INFEAS_CER         = 6,
  MSK_SOL_STA_NEAR_OPTIMAL            = 8,
  MSK_SOL_STA_NEAR_PRIM_FEAS          = 9,
  MSK_SOL_STA_NEAR_DUAL_FEAS          = 10,
  MSK_SOL_STA_NEAR_PRIM_AND_DUAL_FEAS = 11,
  MSK_SOL_STA_NEAR_PRIM_INFEAS_CER    = 12,
  MSK_SOL_STA_NEAR_DUAL_INFEAS_CER    = 13,
  MSK_SOL_STA_INTEGER_OPTIMAL         = 14,
  MSK_SOL_STA_NEAR_INTEGER_OPTIMAL    = 15
};

enum MSKobjsense_enum {
  MSK_OBJECTIVE_SENSE_BEGIN     = 0,
  MSK_OBJECTIVE_SENSE_END       = 3,

  MSK_OBJECTIVE_SENSE_UNDEFINED = 0,
  MSK_OBJECTIVE_SENSE_MINIMIZE  = 1,
  MSK_OBJECTIVE_SENSE_MAXIMIZE  = 2
};

enum MSKsolitem_enum {
  MSK_SOL_ITEM_BEGIN = 0,
  MSK_SOL_ITEM_END = 8,

  MSK_SOL_ITEM_XC  = 0,
  MSK_SOL_ITEM_XX  = 1,
  MSK_SOL_ITEM_Y   = 2,
  MSK_SOL_ITEM_SLC = 3,
  MSK_SOL_ITEM_SUC = 4,
  MSK_SOL_ITEM_SLX = 5,
  MSK_SOL_ITEM_SUX = 6,
  MSK_SOL_ITEM_SNX = 7
};

enum MSKboundkey_enum {
  MSK_BK_BEGIN = 0,
  MSK_BK_END = 5,

  MSK_BK_LO = 0,
  MSK_BK_UP = 1,
  MSK_BK_FX = 2,
  MSK_BK_FR = 3,
  MSK_BK_RA = 4
};

enum MSKbasindtype_enum {
  MSK_BI_BEGIN       = 0,
  MSK_BI_END         = 5,

  MSK_BI_NEVER       = 0,
  MSK_BI_ALWAYS      = 1,
  MSK_BI_NO_ERROR    = 2,
  MSK_BI_IF_FEASIBLE = 3,
  MSK_BI_OTHER       = 4
};

enum MSKbranchdir_enum {
  MSK_BRANCH_DIR_BEGIN = 0,
  MSK_BRANCH_DIR_END  = 3,

  MSK_BRANCH_DIR_FREE = 0,
  MSK_BRANCH_DIR_UP   = 1,
  MSK_BRANCH_DIR_DOWN = 2
};

enum MSKliinfitem_enum {
  MSK_LIINF_BEGIN                         = 0,
  MSK_LIINF_END                           = 14,

  MSK_LIINF_BI_CLEAN_DUAL_DEG_ITER        = 0,
  MSK_LIINF_BI_CLEAN_DUAL_ITER            = 1,
  MSK_LIINF_BI_CLEAN_PRIMAL_DEG_ITER      = 2,
  MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_DEG_ITER = 3,
  MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_ITER     = 4,
  MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_SUB_ITER = 5,
  MSK_LIINF_BI_CLEAN_PRIMAL_ITER          = 6,
  MSK_LIINF_BI_DUAL_ITER                  = 7,
  MSK_LIINF_BI_PRIMAL_ITER                = 8,
  MSK_LIINF_INTPNT_FACTOR_NUM_NZ          = 9,
  MSK_LIINF_MIO_INTPNT_ITER               = 10,
  MSK_LIINF_MIO_SIMPLEX_ITER              = 11,
  MSK_LIINF_RD_NUMANZ                     = 12,
  MSK_LIINF_RD_NUMQNZ                     = 13
};

enum MSKstreamtype_enum {
  MSK_STREAM_BEGIN = 0,
  MSK_STREAM_END = 4,

  MSK_STREAM_LOG = 0,
  MSK_STREAM_MSG = 1,
  MSK_STREAM_ERR = 2,
  MSK_STREAM_WRN = 3
};

enum MSKsimhotstart_enum {
  MSK_SIM_HOTSTART_BEGIN       = 0,
  MSK_SIM_HOTSTART_END         = 3,

  MSK_SIM_HOTSTART_NONE        = 0,
  MSK_SIM_HOTSTART_FREE        = 1,
  MSK_SIM_HOTSTART_STATUS_KEYS = 2
};

enum MSKcallbackcode_enum {
  MSK_CALLBACK_BEGIN                         = 0,
  MSK_CALLBACK_END                           = 117,

  MSK_CALLBACK_BEGIN_BI                      = 0,
  MSK_CALLBACK_BEGIN_CONCURRENT              = 1,
  MSK_CALLBACK_BEGIN_CONIC                   = 2,
  MSK_CALLBACK_BEGIN_DUAL_BI                 = 3,
  MSK_CALLBACK_BEGIN_DUAL_SENSITIVITY        = 4,
  MSK_CALLBACK_BEGIN_DUAL_SETUP_BI           = 5,
  MSK_CALLBACK_BEGIN_DUAL_SIMPLEX            = 6,
  MSK_CALLBACK_BEGIN_DUAL_SIMPLEX_BI         = 7,
  MSK_CALLBACK_BEGIN_FULL_CONVEXITY_CHECK    = 8,
  MSK_CALLBACK_BEGIN_INFEAS_ANA              = 9,
  MSK_CALLBACK_BEGIN_INTPNT                  = 10,
  MSK_CALLBACK_BEGIN_LICENSE_WAIT            = 11,
  MSK_CALLBACK_BEGIN_MIO                     = 12,
  MSK_CALLBACK_BEGIN_NETWORK_DUAL_SIMPLEX    = 13,
  MSK_CALLBACK_BEGIN_NETWORK_PRIMAL_SIMPLEX  = 14,
  MSK_CALLBACK_BEGIN_NETWORK_SIMPLEX         = 15,
  MSK_CALLBACK_BEGIN_NONCONVEX               = 16,
  MSK_CALLBACK_BEGIN_OPTIMIZER               = 17,
  MSK_CALLBACK_BEGIN_PRESOLVE                = 18,
  MSK_CALLBACK_BEGIN_PRIMAL_BI               = 19,
  MSK_CALLBACK_BEGIN_PRIMAL_DUAL_SIMPLEX     = 20,
  MSK_CALLBACK_BEGIN_PRIMAL_DUAL_SIMPLEX_BI  = 21,
  MSK_CALLBACK_BEGIN_PRIMAL_SENSITIVITY      = 22,
  MSK_CALLBACK_BEGIN_PRIMAL_SETUP_BI         = 23,
  MSK_CALLBACK_BEGIN_PRIMAL_SIMPLEX          = 24,
  MSK_CALLBACK_BEGIN_PRIMAL_SIMPLEX_BI       = 25,
  MSK_CALLBACK_BEGIN_QCQO_REFORMULATE        = 26,
  MSK_CALLBACK_BEGIN_READ                    = 27,
  MSK_CALLBACK_BEGIN_SIMPLEX                 = 28,
  MSK_CALLBACK_BEGIN_SIMPLEX_BI              = 29,
  MSK_CALLBACK_BEGIN_SIMPLEX_NETWORK_DETECT  = 30,
  MSK_CALLBACK_BEGIN_WRITE                   = 31,
  MSK_CALLBACK_CONIC                         = 32,
  MSK_CALLBACK_DUAL_SIMPLEX                  = 33,
  MSK_CALLBACK_END_BI                        = 34,
  MSK_CALLBACK_END_CONCURRENT                = 35,
  MSK_CALLBACK_END_CONIC                     = 36,
  MSK_CALLBACK_END_DUAL_BI                   = 37,
  MSK_CALLBACK_END_DUAL_SENSITIVITY          = 38,
  MSK_CALLBACK_END_DUAL_SETUP_BI             = 39,
  MSK_CALLBACK_END_DUAL_SIMPLEX              = 40,
  MSK_CALLBACK_END_DUAL_SIMPLEX_BI           = 41,
  MSK_CALLBACK_END_FULL_CONVEXITY_CHECK      = 42,
  MSK_CALLBACK_END_INFEAS_ANA                = 43,
  MSK_CALLBACK_END_INTPNT                    = 44,
  MSK_CALLBACK_END_LICENSE_WAIT              = 45,
  MSK_CALLBACK_END_MIO                       = 46,
  MSK_CALLBACK_END_NETWORK_DUAL_SIMPLEX      = 47,
  MSK_CALLBACK_END_NETWORK_PRIMAL_SIMPLEX    = 48,
  MSK_CALLBACK_END_NETWORK_SIMPLEX           = 49,
  MSK_CALLBACK_END_NONCONVEX                 = 50,
  MSK_CALLBACK_END_OPTIMIZER                 = 51,
  MSK_CALLBACK_END_PRESOLVE                  = 52,
  MSK_CALLBACK_END_PRIMAL_BI                 = 53,
  MSK_CALLBACK_END_PRIMAL_DUAL_SIMPLEX       = 54,
  MSK_CALLBACK_END_PRIMAL_DUAL_SIMPLEX_BI    = 55,
  MSK_CALLBACK_END_PRIMAL_SENSITIVITY        = 56,
  MSK_CALLBACK_END_PRIMAL_SETUP_BI           = 57,
  MSK_CALLBACK_END_PRIMAL_SIMPLEX            = 58,
  MSK_CALLBACK_END_PRIMAL_SIMPLEX_BI         = 59,
  MSK_CALLBACK_END_QCQO_REFORMULATE          = 60,
  MSK_CALLBACK_END_READ                      = 61,
  MSK_CALLBACK_END_SIMPLEX                   = 62,
  MSK_CALLBACK_END_SIMPLEX_BI                = 63,
  MSK_CALLBACK_END_SIMPLEX_NETWORK_DETECT    = 64,
  MSK_CALLBACK_END_WRITE                     = 65,
  MSK_CALLBACK_IM_BI                         = 66,
  MSK_CALLBACK_IM_CONIC                      = 67,
  MSK_CALLBACK_IM_DUAL_BI                    = 68,
  MSK_CALLBACK_IM_DUAL_SENSIVITY             = 69,
  MSK_CALLBACK_IM_DUAL_SIMPLEX               = 70,
  MSK_CALLBACK_IM_FULL_CONVEXITY_CHECK       = 71,
  MSK_CALLBACK_IM_INTPNT                     = 72,
  MSK_CALLBACK_IM_LICENSE_WAIT               = 73,
  MSK_CALLBACK_IM_LU                         = 74,
  MSK_CALLBACK_IM_MIO                        = 75,
  MSK_CALLBACK_IM_MIO_DUAL_SIMPLEX           = 76,
  MSK_CALLBACK_IM_MIO_INTPNT                 = 77,
  MSK_CALLBACK_IM_MIO_PRESOLVE               = 78,
  MSK_CALLBACK_IM_MIO_PRIMAL_SIMPLEX         = 79,
  MSK_CALLBACK_IM_NETWORK_DUAL_SIMPLEX       = 80,
  MSK_CALLBACK_IM_NETWORK_PRIMAL_SIMPLEX     = 81,
  MSK_CALLBACK_IM_NONCONVEX                  = 82,
  MSK_CALLBACK_IM_ORDER                      = 83,
  MSK_CALLBACK_IM_PRESOLVE                   = 84,
  MSK_CALLBACK_IM_PRIMAL_BI                  = 85,
  MSK_CALLBACK_IM_PRIMAL_DUAL_SIMPLEX        = 86,
  MSK_CALLBACK_IM_PRIMAL_SENSIVITY           = 87,
  MSK_CALLBACK_IM_PRIMAL_SIMPLEX             = 88,
  MSK_CALLBACK_IM_QO_REFORMULATE             = 89,
  MSK_CALLBACK_IM_SIMPLEX                    = 90,
  MSK_CALLBACK_IM_SIMPLEX_BI                 = 91,
  MSK_CALLBACK_INTPNT                        = 92,
  MSK_CALLBACK_NEW_INT_MIO                   = 93,
  MSK_CALLBACK_NONCOVEX                      = 94,
  MSK_CALLBACK_PRIMAL_SIMPLEX                = 95,
  MSK_CALLBACK_QCONE                         = 96,
  MSK_CALLBACK_READ_ADD_ANZ                  = 97,
  MSK_CALLBACK_READ_ADD_CONES                = 98,
  MSK_CALLBACK_READ_ADD_CONS                 = 99,
  MSK_CALLBACK_READ_ADD_QNZ                  = 100,
  MSK_CALLBACK_READ_ADD_VARS                 = 101,
  MSK_CALLBACK_READ_OPF                      = 102,
  MSK_CALLBACK_READ_OPF_SECTION              = 103,
  MSK_CALLBACK_UPDATE_DUAL_BI                = 104,
  MSK_CALLBACK_UPDATE_DUAL_SIMPLEX           = 105,
  MSK_CALLBACK_UPDATE_DUAL_SIMPLEX_BI        = 106,
  MSK_CALLBACK_UPDATE_NETWORK_DUAL_SIMPLEX   = 107,
  MSK_CALLBACK_UPDATE_NETWORK_PRIMAL_SIMPLEX = 108,
  MSK_CALLBACK_UPDATE_NONCONVEX              = 109,
  MSK_CALLBACK_UPDATE_PRESOLVE               = 110,
  MSK_CALLBACK_UPDATE_PRIMAL_BI              = 111,
  MSK_CALLBACK_UPDATE_PRIMAL_DUAL_SIMPLEX    = 112,
  MSK_CALLBACK_UPDATE_PRIMAL_DUAL_SIMPLEX_BI = 113,
  MSK_CALLBACK_UPDATE_PRIMAL_SIMPLEX         = 114,
  MSK_CALLBACK_UPDATE_PRIMAL_SIMPLEX_BI      = 115,
  MSK_CALLBACK_WRITE_OPF                     = 116
};

enum MSKproblemitem_enum {
  MSK_PI_BEGIN = 0,
  MSK_PI_END  = 3,

  MSK_PI_VAR  = 0,
  MSK_PI_CON  = 1,
  MSK_PI_CONE = 2
};

enum MSKfeature_enum {
  MSK_FEATURE_BEGIN = 0,
  MSK_FEATURE_END  = 4,

  MSK_FEATURE_PTS  = 0,
  MSK_FEATURE_PTON = 1,
  MSK_FEATURE_PTOM = 2,
  MSK_FEATURE_PTOX = 3
};

enum MSKsparam_enum {
  MSK_SPAR_BEGIN                     = 0,
  MSK_SPAR_END                       = 25,

  MSK_SPAR_BAS_SOL_FILE_NAME         = 0,
  MSK_SPAR_DATA_FILE_NAME            = 1,
  MSK_SPAR_DEBUG_FILE_NAME           = 2,
  MSK_SPAR_FEASREPAIR_NAME_PREFIX    = 3,
  MSK_SPAR_FEASREPAIR_NAME_SEPARATOR = 4,
  MSK_SPAR_FEASREPAIR_NAME_WSUMVIOL  = 5,
  MSK_SPAR_INT_SOL_FILE_NAME         = 6,
  MSK_SPAR_ITR_SOL_FILE_NAME         = 7,
  MSK_SPAR_PARAM_COMMENT_SIGN        = 8,
  MSK_SPAR_PARAM_READ_FILE_NAME      = 9,
  MSK_SPAR_PARAM_WRITE_FILE_NAME     = 10,
  MSK_SPAR_READ_MPS_BOU_NAME         = 11,
  MSK_SPAR_READ_MPS_OBJ_NAME         = 12,
  MSK_SPAR_READ_MPS_RAN_NAME         = 13,
  MSK_SPAR_READ_MPS_RHS_NAME         = 14,
  MSK_SPAR_SENSITIVITY_FILE_NAME     = 15,
  MSK_SPAR_SENSITIVITY_RES_FILE_NAME = 16,
  MSK_SPAR_SOL_FILTER_XC_LOW         = 17,
  MSK_SPAR_SOL_FILTER_XC_UPR         = 18,
  MSK_SPAR_SOL_FILTER_XX_LOW         = 19,
  MSK_SPAR_SOL_FILTER_XX_UPR         = 20,
  MSK_SPAR_STAT_FILE_NAME            = 21,
  MSK_SPAR_STAT_KEY                  = 22,
  MSK_SPAR_STAT_NAME                 = 23,
  MSK_SPAR_WRITE_LP_GEN_VAR_NAME     = 24
};

enum MSKmark_enum {
  MSK_MARK_BEGIN = 0,
  MSK_MARK_END = 2,

  MSK_MARK_LO = 0,
  MSK_MARK_UP = 1
};

enum MSKconetype_enum {
  MSK_CT_BEGIN = 0,
  MSK_CT_END   = 2,

  MSK_CT_QUAD  = 0,
  MSK_CT_RQUAD = 1
};

enum MSKfeasrepairtype_enum {
  MSK_FEASREPAIR_BEGIN             = 0,
  MSK_FEASREPAIR_END               = 3,

  MSK_FEASREPAIR_OPTIMIZE_NONE     = 0,
  MSK_FEASREPAIR_OPTIMIZE_PENALTY  = 1,
  MSK_FEASREPAIR_OPTIMIZE_COMBINED = 2
};

enum MSKiomode_enum {
  MSK_IOMODE_BEGIN     = 0,
  MSK_IOMODE_END       = 3,

  MSK_IOMODE_READ      = 0,
  MSK_IOMODE_WRITE     = 1,
  MSK_IOMODE_READWRITE = 2
};

enum MSKadoptype_enum {
  MSK_ADOPTYPE_BEGIN     = 0,
  MSK_ADOPTYPE_END       = 4,

  MSK_ADOPTYPE_NONE      = 0,
  MSK_ADOPTYPE_CONSTANT  = 1,
  MSK_ADOPTYPE_VARIABLE  = 2,
  MSK_ADOPTYPE_REFERENCE = 3
};

enum MSKsimseltype_enum {
  MSK_SIM_SELECTION_BEGIN   = 0,
  MSK_SIM_SELECTION_END     = 6,

  MSK_SIM_SELECTION_FREE    = 0,
  MSK_SIM_SELECTION_FULL    = 1,
  MSK_SIM_SELECTION_ASE     = 2,
  MSK_SIM_SELECTION_DEVEX   = 3,
  MSK_SIM_SELECTION_SE      = 4,
  MSK_SIM_SELECTION_PARTIAL = 5
};

enum MSKmsgkey_enum {
  MSK_MSG_READING_FILE = 1000,
  MSK_MSG_WRITING_FILE = 1001,
  MSK_MSG_MPS_SELECTED = 1100
};

enum MSKmiomode_enum {
  MSK_MIO_MODE_BEGIN     = 0,
  MSK_MIO_MODE_END       = 3,

  MSK_MIO_MODE_IGNORED   = 0,
  MSK_MIO_MODE_SATISFIED = 1,
  MSK_MIO_MODE_LAZY      = 2
};

enum MSKdinfitem_enum {
  MSK_DINF_BEGIN                      = 0,
  MSK_DINF_END                        = 62,

  MSK_DINF_BI_CLEAN_DUAL_TIME         = 0,
  MSK_DINF_BI_CLEAN_PRIMAL_DUAL_TIME  = 1,
  MSK_DINF_BI_CLEAN_PRIMAL_TIME       = 2,
  MSK_DINF_BI_CLEAN_TIME              = 3,
  MSK_DINF_BI_DUAL_TIME               = 4,
  MSK_DINF_BI_PRIMAL_TIME             = 5,
  MSK_DINF_BI_TIME                    = 6,
  MSK_DINF_CONCURRENT_TIME            = 7,
  MSK_DINF_INTPNT_DUAL_FEAS           = 8,
  MSK_DINF_INTPNT_DUAL_OBJ            = 9,
  MSK_DINF_INTPNT_FACTOR_NUM_FLOPS    = 10,
  MSK_DINF_INTPNT_KAP_DIV_TAU         = 11,
  MSK_DINF_INTPNT_ORDER_TIME          = 12,
  MSK_DINF_INTPNT_PRIMAL_FEAS         = 13,
  MSK_DINF_INTPNT_PRIMAL_OBJ          = 14,
  MSK_DINF_INTPNT_TIME                = 15,
  MSK_DINF_MIO_CONSTRUCT_SOLUTION_OBJ = 16,
  MSK_DINF_MIO_HEURISTIC_TIME         = 17,
  MSK_DINF_MIO_OBJ_ABS_GAP            = 18,
  MSK_DINF_MIO_OBJ_BOUND              = 19,
  MSK_DINF_MIO_OBJ_INT                = 20,
  MSK_DINF_MIO_OBJ_REL_GAP            = 21,
  MSK_DINF_MIO_OPTIMIZER_TIME         = 22,
  MSK_DINF_MIO_ROOT_OPTIMIZER_TIME    = 23,
  MSK_DINF_MIO_ROOT_PRESOLVE_TIME     = 24,
  MSK_DINF_MIO_TIME                   = 25,
  MSK_DINF_MIO_USER_OBJ_CUT           = 26,
  MSK_DINF_OPTIMIZER_TIME             = 27,
  MSK_DINF_PRESOLVE_ELI_TIME          = 28,
  MSK_DINF_PRESOLVE_LINDEP_TIME       = 29,
  MSK_DINF_PRESOLVE_TIME              = 30,
  MSK_DINF_QCQO_REFORMULATE_TIME      = 31,
  MSK_DINF_RD_TIME                    = 32,
  MSK_DINF_SIM_DUAL_TIME              = 33,
  MSK_DINF_SIM_FEAS                   = 34,
  MSK_DINF_SIM_NETWORK_DUAL_TIME      = 35,
  MSK_DINF_SIM_NETWORK_PRIMAL_TIME    = 36,
  MSK_DINF_SIM_NETWORK_TIME           = 37,
  MSK_DINF_SIM_OBJ                    = 38,
  MSK_DINF_SIM_PRIMAL_DUAL_TIME       = 39,
  MSK_DINF_SIM_PRIMAL_TIME            = 40,
  MSK_DINF_SIM_TIME                   = 41,
  MSK_DINF_SOL_BAS_DUAL_OBJ           = 42,
  MSK_DINF_SOL_BAS_MAX_DBI            = 43,
  MSK_DINF_SOL_BAS_MAX_DEQI           = 44,
  MSK_DINF_SOL_BAS_MAX_PBI            = 45,
  MSK_DINF_SOL_BAS_MAX_PEQI           = 46,
  MSK_DINF_SOL_BAS_MAX_PINTI          = 47,
  MSK_DINF_SOL_BAS_PRIMAL_OBJ         = 48,
  MSK_DINF_SOL_INT_MAX_PBI            = 49,
  MSK_DINF_SOL_INT_MAX_PEQI           = 50,
  MSK_DINF_SOL_INT_MAX_PINTI          = 51,
  MSK_DINF_SOL_INT_PRIMAL_OBJ         = 52,
  MSK_DINF_SOL_ITR_DUAL_OBJ           = 53,
  MSK_DINF_SOL_ITR_MAX_DBI            = 54,
  MSK_DINF_SOL_ITR_MAX_DCNI           = 55,
  MSK_DINF_SOL_ITR_MAX_DEQI           = 56,
  MSK_DINF_SOL_ITR_MAX_PBI            = 57,
  MSK_DINF_SOL_ITR_MAX_PCNI           = 58,
  MSK_DINF_SOL_ITR_MAX_PEQI           = 59,
  MSK_DINF_SOL_ITR_MAX_PINTI          = 60,
  MSK_DINF_SOL_ITR_PRIMAL_OBJ         = 61
};

enum MSKparametertype_enum {
  MSK_PAR_BEGIN        = 0,
  MSK_PAR_END          = 4,

  MSK_PAR_INVALID_TYPE = 0,
  MSK_PAR_DOU_TYPE     = 1,
  MSK_PAR_INT_TYPE     = 2,
  MSK_PAR_STR_TYPE     = 3
};

enum MSKrescodetype_enum {
  MSK_RESPONSE_BEGIN = 0,
  MSK_RESPONSE_END = 5,

  MSK_RESPONSE_OK  = 0,
  MSK_RESPONSE_WRN = 1,
  MSK_RESPONSE_TRM = 2,
  MSK_RESPONSE_ERR = 3,
  MSK_RESPONSE_UNK = 4
};

enum MSKprosta_enum {
  MSK_PRO_STA_BEGIN                    = 0,
  MSK_PRO_STA_END                      = 12,

  MSK_PRO_STA_UNKNOWN                  = 0,
  MSK_PRO_STA_PRIM_AND_DUAL_FEAS       = 1,
  MSK_PRO_STA_PRIM_FEAS                = 2,
  MSK_PRO_STA_DUAL_FEAS                = 3,
  MSK_PRO_STA_PRIM_INFEAS              = 4,
  MSK_PRO_STA_DUAL_INFEAS              = 5,
  MSK_PRO_STA_PRIM_AND_DUAL_INFEAS     = 6,
  MSK_PRO_STA_ILL_POSED                = 7,
  MSK_PRO_STA_NEAR_PRIM_AND_DUAL_FEAS  = 8,
  MSK_PRO_STA_NEAR_PRIM_FEAS           = 9,
  MSK_PRO_STA_NEAR_DUAL_FEAS           = 10,
  MSK_PRO_STA_PRIM_INFEAS_OR_UNBOUNDED = 11
};

enum MSKscalingtype_enum {
  MSK_SCALING_BEGIN      = 0,
  MSK_SCALING_END        = 4,

  MSK_SCALING_FREE       = 0,
  MSK_SCALING_NONE       = 1,
  MSK_SCALING_MODERATE   = 2,
  MSK_SCALING_AGGRESSIVE = 3
};

enum MSKrescode_enum {
  MSK_RES_OK                                     = 0,
  MSK_RES_WRN_OPEN_PARAM_FILE                    = 50,
  MSK_RES_WRN_LARGE_BOUND                        = 51,
  MSK_RES_WRN_LARGE_LO_BOUND                     = 52,
  MSK_RES_WRN_LARGE_UP_BOUND                     = 53,
  MSK_RES_WRN_LARGE_CON_FX                       = 54,
  MSK_RES_WRN_LARGE_CJ                           = 57,
  MSK_RES_WRN_LARGE_AIJ                          = 62,
  MSK_RES_WRN_ZERO_AIJ                           = 63,
  MSK_RES_WRN_NAME_MAX_LEN                       = 65,
  MSK_RES_WRN_SPAR_MAX_LEN                       = 66,
  MSK_RES_WRN_MPS_SPLIT_RHS_VECTOR               = 70,
  MSK_RES_WRN_MPS_SPLIT_RAN_VECTOR               = 71,
  MSK_RES_WRN_MPS_SPLIT_BOU_VECTOR               = 72,
  MSK_RES_WRN_LP_OLD_QUAD_FORMAT                 = 80,
  MSK_RES_WRN_LP_DROP_VARIABLE                   = 85,
  MSK_RES_WRN_NZ_IN_UPR_TRI                      = 200,
  MSK_RES_WRN_DROPPED_NZ_QOBJ                    = 201,
  MSK_RES_WRN_IGNORE_INTEGER                     = 250,
  MSK_RES_WRN_NO_GLOBAL_OPTIMIZER                = 251,
  MSK_RES_WRN_MIO_INFEASIBLE_FINAL               = 270,
  MSK_RES_WRN_SOL_FILTER                         = 300,
  MSK_RES_WRN_UNDEF_SOL_FILE_NAME                = 350,
  MSK_RES_WRN_SOL_FILE_IGNORED_CON               = 351,
  MSK_RES_WRN_SOL_FILE_IGNORED_VAR               = 352,
  MSK_RES_WRN_TOO_FEW_BASIS_VARS                 = 400,
  MSK_RES_WRN_TOO_MANY_BASIS_VARS                = 405,
  MSK_RES_WRN_LICENSE_EXPIRE                     = 500,
  MSK_RES_WRN_LICENSE_SERVER                     = 501,
  MSK_RES_WRN_EMPTY_NAME                         = 502,
  MSK_RES_WRN_USING_GENERIC_NAMES                = 503,
  MSK_RES_WRN_LICENSE_FEATURE_EXPIRE             = 505,
  MSK_RES_WRN_ZEROS_IN_SPARSE_ROW                = 705,
  MSK_RES_WRN_ZEROS_IN_SPARSE_COL                = 710,
  MSK_RES_WRN_INCOMPLETE_LINEAR_DEPENDENCY_CHECK = 800,
  MSK_RES_WRN_ELIMINATOR_SPACE                   = 801,
  MSK_RES_WRN_PRESOLVE_OUTOFSPACE                = 802,
  MSK_RES_WRN_PRESOLVE_BAD_PRECISION             = 803,
  MSK_RES_WRN_WRITE_DISCARDED_CFIX               = 804,
  MSK_RES_WRN_CONSTRUCT_SOLUTION_INFEAS          = 805,
  MSK_RES_WRN_CONSTRUCT_INVALID_SOL_ITG          = 807,
  MSK_RES_WRN_CONSTRUCT_NO_SOL_ITG               = 810,
  MSK_RES_WRN_ANA_LARGE_BOUNDS                   = 900,
  MSK_RES_WRN_ANA_C_ZERO                         = 901,
  MSK_RES_WRN_ANA_EMPTY_COLS                     = 902,
  MSK_RES_WRN_ANA_CLOSE_BOUNDS                   = 903,
  MSK_RES_WRN_ANA_ALMOST_INT_BOUNDS              = 904,
  MSK_RES_ERR_LICENSE                            = 1000,
  MSK_RES_ERR_LICENSE_EXPIRED                    = 1001,
  MSK_RES_ERR_LICENSE_VERSION                    = 1002,
  MSK_RES_ERR_SIZE_LICENSE                       = 1005,
  MSK_RES_ERR_PROB_LICENSE                       = 1006,
  MSK_RES_ERR_FILE_LICENSE                       = 1007,
  MSK_RES_ERR_MISSING_LICENSE_FILE               = 1008,
  MSK_RES_ERR_SIZE_LICENSE_CON                   = 1010,
  MSK_RES_ERR_SIZE_LICENSE_VAR                   = 1011,
  MSK_RES_ERR_SIZE_LICENSE_INTVAR                = 1012,
  MSK_RES_ERR_OPTIMIZER_LICENSE                  = 1013,
  MSK_RES_ERR_FLEXLM                             = 1014,
  MSK_RES_ERR_LICENSE_SERVER                     = 1015,
  MSK_RES_ERR_LICENSE_MAX                        = 1016,
  MSK_RES_ERR_LICENSE_MOSEKLM_DAEMON             = 1017,
  MSK_RES_ERR_LICENSE_FEATURE                    = 1018,
  MSK_RES_ERR_PLATFORM_NOT_LICENSED              = 1019,
  MSK_RES_ERR_LICENSE_CANNOT_ALLOCATE            = 1020,
  MSK_RES_ERR_LICENSE_CANNOT_CONNECT             = 1021,
  MSK_RES_ERR_LICENSE_INVALID_HOSTID             = 1025,
  MSK_RES_ERR_LICENSE_SERVER_VERSION             = 1026,
  MSK_RES_ERR_LICENSE_NO_SERVER_SUPPORT          = 1027,
  MSK_RES_ERR_OPEN_DL                            = 1030,
  MSK_RES_ERR_OLDER_DLL                          = 1035,
  MSK_RES_ERR_NEWER_DLL                          = 1036,
  MSK_RES_ERR_LINK_FILE_DLL                      = 1040,
  MSK_RES_ERR_THREAD_MUTEX_INIT                  = 1045,
  MSK_RES_ERR_THREAD_MUTEX_LOCK                  = 1046,
  MSK_RES_ERR_THREAD_MUTEX_UNLOCK                = 1047,
  MSK_RES_ERR_THREAD_CREATE                      = 1048,
  MSK_RES_ERR_THREAD_COND_INIT                   = 1049,
  MSK_RES_ERR_UNKNOWN                            = 1050,
  MSK_RES_ERR_SPACE                              = 1051,
  MSK_RES_ERR_FILE_OPEN                          = 1052,
  MSK_RES_ERR_FILE_READ                          = 1053,
  MSK_RES_ERR_FILE_WRITE                         = 1054,
  MSK_RES_ERR_DATA_FILE_EXT                      = 1055,
  MSK_RES_ERR_INVALID_FILE_NAME                  = 1056,
  MSK_RES_ERR_INVALID_SOL_FILE_NAME              = 1057,
  MSK_RES_ERR_INVALID_MBT_FILE                   = 1058,
  MSK_RES_ERR_END_OF_FILE                        = 1059,
  MSK_RES_ERR_NULL_ENV                           = 1060,
  MSK_RES_ERR_NULL_TASK                          = 1061,
  MSK_RES_ERR_INVALID_STREAM                     = 1062,
  MSK_RES_ERR_NO_INIT_ENV                        = 1063,
  MSK_RES_ERR_INVALID_TASK                       = 1064,
  MSK_RES_ERR_NULL_POINTER                       = 1065,
  MSK_RES_ERR_LIVING_TASKS                       = 1066,
  MSK_RES_ERR_BLANK_NAME                         = 1070,
  MSK_RES_ERR_DUP_NAME                           = 1071,
  MSK_RES_ERR_INVALID_OBJ_NAME                   = 1075,
  MSK_RES_ERR_SPACE_LEAKING                      = 1080,
  MSK_RES_ERR_SPACE_NO_INFO                      = 1081,
  MSK_RES_ERR_READ_FORMAT                        = 1090,
  MSK_RES_ERR_MPS_FILE                           = 1100,
  MSK_RES_ERR_MPS_INV_FIELD                      = 1101,
  MSK_RES_ERR_MPS_INV_MARKER                     = 1102,
  MSK_RES_ERR_MPS_NULL_CON_NAME                  = 1103,
  MSK_RES_ERR_MPS_NULL_VAR_NAME                  = 1104,
  MSK_RES_ERR_MPS_UNDEF_CON_NAME                 = 1105,
  MSK_RES_ERR_MPS_UNDEF_VAR_NAME                 = 1106,
  MSK_RES_ERR_MPS_INV_CON_KEY                    = 1107,
  MSK_RES_ERR_MPS_INV_BOUND_KEY                  = 1108,
  MSK_RES_ERR_MPS_INV_SEC_NAME                   = 1109,
  MSK_RES_ERR_MPS_NO_OBJECTIVE                   = 1110,
  MSK_RES_ERR_MPS_SPLITTED_VAR                   = 1111,
  MSK_RES_ERR_MPS_MUL_CON_NAME                   = 1112,
  MSK_RES_ERR_MPS_MUL_QSEC                       = 1113,
  MSK_RES_ERR_MPS_MUL_QOBJ                       = 1114,
  MSK_RES_ERR_MPS_INV_SEC_ORDER                  = 1115,
  MSK_RES_ERR_MPS_MUL_CSEC                       = 1116,
  MSK_RES_ERR_MPS_CONE_TYPE                      = 1117,
  MSK_RES_ERR_MPS_CONE_OVERLAP                   = 1118,
  MSK_RES_ERR_MPS_CONE_REPEAT                    = 1119,
  MSK_RES_ERR_MPS_INVALID_OBJSENSE               = 1122,
  MSK_RES_ERR_MPS_TAB_IN_FIELD2                  = 1125,
  MSK_RES_ERR_MPS_TAB_IN_FIELD3                  = 1126,
  MSK_RES_ERR_MPS_TAB_IN_FIELD5                  = 1127,
  MSK_RES_ERR_MPS_INVALID_OBJ_NAME               = 1128,
  MSK_RES_ERR_ORD_INVALID_BRANCH_DIR             = 1130,
  MSK_RES_ERR_ORD_INVALID                        = 1131,
  MSK_RES_ERR_LP_INCOMPATIBLE                    = 1150,
  MSK_RES_ERR_LP_EMPTY                           = 1151,
  MSK_RES_ERR_LP_DUP_SLACK_NAME                  = 1152,
  MSK_RES_ERR_WRITE_MPS_INVALID_NAME             = 1153,
  MSK_RES_ERR_LP_INVALID_VAR_NAME                = 1154,
  MSK_RES_ERR_LP_FREE_CONSTRAINT                 = 1155,
  MSK_RES_ERR_WRITE_OPF_INVALID_VAR_NAME         = 1156,
  MSK_RES_ERR_LP_FILE_FORMAT                     = 1157,
  MSK_RES_ERR_WRITE_LP_FORMAT                    = 1158,
  MSK_RES_ERR_READ_LP_MISSING_END_TAG            = 1159,
  MSK_RES_ERR_LP_FORMAT                          = 1160,
  MSK_RES_ERR_WRITE_LP_NON_UNIQUE_NAME           = 1161,
  MSK_RES_ERR_READ_LP_NONEXISTING_NAME           = 1162,
  MSK_RES_ERR_LP_WRITE_CONIC_PROBLEM             = 1163,
  MSK_RES_ERR_LP_WRITE_GECO_PROBLEM              = 1164,
  MSK_RES_ERR_WRITING_FILE                       = 1166,
  MSK_RES_ERR_OPF_FORMAT                         = 1168,
  MSK_RES_ERR_OPF_NEW_VARIABLE                   = 1169,
  MSK_RES_ERR_INVALID_NAME_IN_SOL_FILE           = 1170,
  MSK_RES_ERR_LP_INVALID_CON_NAME                = 1171,
  MSK_RES_ERR_OPF_PREMATURE_EOF                  = 1172,
  MSK_RES_ERR_ARGUMENT_LENNEQ                    = 1197,
  MSK_RES_ERR_ARGUMENT_TYPE                      = 1198,
  MSK_RES_ERR_NR_ARGUMENTS                       = 1199,
  MSK_RES_ERR_IN_ARGUMENT                        = 1200,
  MSK_RES_ERR_ARGUMENT_DIMENSION                 = 1201,
  MSK_RES_ERR_INDEX_IS_TOO_SMALL                 = 1203,
  MSK_RES_ERR_INDEX_IS_TOO_LARGE                 = 1204,
  MSK_RES_ERR_PARAM_NAME                         = 1205,
  MSK_RES_ERR_PARAM_NAME_DOU                     = 1206,
  MSK_RES_ERR_PARAM_NAME_INT                     = 1207,
  MSK_RES_ERR_PARAM_NAME_STR                     = 1208,
  MSK_RES_ERR_PARAM_INDEX                        = 1210,
  MSK_RES_ERR_PARAM_IS_TOO_LARGE                 = 1215,
  MSK_RES_ERR_PARAM_IS_TOO_SMALL                 = 1216,
  MSK_RES_ERR_PARAM_VALUE_STR                    = 1217,
  MSK_RES_ERR_PARAM_TYPE                         = 1218,
  MSK_RES_ERR_INF_DOU_INDEX                      = 1219,
  MSK_RES_ERR_INF_INT_INDEX                      = 1220,
  MSK_RES_ERR_INDEX_ARR_IS_TOO_SMALL             = 1221,
  MSK_RES_ERR_INDEX_ARR_IS_TOO_LARGE             = 1222,
  MSK_RES_ERR_INF_LINT_INDEX                     = 1225,
  MSK_RES_ERR_INF_DOU_NAME                       = 1230,
  MSK_RES_ERR_INF_INT_NAME                       = 1231,
  MSK_RES_ERR_INF_TYPE                           = 1232,
  MSK_RES_ERR_INF_LINT_NAME                      = 1234,
  MSK_RES_ERR_INDEX                              = 1235,
  MSK_RES_ERR_WHICHSOL                           = 1236,
  MSK_RES_ERR_SOLITEM                            = 1237,
  MSK_RES_ERR_WHICHITEM_NOT_ALLOWED              = 1238,
  MSK_RES_ERR_MAXNUMCON                          = 1240,
  MSK_RES_ERR_MAXNUMVAR                          = 1241,
  MSK_RES_ERR_MAXNUMQNZ                          = 1243,
  MSK_RES_ERR_NUMCONLIM                          = 1250,
  MSK_RES_ERR_NUMVARLIM                          = 1251,
  MSK_RES_ERR_TOO_SMALL_MAXNUMANZ                = 1252,
  MSK_RES_ERR_INV_APTRE                          = 1253,
  MSK_RES_ERR_MUL_A_ELEMENT                      = 1254,
  MSK_RES_ERR_INV_BK                             = 1255,
  MSK_RES_ERR_INV_BKC                            = 1256,
  MSK_RES_ERR_INV_BKX                            = 1257,
  MSK_RES_ERR_INV_VAR_TYPE                       = 1258,
  MSK_RES_ERR_SOLVER_PROBTYPE                    = 1259,
  MSK_RES_ERR_OBJECTIVE_RANGE                    = 1260,
  MSK_RES_ERR_FIRST                              = 1261,
  MSK_RES_ERR_LAST                               = 1262,
  MSK_RES_ERR_NEGATIVE_SURPLUS                   = 1263,
  MSK_RES_ERR_NEGATIVE_APPEND                    = 1264,
  MSK_RES_ERR_UNDEF_SOLUTION                     = 1265,
  MSK_RES_ERR_BASIS                              = 1266,
  MSK_RES_ERR_INV_SKC                            = 1267,
  MSK_RES_ERR_INV_SKX                            = 1268,
  MSK_RES_ERR_INV_SK_STR                         = 1269,
  MSK_RES_ERR_INV_SK                             = 1270,
  MSK_RES_ERR_INV_CONE_TYPE_STR                  = 1271,
  MSK_RES_ERR_INV_CONE_TYPE                      = 1272,
  MSK_RES_ERR_INV_SKN                            = 1274,
  MSK_RES_ERR_INVALID_SURPLUS                    = 1275,
  MSK_RES_ERR_INV_NAME_ITEM                      = 1280,
  MSK_RES_ERR_PRO_ITEM                           = 1281,
  MSK_RES_ERR_INVALID_FORMAT_TYPE                = 1283,
  MSK_RES_ERR_FIRSTI                             = 1285,
  MSK_RES_ERR_LASTI                              = 1286,
  MSK_RES_ERR_FIRSTJ                             = 1287,
  MSK_RES_ERR_LASTJ                              = 1288,
  MSK_RES_ERR_NONLINEAR_EQUALITY                 = 1290,
  MSK_RES_ERR_NONCONVEX                          = 1291,
  MSK_RES_ERR_NONLINEAR_RANGED                   = 1292,
  MSK_RES_ERR_CON_Q_NOT_PSD                      = 1293,
  MSK_RES_ERR_CON_Q_NOT_NSD                      = 1294,
  MSK_RES_ERR_OBJ_Q_NOT_PSD                      = 1295,
  MSK_RES_ERR_OBJ_Q_NOT_NSD                      = 1296,
  MSK_RES_ERR_ARGUMENT_PERM_ARRAY                = 1299,
  MSK_RES_ERR_CONE_INDEX                         = 1300,
  MSK_RES_ERR_CONE_SIZE                          = 1301,
  MSK_RES_ERR_CONE_OVERLAP                       = 1302,
  MSK_RES_ERR_CONE_REP_VAR                       = 1303,
  MSK_RES_ERR_MAXNUMCONE                         = 1304,
  MSK_RES_ERR_CONE_TYPE                          = 1305,
  MSK_RES_ERR_CONE_TYPE_STR                      = 1306,
  MSK_RES_ERR_REMOVE_CONE_VARIABLE               = 1310,
  MSK_RES_ERR_SOL_FILE_INVALID_NUMBER            = 1350,
  MSK_RES_ERR_HUGE_C                             = 1375,
  MSK_RES_ERR_HUGE_AIJ                           = 1380,
  MSK_RES_ERR_INFINITE_BOUND                     = 1400,
  MSK_RES_ERR_INV_QOBJ_SUBI                      = 1401,
  MSK_RES_ERR_INV_QOBJ_SUBJ                      = 1402,
  MSK_RES_ERR_INV_QOBJ_VAL                       = 1403,
  MSK_RES_ERR_INV_QCON_SUBK                      = 1404,
  MSK_RES_ERR_INV_QCON_SUBI                      = 1405,
  MSK_RES_ERR_INV_QCON_SUBJ                      = 1406,
  MSK_RES_ERR_INV_QCON_VAL                       = 1407,
  MSK_RES_ERR_QCON_SUBI_TOO_SMALL                = 1408,
  MSK_RES_ERR_QCON_SUBI_TOO_LARGE                = 1409,
  MSK_RES_ERR_QOBJ_UPPER_TRIANGLE                = 1415,
  MSK_RES_ERR_QCON_UPPER_TRIANGLE                = 1417,
  MSK_RES_ERR_FIXED_BOUND_VALUES                 = 1425,
  MSK_RES_ERR_USER_FUNC_RET                      = 1430,
  MSK_RES_ERR_USER_FUNC_RET_DATA                 = 1431,
  MSK_RES_ERR_USER_NLO_FUNC                      = 1432,
  MSK_RES_ERR_USER_NLO_EVAL                      = 1433,
  MSK_RES_ERR_USER_NLO_EVAL_HESSUBI              = 1440,
  MSK_RES_ERR_USER_NLO_EVAL_HESSUBJ              = 1441,
  MSK_RES_ERR_INVALID_OBJECTIVE_SENSE            = 1445,
  MSK_RES_ERR_UNDEFINED_OBJECTIVE_SENSE          = 1446,
  MSK_RES_ERR_Y_IS_UNDEFINED                     = 1449,
  MSK_RES_ERR_NAN_IN_DOUBLE_DATA                 = 1450,
  MSK_RES_ERR_NAN_IN_BLC                         = 1461,
  MSK_RES_ERR_NAN_IN_BUC                         = 1462,
  MSK_RES_ERR_NAN_IN_C                           = 1470,
  MSK_RES_ERR_NAN_IN_BLX                         = 1471,
  MSK_RES_ERR_NAN_IN_BUX                         = 1472,
  MSK_RES_ERR_NAN_IN_AIJ                         = 1473,
  MSK_RES_ERR_INV_PROBLEM                        = 1500,
  MSK_RES_ERR_MIXED_PROBLEM                      = 1501,
  MSK_RES_ERR_INV_OPTIMIZER                      = 1550,
  MSK_RES_ERR_MIO_NO_OPTIMIZER                   = 1551,
  MSK_RES_ERR_NO_OPTIMIZER_VAR_TYPE              = 1552,
  MSK_RES_ERR_MIO_NOT_LOADED                     = 1553,
  MSK_RES_ERR_POSTSOLVE                          = 1580,
  MSK_RES_ERR_OVERFLOW                           = 1590,
  MSK_RES_ERR_NO_BASIS_SOL                       = 1600,
  MSK_RES_ERR_BASIS_FACTOR                       = 1610,
  MSK_RES_ERR_BASIS_SINGULAR                     = 1615,
  MSK_RES_ERR_FACTOR                             = 1650,
  MSK_RES_ERR_FEASREPAIR_CANNOT_RELAX            = 1700,
  MSK_RES_ERR_FEASREPAIR_SOLVING_RELAXED         = 1701,
  MSK_RES_ERR_FEASREPAIR_INCONSISTENT_BOUND      = 1702,
  MSK_RES_ERR_NAME_MAX_LEN                       = 1750,
  MSK_RES_ERR_NAME_IS_NULL                       = 1760,
  MSK_RES_ERR_INVALID_COMPRESSION                = 1800,
  MSK_RES_ERR_INVALID_IOMODE                     = 1801,
  MSK_RES_ERR_NO_PRIMAL_INFEAS_CER               = 2000,
  MSK_RES_ERR_NO_DUAL_INFEAS_CER                 = 2001,
  MSK_RES_ERR_NO_SOLUTION_IN_CALLBACK            = 2500,
  MSK_RES_ERR_INV_MARKI                          = 2501,
  MSK_RES_ERR_INV_MARKJ                          = 2502,
  MSK_RES_ERR_INV_NUMI                           = 2503,
  MSK_RES_ERR_INV_NUMJ                           = 2504,
  MSK_RES_ERR_CANNOT_CLONE_NL                    = 2505,
  MSK_RES_ERR_CANNOT_HANDLE_NL                   = 2506,
  MSK_RES_ERR_INVALID_ACCMODE                    = 2520,
  MSK_RES_ERR_MBT_INCOMPATIBLE                   = 2550,
  MSK_RES_ERR_LU_MAX_NUM_TRIES                   = 2800,
  MSK_RES_ERR_INVALID_UTF8                       = 2900,
  MSK_RES_ERR_INVALID_WCHAR                      = 2901,
  MSK_RES_ERR_NO_DUAL_FOR_ITG_SOL                = 2950,
  MSK_RES_ERR_INTERNAL                           = 3000,
  MSK_RES_ERR_API_ARRAY_TOO_SMALL                = 3001,
  MSK_RES_ERR_API_CB_CONNECT                     = 3002,
  MSK_RES_ERR_API_FATAL_ERROR                    = 3005,
  MSK_RES_ERR_SEN_FORMAT                         = 3050,
  MSK_RES_ERR_SEN_UNDEF_NAME                     = 3051,
  MSK_RES_ERR_SEN_INDEX_RANGE                    = 3052,
  MSK_RES_ERR_SEN_BOUND_INVALID_UP               = 3053,
  MSK_RES_ERR_SEN_BOUND_INVALID_LO               = 3054,
  MSK_RES_ERR_SEN_INDEX_INVALID                  = 3055,
  MSK_RES_ERR_SEN_INVALID_REGEXP                 = 3056,
  MSK_RES_ERR_SEN_SOLUTION_STATUS                = 3057,
  MSK_RES_ERR_SEN_NUMERICAL                      = 3058,
  MSK_RES_ERR_CONCURRENT_OPTIMIZER               = 3059,
  MSK_RES_ERR_UNB_STEP_SIZE                      = 3100,
  MSK_RES_ERR_IDENTICAL_TASKS                    = 3101,
  MSK_RES_ERR_AD_INVALID_CODELIST                = 3102,
  MSK_RES_ERR_AD_INVALID_OPERATOR                = 3103,
  MSK_RES_ERR_AD_INVALID_OPERAND                 = 3104,
  MSK_RES_ERR_AD_MISSING_OPERAND                 = 3105,
  MSK_RES_ERR_AD_MISSING_RETURN                  = 3106,
  MSK_RES_ERR_INVALID_BRANCH_DIRECTION           = 3200,
  MSK_RES_ERR_INVALID_BRANCH_PRIORITY            = 3201,
  MSK_RES_ERR_INTERNAL_TEST_FAILED               = 3500,
  MSK_RES_ERR_XML_INVALID_PROBLEM_TYPE           = 3600,
  MSK_RES_ERR_INVALID_AMPL_STUB                  = 3700,
  MSK_RES_ERR_INT64_TO_INT32_CAST                = 3800,
  MSK_RES_ERR_SIZE_LICENSE_NUMCORES              = 3900,
  MSK_RES_ERR_INFEAS_UNDEFINED                   = 3910,
  MSK_RES_ERR_API_INTERNAL                       = 3999,
  MSK_RES_TRM_MAX_ITERATIONS                     = 4000,
  MSK_RES_TRM_MAX_TIME                           = 4001,
  MSK_RES_TRM_OBJECTIVE_RANGE                    = 4002,
  MSK_RES_TRM_MIO_NEAR_REL_GAP                   = 4003,
  MSK_RES_TRM_MIO_NEAR_ABS_GAP                   = 4004,
  MSK_RES_TRM_USER_BREAK                         = 4005,
  MSK_RES_TRM_STALL                              = 4006,
  MSK_RES_TRM_USER_CALLBACK                      = 4007,
  MSK_RES_TRM_MIO_NUM_RELAXS                     = 4008,
  MSK_RES_TRM_MIO_NUM_BRANCHES                   = 4009,
  MSK_RES_TRM_NUM_MAX_NUM_INT_SOLUTIONS          = 4015,
  MSK_RES_TRM_MAX_NUM_SETBACKS                   = 4020,
  MSK_RES_TRM_NUMERICAL_PROBLEM                  = 4025,
  MSK_RES_TRM_INTERNAL                           = 4030,
  MSK_RES_TRM_INTERNAL_STOP                      = 4031
};

enum MSKmionodeseltype_enum {
  MSK_MIO_NODE_SELECTION_BEGIN  = 0,
  MSK_MIO_NODE_SELECTION_END    = 6,

  MSK_MIO_NODE_SELECTION_FREE   = 0,
  MSK_MIO_NODE_SELECTION_FIRST  = 1,
  MSK_MIO_NODE_SELECTION_BEST   = 2,
  MSK_MIO_NODE_SELECTION_WORST  = 3,
  MSK_MIO_NODE_SELECTION_HYBRID = 4,
  MSK_MIO_NODE_SELECTION_PSEUDO = 5
};

enum MSKonoffkey_enum {
  MSK_BEGIN = 0,
  MSK_END = 2,

  MSK_OFF = 0,
  MSK_ON  = 1
};

enum MSKsimdegen_enum {
  MSK_SIM_DEGEN_BEGIN      = 0,
  MSK_SIM_DEGEN_END        = 5,

  MSK_SIM_DEGEN_NONE       = 0,
  MSK_SIM_DEGEN_FREE       = 1,
  MSK_SIM_DEGEN_AGGRESSIVE = 2,
  MSK_SIM_DEGEN_MODERATE   = 3,
  MSK_SIM_DEGEN_MINIMUM    = 4
};

enum MSKdataformat_enum {
  MSK_DATA_FORMAT_BEGIN     = 0,
  MSK_DATA_FORMAT_END       = 7,

  MSK_DATA_FORMAT_EXTENSION = 0,
  MSK_DATA_FORMAT_MPS       = 1,
  MSK_DATA_FORMAT_LP        = 2,
  MSK_DATA_FORMAT_MBT       = 3,
  MSK_DATA_FORMAT_OP        = 4,
  MSK_DATA_FORMAT_XML       = 5,
  MSK_DATA_FORMAT_FREE_MPS  = 6
};

enum MSKorderingtype_enum {
  MSK_ORDER_METHOD_BEGIN      = 0,
  MSK_ORDER_METHOD_END        = 6,

  MSK_ORDER_METHOD_FREE       = 0,
  MSK_ORDER_METHOD_APPMINLOC1 = 1,
  MSK_ORDER_METHOD_APPMINLOC2 = 2,
  MSK_ORDER_METHOD_GRAPHPAR1  = 3,
  MSK_ORDER_METHOD_GRAPHPAR2  = 4,
  MSK_ORDER_METHOD_NONE       = 5
};

enum MSKproblemtype_enum {
  MSK_PROBTYPE_BEGIN = 0,
  MSK_PROBTYPE_END   = 6,

  MSK_PROBTYPE_LO    = 0,
  MSK_PROBTYPE_QO    = 1,
  MSK_PROBTYPE_QCQO  = 2,
  MSK_PROBTYPE_GECO  = 3,
  MSK_PROBTYPE_CONIC = 4,
  MSK_PROBTYPE_MIXED = 5
};

enum MSKinftype_enum {
  MSK_INF_BEGIN     = 0,
  MSK_INF_END       = 3,

  MSK_INF_DOU_TYPE  = 0,
  MSK_INF_INT_TYPE  = 1,
  MSK_INF_LINT_TYPE = 2
};

enum MSKpresolvemode_enum {
  MSK_PRESOLVE_MODE_BEGIN = 0,
  MSK_PRESOLVE_MODE_END  = 3,

  MSK_PRESOLVE_MODE_OFF  = 0,
  MSK_PRESOLVE_MODE_ON   = 1,
  MSK_PRESOLVE_MODE_FREE = 2
};

enum MSKdparam_enum {
  MSK_DPAR_BEGIN                         = 0,
  MSK_DPAR_END                           = 67,

  MSK_DPAR_ANA_SOL_INFEAS_TOL            = 0,
  MSK_DPAR_BASIS_REL_TOL_S               = 1,
  MSK_DPAR_BASIS_TOL_S                   = 2,
  MSK_DPAR_BASIS_TOL_X                   = 3,
  MSK_DPAR_CALLBACK_FREQ                 = 4,
  MSK_DPAR_CHECK_CONVEXITY_REL_TOL       = 5,
  MSK_DPAR_DATA_TOL_AIJ                  = 6,
  MSK_DPAR_DATA_TOL_AIJ_HUGE             = 7,
  MSK_DPAR_DATA_TOL_AIJ_LARGE            = 8,
  MSK_DPAR_DATA_TOL_BOUND_INF            = 9,
  MSK_DPAR_DATA_TOL_BOUND_WRN            = 10,
  MSK_DPAR_DATA_TOL_C_HUGE               = 11,
  MSK_DPAR_DATA_TOL_CJ_LARGE             = 12,
  MSK_DPAR_DATA_TOL_QIJ                  = 13,
  MSK_DPAR_DATA_TOL_X                    = 14,
  MSK_DPAR_FEASREPAIR_TOL                = 15,
  MSK_DPAR_INTPNT_CO_TOL_DFEAS           = 16,
  MSK_DPAR_INTPNT_CO_TOL_INFEAS          = 17,
  MSK_DPAR_INTPNT_CO_TOL_MU_RED          = 18,
  MSK_DPAR_INTPNT_CO_TOL_NEAR_REL        = 19,
  MSK_DPAR_INTPNT_CO_TOL_PFEAS           = 20,
  MSK_DPAR_INTPNT_CO_TOL_REL_GAP         = 21,
  MSK_DPAR_INTPNT_NL_MERIT_BAL           = 22,
  MSK_DPAR_INTPNT_NL_TOL_DFEAS           = 23,
  MSK_DPAR_INTPNT_NL_TOL_MU_RED          = 24,
  MSK_DPAR_INTPNT_NL_TOL_NEAR_REL        = 25,
  MSK_DPAR_INTPNT_NL_TOL_PFEAS           = 26,
  MSK_DPAR_INTPNT_NL_TOL_REL_GAP         = 27,
  MSK_DPAR_INTPNT_NL_TOL_REL_STEP        = 28,
  MSK_DPAR_INTPNT_TOL_DFEAS              = 29,
  MSK_DPAR_INTPNT_TOL_DSAFE              = 30,
  MSK_DPAR_INTPNT_TOL_INFEAS             = 31,
  MSK_DPAR_INTPNT_TOL_MU_RED             = 32,
  MSK_DPAR_INTPNT_TOL_PATH               = 33,
  MSK_DPAR_INTPNT_TOL_PFEAS              = 34,
  MSK_DPAR_INTPNT_TOL_PSAFE              = 35,
  MSK_DPAR_INTPNT_TOL_REL_GAP            = 36,
  MSK_DPAR_INTPNT_TOL_REL_STEP           = 37,
  MSK_DPAR_INTPNT_TOL_STEP_SIZE          = 38,
  MSK_DPAR_LOWER_OBJ_CUT                 = 39,
  MSK_DPAR_LOWER_OBJ_CUT_FINITE_TRH      = 40,
  MSK_DPAR_MIO_DISABLE_TERM_TIME         = 41,
  MSK_DPAR_MIO_HEURISTIC_TIME            = 42,
  MSK_DPAR_MIO_MAX_TIME                  = 43,
  MSK_DPAR_MIO_MAX_TIME_APRX_OPT         = 44,
  MSK_DPAR_MIO_NEAR_TOL_ABS_GAP          = 45,
  MSK_DPAR_MIO_NEAR_TOL_REL_GAP          = 46,
  MSK_DPAR_MIO_REL_ADD_CUT_LIMITED       = 47,
  MSK_DPAR_MIO_REL_GAP_CONST             = 48,
  MSK_DPAR_MIO_TOL_ABS_GAP               = 49,
  MSK_DPAR_MIO_TOL_ABS_RELAX_INT         = 50,
  MSK_DPAR_MIO_TOL_FEAS                  = 51,
  MSK_DPAR_MIO_TOL_REL_GAP               = 52,
  MSK_DPAR_MIO_TOL_REL_RELAX_INT         = 53,
  MSK_DPAR_MIO_TOL_X                     = 54,
  MSK_DPAR_NONCONVEX_TOL_FEAS            = 55,
  MSK_DPAR_NONCONVEX_TOL_OPT             = 56,
  MSK_DPAR_OPTIMIZER_MAX_TIME            = 57,
  MSK_DPAR_PRESOLVE_TOL_AIJ              = 58,
  MSK_DPAR_PRESOLVE_TOL_LIN_DEP          = 59,
  MSK_DPAR_PRESOLVE_TOL_S                = 60,
  MSK_DPAR_PRESOLVE_TOL_X                = 61,
  MSK_DPAR_QCQO_REFORMULATE_REL_DROP_TOL = 62,
  MSK_DPAR_SIM_LU_TOL_REL_PIV            = 63,
  MSK_DPAR_SIMPLEX_ABS_TOL_PIV           = 64,
  MSK_DPAR_UPPER_OBJ_CUT                 = 65,
  MSK_DPAR_UPPER_OBJ_CUT_FINITE_TRH      = 66
};

enum MSKsimdupvec_enum {
  MSK_SIM_EXPLOIT_DUPVEC_BEGIN = 0,
  MSK_SIM_EXPLOIT_DUPVEC_END  = 3,

  MSK_SIM_EXPLOIT_DUPVEC_OFF  = 0,
  MSK_SIM_EXPLOIT_DUPVEC_ON   = 1,
  MSK_SIM_EXPLOIT_DUPVEC_FREE = 2
};

enum MSKnetworkdetect_enum {
  MSK_NETWORK_DETECT_BEGIN    = 0,
  MSK_NETWORK_DETECT_END      = 3,

  MSK_NETWORK_DETECT_FREE     = 0,
  MSK_NETWORK_DETECT_SIMPLE   = 1,
  MSK_NETWORK_DETECT_ADVANCED = 2
};

enum MSKcompresstype_enum {
  MSK_COMPRESS_BEGIN = 0,
  MSK_COMPRESS_END  = 3,

  MSK_COMPRESS_NONE = 0,
  MSK_COMPRESS_FREE = 1,
  MSK_COMPRESS_GZIP = 2
};

enum MSKmpsformat_enum {
  MSK_MPS_FORMAT_BEGIN   = 0,
  MSK_MPS_FORMAT_END     = 3,

  MSK_MPS_FORMAT_STRICT  = 0,
  MSK_MPS_FORMAT_RELAXED = 1,
  MSK_MPS_FORMAT_FREE    = 2
};

enum MSKvariabletype_enum {
  MSK_VAR_BEGIN     = 0,
  MSK_VAR_END       = 2,

  MSK_VAR_TYPE_CONT = 0,
  MSK_VAR_TYPE_INT  = 1
};

enum MSKcheckconvexitytype_enum {
  MSK_CHECK_CONVEXITY_BEGIN  = 0,
  MSK_CHECK_CONVEXITY_END    = 3,

  MSK_CHECK_CONVEXITY_NONE   = 0,
  MSK_CHECK_CONVEXITY_SIMPLE = 1,
  MSK_CHECK_CONVEXITY_FULL   = 2
};

enum MSKlanguage_enum {
  MSK_LANG_BEGIN = 0,
  MSK_LANG_END = 2,

  MSK_LANG_ENG = 0,
  MSK_LANG_DAN = 1
};

enum MSKstartpointtype_enum {
  MSK_STARTING_POINT_BEGIN          = 0,
  MSK_STARTING_POINT_END            = 4,

  MSK_STARTING_POINT_FREE           = 0,
  MSK_STARTING_POINT_GUESS          = 1,
  MSK_STARTING_POINT_CONSTANT       = 2,
  MSK_STARTING_POINT_SATISFY_BOUNDS = 3
};

enum MSKsoltype_enum {
  MSK_SOL_BEGIN = 0,
  MSK_SOL_END = 3,

  MSK_SOL_ITR = 0,
  MSK_SOL_BAS = 1,
  MSK_SOL_ITG = 2
};

enum MSKscalingmethod_enum {
  MSK_SCALING_METHOD_BEGIN = 0,
  MSK_SCALING_METHOD_END  = 2,

  MSK_SCALING_METHOD_POW2 = 0,
  MSK_SCALING_METHOD_FREE = 1
};

enum MSKvalue_enum {
  MSK_LICENSE_BUFFER_LENGTH = 20,
  MSK_MAX_STR_LEN           = 1024
};

enum MSKstakey_enum {
  MSK_SK_BEGIN  = 0,
  MSK_SK_END    = 7,

  MSK_SK_UNK    = 0,
  MSK_SK_BAS    = 1,
  MSK_SK_SUPBAS = 2,
  MSK_SK_LOW    = 3,
  MSK_SK_UPR    = 4,
  MSK_SK_FIX    = 5,
  MSK_SK_INF    = 6
};

enum MSKsimreform_enum {
  MSK_SIM_REFORMULATION_BEGIN      = 0,
  MSK_SIM_REFORMULATION_END        = 4,

  MSK_SIM_REFORMULATION_OFF        = 0,
  MSK_SIM_REFORMULATION_ON         = 1,
  MSK_SIM_REFORMULATION_FREE       = 2,
  MSK_SIM_REFORMULATION_AGGRESSIVE = 3
};

enum MSKiinfitem_enum {
  MSK_IINF_BEGIN                            = 0,
  MSK_IINF_END                              = 98,

  MSK_IINF_ANA_PRO_NUM_CON                  = 0,
  MSK_IINF_ANA_PRO_NUM_CON_EQ               = 1,
  MSK_IINF_ANA_PRO_NUM_CON_FR               = 2,
  MSK_IINF_ANA_PRO_NUM_CON_LO               = 3,
  MSK_IINF_ANA_PRO_NUM_CON_RA               = 4,
  MSK_IINF_ANA_PRO_NUM_CON_UP               = 5,
  MSK_IINF_ANA_PRO_NUM_VAR                  = 6,
  MSK_IINF_ANA_PRO_NUM_VAR_BIN              = 7,
  MSK_IINF_ANA_PRO_NUM_VAR_CONT             = 8,
  MSK_IINF_ANA_PRO_NUM_VAR_EQ               = 9,
  MSK_IINF_ANA_PRO_NUM_VAR_FR               = 10,
  MSK_IINF_ANA_PRO_NUM_VAR_INT              = 11,
  MSK_IINF_ANA_PRO_NUM_VAR_LO               = 12,
  MSK_IINF_ANA_PRO_NUM_VAR_RA               = 13,
  MSK_IINF_ANA_PRO_NUM_VAR_UP               = 14,
  MSK_IINF_CACHE_SIZE_L1                    = 15,
  MSK_IINF_CACHE_SIZE_L2                    = 16,
  MSK_IINF_CONCURRENT_FASTEST_OPTIMIZER     = 17,
  MSK_IINF_CPU_TYPE                         = 18,
  MSK_IINF_INTPNT_FACTOR_NUM_OFFCOL         = 19,
  MSK_IINF_INTPNT_ITER                      = 20,
  MSK_IINF_INTPNT_NUM_THREADS               = 21,
  MSK_IINF_INTPNT_SOLVE_DUAL                = 22,
  MSK_IINF_MIO_CONSTRUCT_SOLUTION           = 23,
  MSK_IINF_MIO_INITIAL_SOLUTION             = 24,
  MSK_IINF_MIO_NUM_ACTIVE_NODES             = 25,
  MSK_IINF_MIO_NUM_BRANCH                   = 26,
  MSK_IINF_MIO_NUM_CUTS                     = 27,
  MSK_IINF_MIO_NUM_INT_SOLUTIONS            = 28,
  MSK_IINF_MIO_NUM_RELAX                    = 29,
  MSK_IINF_MIO_NUMCON                       = 30,
  MSK_IINF_MIO_NUMINT                       = 31,
  MSK_IINF_MIO_NUMVAR                       = 32,
  MSK_IINF_MIO_TOTAL_NUM_BASIS_CUTS         = 33,
  MSK_IINF_MIO_TOTAL_NUM_BRANCH             = 34,
  MSK_IINF_MIO_TOTAL_NUM_CARDGUB_CUTS       = 35,
  MSK_IINF_MIO_TOTAL_NUM_CLIQUE_CUTS        = 36,
  MSK_IINF_MIO_TOTAL_NUM_COEF_REDC_CUTS     = 37,
  MSK_IINF_MIO_TOTAL_NUM_CONTRA_CUTS        = 38,
  MSK_IINF_MIO_TOTAL_NUM_CUTS               = 39,
  MSK_IINF_MIO_TOTAL_NUM_DISAGG_CUTS        = 40,
  MSK_IINF_MIO_TOTAL_NUM_FLOW_COVER_CUTS    = 41,
  MSK_IINF_MIO_TOTAL_NUM_GCD_CUTS           = 42,
  MSK_IINF_MIO_TOTAL_NUM_GOMORY_CUTS        = 43,
  MSK_IINF_MIO_TOTAL_NUM_GUB_COVER_CUTS     = 44,
  MSK_IINF_MIO_TOTAL_NUM_KNAPSUR_COVER_CUTS = 45,
  MSK_IINF_MIO_TOTAL_NUM_LATTICE_CUTS       = 46,
  MSK_IINF_MIO_TOTAL_NUM_LIFT_CUTS          = 47,
  MSK_IINF_MIO_TOTAL_NUM_OBJ_CUTS           = 48,
  MSK_IINF_MIO_TOTAL_NUM_PLAN_LOC_CUTS      = 49,
  MSK_IINF_MIO_TOTAL_NUM_RELAX              = 50,
  MSK_IINF_MIO_USER_OBJ_CUT                 = 51,
  MSK_IINF_OPT_NUMCON                       = 52,
  MSK_IINF_OPT_NUMVAR                       = 53,
  MSK_IINF_OPTIMIZE_RESPONSE                = 54,
  MSK_IINF_RD_NUMCON                        = 55,
  MSK_IINF_RD_NUMCONE                       = 56,
  MSK_IINF_RD_NUMINTVAR                     = 57,
  MSK_IINF_RD_NUMQ                          = 58,
  MSK_IINF_RD_NUMVAR                        = 59,
  MSK_IINF_RD_PROTYPE                       = 60,
  MSK_IINF_SIM_DUAL_DEG_ITER                = 61,
  MSK_IINF_SIM_DUAL_HOTSTART                = 62,
  MSK_IINF_SIM_DUAL_HOTSTART_LU             = 63,
  MSK_IINF_SIM_DUAL_INF_ITER                = 64,
  MSK_IINF_SIM_DUAL_ITER                    = 65,
  MSK_IINF_SIM_NETWORK_DUAL_DEG_ITER        = 66,
  MSK_IINF_SIM_NETWORK_DUAL_HOTSTART        = 67,
  MSK_IINF_SIM_NETWORK_DUAL_HOTSTART_LU     = 68,
  MSK_IINF_SIM_NETWORK_DUAL_INF_ITER        = 69,
  MSK_IINF_SIM_NETWORK_DUAL_ITER            = 70,
  MSK_IINF_SIM_NETWORK_PRIMAL_DEG_ITER      = 71,
  MSK_IINF_SIM_NETWORK_PRIMAL_HOTSTART      = 72,
  MSK_IINF_SIM_NETWORK_PRIMAL_HOTSTART_LU   = 73,
  MSK_IINF_SIM_NETWORK_PRIMAL_INF_ITER      = 74,
  MSK_IINF_SIM_NETWORK_PRIMAL_ITER          = 75,
  MSK_IINF_SIM_NUMCON                       = 76,
  MSK_IINF_SIM_NUMVAR                       = 77,
  MSK_IINF_SIM_PRIMAL_DEG_ITER              = 78,
  MSK_IINF_SIM_PRIMAL_DUAL_DEG_ITER         = 79,
  MSK_IINF_SIM_PRIMAL_DUAL_HOTSTART         = 80,
  MSK_IINF_SIM_PRIMAL_DUAL_HOTSTART_LU      = 81,
  MSK_IINF_SIM_PRIMAL_DUAL_INF_ITER         = 82,
  MSK_IINF_SIM_PRIMAL_DUAL_ITER             = 83,
  MSK_IINF_SIM_PRIMAL_HOTSTART              = 84,
  MSK_IINF_SIM_PRIMAL_HOTSTART_LU           = 85,
  MSK_IINF_SIM_PRIMAL_INF_ITER              = 86,
  MSK_IINF_SIM_PRIMAL_ITER                  = 87,
  MSK_IINF_SIM_SOLVE_DUAL                   = 88,
  MSK_IINF_SOL_BAS_PROSTA                   = 89,
  MSK_IINF_SOL_BAS_SOLSTA                   = 90,
  MSK_IINF_SOL_INT_PROSTA                   = 91,
  MSK_IINF_SOL_INT_SOLSTA                   = 92,
  MSK_IINF_SOL_ITR_PROSTA                   = 93,
  MSK_IINF_SOL_ITR_SOLSTA                   = 94,
  MSK_IINF_STO_NUM_A_CACHE_FLUSHES          = 95,
  MSK_IINF_STO_NUM_A_REALLOC                = 96,
  MSK_IINF_STO_NUM_A_TRANSPOSES             = 97
};

enum MSKxmlwriteroutputtype_enum {
  MSK_WRITE_XML_MODE_BEGIN = 0,
  MSK_WRITE_XML_MODE_END = 2,

  MSK_WRITE_XML_MODE_ROW = 0,
  MSK_WRITE_XML_MODE_COL = 1
};

enum MSKoptimizertype_enum {
  MSK_OPTIMIZER_BEGIN               = 0,
  MSK_OPTIMIZER_END                 = 11,

  MSK_OPTIMIZER_FREE                = 0,
  MSK_OPTIMIZER_INTPNT              = 1,
  MSK_OPTIMIZER_CONIC               = 2,
  MSK_OPTIMIZER_QCONE               = 3,
  MSK_OPTIMIZER_PRIMAL_SIMPLEX      = 4,
  MSK_OPTIMIZER_DUAL_SIMPLEX        = 5,
  MSK_OPTIMIZER_PRIMAL_DUAL_SIMPLEX = 6,
  MSK_OPTIMIZER_FREE_SIMPLEX        = 7,
  MSK_OPTIMIZER_MIXED_INT           = 8,
  MSK_OPTIMIZER_NONCONVEX           = 9,
  MSK_OPTIMIZER_CONCURRENT          = 10
};

enum MSKcputype_enum {
  MSK_CPU_UNKNOWN        = 0,
  MSK_CPU_GENERIC        = 1,
  MSK_CPU_INTEL_P3       = 2,
  MSK_CPU_INTEL_P4       = 3,
  MSK_CPU_AMD_ATHLON     = 4,
  MSK_CPU_HP_PARISC20    = 5,
  MSK_CPU_INTEL_ITANIUM2 = 6,
  MSK_CPU_AMD_OPTERON    = 7,
  MSK_CPU_POWERPC_G5     = 8,
  MSK_CPU_INTEL_PM       = 9,
  MSK_CPU_INTEL_CORE2    = 10
};

enum MSKmiocontsoltype_enum {
  MSK_MIO_CONT_SOL_BEGIN   = 0,
  MSK_MIO_CONT_SOL_END     = 4,

  MSK_MIO_CONT_SOL_NONE    = 0,
  MSK_MIO_CONT_SOL_ROOT    = 1,
  MSK_MIO_CONT_SOL_ITG     = 2,
  MSK_MIO_CONT_SOL_ITG_REL = 3
};

/* } namespace mosek; */
/**************************************************/
#define MSK_FIRST_ERR_CODE 1000 
#define MSK_LAST_ERR_CODE  3999 
/**************************************************/



#define MSK_SPAR_BAS_SOL_FILE_NAME_                         "MSK_SPAR_BAS_SOL_FILE_NAME"
#define MSK_SPAR_DATA_FILE_NAME_                            "MSK_SPAR_DATA_FILE_NAME"
#define MSK_SPAR_DEBUG_FILE_NAME_                           "MSK_SPAR_DEBUG_FILE_NAME"
#define MSK_SPAR_FEASREPAIR_NAME_PREFIX_                    "MSK_SPAR_FEASREPAIR_NAME_PREFIX"
#define MSK_SPAR_FEASREPAIR_NAME_SEPARATOR_                 "MSK_SPAR_FEASREPAIR_NAME_SEPARATOR"
#define MSK_SPAR_FEASREPAIR_NAME_WSUMVIOL_                  "MSK_SPAR_FEASREPAIR_NAME_WSUMVIOL"
#define MSK_SPAR_INT_SOL_FILE_NAME_                         "MSK_SPAR_INT_SOL_FILE_NAME"
#define MSK_SPAR_ITR_SOL_FILE_NAME_                         "MSK_SPAR_ITR_SOL_FILE_NAME"
#define MSK_SPAR_PARAM_COMMENT_SIGN_                        "MSK_SPAR_PARAM_COMMENT_SIGN"
#define MSK_SPAR_PARAM_READ_FILE_NAME_                      "MSK_SPAR_PARAM_READ_FILE_NAME"
#define MSK_SPAR_PARAM_WRITE_FILE_NAME_                     "MSK_SPAR_PARAM_WRITE_FILE_NAME"
#define MSK_SPAR_READ_MPS_BOU_NAME_                         "MSK_SPAR_READ_MPS_BOU_NAME"
#define MSK_SPAR_READ_MPS_OBJ_NAME_                         "MSK_SPAR_READ_MPS_OBJ_NAME"
#define MSK_SPAR_READ_MPS_RAN_NAME_                         "MSK_SPAR_READ_MPS_RAN_NAME"
#define MSK_SPAR_READ_MPS_RHS_NAME_                         "MSK_SPAR_READ_MPS_RHS_NAME"
#define MSK_SPAR_SENSITIVITY_FILE_NAME_                     "MSK_SPAR_SENSITIVITY_FILE_NAME"
#define MSK_SPAR_SENSITIVITY_RES_FILE_NAME_                 "MSK_SPAR_SENSITIVITY_RES_FILE_NAME"
#define MSK_SPAR_SOL_FILTER_XC_LOW_                         "MSK_SPAR_SOL_FILTER_XC_LOW"
#define MSK_SPAR_SOL_FILTER_XC_UPR_                         "MSK_SPAR_SOL_FILTER_XC_UPR"
#define MSK_SPAR_SOL_FILTER_XX_LOW_                         "MSK_SPAR_SOL_FILTER_XX_LOW"
#define MSK_SPAR_SOL_FILTER_XX_UPR_                         "MSK_SPAR_SOL_FILTER_XX_UPR"
#define MSK_SPAR_STAT_FILE_NAME_                            "MSK_SPAR_STAT_FILE_NAME"
#define MSK_SPAR_STAT_KEY_                                  "MSK_SPAR_STAT_KEY"
#define MSK_SPAR_STAT_NAME_                                 "MSK_SPAR_STAT_NAME"
#define MSK_SPAR_WRITE_LP_GEN_VAR_NAME_                     "MSK_SPAR_WRITE_LP_GEN_VAR_NAME"

#define MSK_DPAR_ANA_SOL_INFEAS_TOL_                        "MSK_DPAR_ANA_SOL_INFEAS_TOL"
#define MSK_DPAR_BASIS_REL_TOL_S_                           "MSK_DPAR_BASIS_REL_TOL_S"
#define MSK_DPAR_BASIS_TOL_S_                               "MSK_DPAR_BASIS_TOL_S"
#define MSK_DPAR_BASIS_TOL_X_                               "MSK_DPAR_BASIS_TOL_X"
#define MSK_DPAR_CALLBACK_FREQ_                             "MSK_DPAR_CALLBACK_FREQ"
#define MSK_DPAR_CHECK_CONVEXITY_REL_TOL_                   "MSK_DPAR_CHECK_CONVEXITY_REL_TOL"
#define MSK_DPAR_DATA_TOL_AIJ_                              "MSK_DPAR_DATA_TOL_AIJ"
#define MSK_DPAR_DATA_TOL_AIJ_HUGE_                         "MSK_DPAR_DATA_TOL_AIJ_HUGE"
#define MSK_DPAR_DATA_TOL_AIJ_LARGE_                        "MSK_DPAR_DATA_TOL_AIJ_LARGE"
#define MSK_DPAR_DATA_TOL_BOUND_INF_                        "MSK_DPAR_DATA_TOL_BOUND_INF"
#define MSK_DPAR_DATA_TOL_BOUND_WRN_                        "MSK_DPAR_DATA_TOL_BOUND_WRN"
#define MSK_DPAR_DATA_TOL_C_HUGE_                           "MSK_DPAR_DATA_TOL_C_HUGE"
#define MSK_DPAR_DATA_TOL_CJ_LARGE_                         "MSK_DPAR_DATA_TOL_CJ_LARGE"
#define MSK_DPAR_DATA_TOL_QIJ_                              "MSK_DPAR_DATA_TOL_QIJ"
#define MSK_DPAR_DATA_TOL_X_                                "MSK_DPAR_DATA_TOL_X"
#define MSK_DPAR_FEASREPAIR_TOL_                            "MSK_DPAR_FEASREPAIR_TOL"
#define MSK_DPAR_INTPNT_CO_TOL_DFEAS_                       "MSK_DPAR_INTPNT_CO_TOL_DFEAS"
#define MSK_DPAR_INTPNT_CO_TOL_INFEAS_                      "MSK_DPAR_INTPNT_CO_TOL_INFEAS"
#define MSK_DPAR_INTPNT_CO_TOL_MU_RED_                      "MSK_DPAR_INTPNT_CO_TOL_MU_RED"
#define MSK_DPAR_INTPNT_CO_TOL_NEAR_REL_                    "MSK_DPAR_INTPNT_CO_TOL_NEAR_REL"
#define MSK_DPAR_INTPNT_CO_TOL_PFEAS_                       "MSK_DPAR_INTPNT_CO_TOL_PFEAS"
#define MSK_DPAR_INTPNT_CO_TOL_REL_GAP_                     "MSK_DPAR_INTPNT_CO_TOL_REL_GAP"
#define MSK_DPAR_INTPNT_NL_MERIT_BAL_                       "MSK_DPAR_INTPNT_NL_MERIT_BAL"
#define MSK_DPAR_INTPNT_NL_TOL_DFEAS_                       "MSK_DPAR_INTPNT_NL_TOL_DFEAS"
#define MSK_DPAR_INTPNT_NL_TOL_MU_RED_                      "MSK_DPAR_INTPNT_NL_TOL_MU_RED"
#define MSK_DPAR_INTPNT_NL_TOL_NEAR_REL_                    "MSK_DPAR_INTPNT_NL_TOL_NEAR_REL"
#define MSK_DPAR_INTPNT_NL_TOL_PFEAS_                       "MSK_DPAR_INTPNT_NL_TOL_PFEAS"
#define MSK_DPAR_INTPNT_NL_TOL_REL_GAP_                     "MSK_DPAR_INTPNT_NL_TOL_REL_GAP"
#define MSK_DPAR_INTPNT_NL_TOL_REL_STEP_                    "MSK_DPAR_INTPNT_NL_TOL_REL_STEP"
#define MSK_DPAR_INTPNT_TOL_DFEAS_                          "MSK_DPAR_INTPNT_TOL_DFEAS"
#define MSK_DPAR_INTPNT_TOL_DSAFE_                          "MSK_DPAR_INTPNT_TOL_DSAFE"
#define MSK_DPAR_INTPNT_TOL_INFEAS_                         "MSK_DPAR_INTPNT_TOL_INFEAS"
#define MSK_DPAR_INTPNT_TOL_MU_RED_                         "MSK_DPAR_INTPNT_TOL_MU_RED"
#define MSK_DPAR_INTPNT_TOL_PATH_                           "MSK_DPAR_INTPNT_TOL_PATH"
#define MSK_DPAR_INTPNT_TOL_PFEAS_                          "MSK_DPAR_INTPNT_TOL_PFEAS"
#define MSK_DPAR_INTPNT_TOL_PSAFE_                          "MSK_DPAR_INTPNT_TOL_PSAFE"
#define MSK_DPAR_INTPNT_TOL_REL_GAP_                        "MSK_DPAR_INTPNT_TOL_REL_GAP"
#define MSK_DPAR_INTPNT_TOL_REL_STEP_                       "MSK_DPAR_INTPNT_TOL_REL_STEP"
#define MSK_DPAR_INTPNT_TOL_STEP_SIZE_                      "MSK_DPAR_INTPNT_TOL_STEP_SIZE"
#define MSK_DPAR_LOWER_OBJ_CUT_                             "MSK_DPAR_LOWER_OBJ_CUT"
#define MSK_DPAR_LOWER_OBJ_CUT_FINITE_TRH_                  "MSK_DPAR_LOWER_OBJ_CUT_FINITE_TRH"
#define MSK_DPAR_MIO_DISABLE_TERM_TIME_                     "MSK_DPAR_MIO_DISABLE_TERM_TIME"
#define MSK_DPAR_MIO_HEURISTIC_TIME_                        "MSK_DPAR_MIO_HEURISTIC_TIME"
#define MSK_DPAR_MIO_MAX_TIME_                              "MSK_DPAR_MIO_MAX_TIME"
#define MSK_DPAR_MIO_MAX_TIME_APRX_OPT_                     "MSK_DPAR_MIO_MAX_TIME_APRX_OPT"
#define MSK_DPAR_MIO_NEAR_TOL_ABS_GAP_                      "MSK_DPAR_MIO_NEAR_TOL_ABS_GAP"
#define MSK_DPAR_MIO_NEAR_TOL_REL_GAP_                      "MSK_DPAR_MIO_NEAR_TOL_REL_GAP"
#define MSK_DPAR_MIO_REL_ADD_CUT_LIMITED_                   "MSK_DPAR_MIO_REL_ADD_CUT_LIMITED"
#define MSK_DPAR_MIO_REL_GAP_CONST_                         "MSK_DPAR_MIO_REL_GAP_CONST"
#define MSK_DPAR_MIO_TOL_ABS_GAP_                           "MSK_DPAR_MIO_TOL_ABS_GAP"
#define MSK_DPAR_MIO_TOL_ABS_RELAX_INT_                     "MSK_DPAR_MIO_TOL_ABS_RELAX_INT"
#define MSK_DPAR_MIO_TOL_FEAS_                              "MSK_DPAR_MIO_TOL_FEAS"
#define MSK_DPAR_MIO_TOL_REL_GAP_                           "MSK_DPAR_MIO_TOL_REL_GAP"
#define MSK_DPAR_MIO_TOL_REL_RELAX_INT_                     "MSK_DPAR_MIO_TOL_REL_RELAX_INT"
#define MSK_DPAR_MIO_TOL_X_                                 "MSK_DPAR_MIO_TOL_X"
#define MSK_DPAR_NONCONVEX_TOL_FEAS_                        "MSK_DPAR_NONCONVEX_TOL_FEAS"
#define MSK_DPAR_NONCONVEX_TOL_OPT_                         "MSK_DPAR_NONCONVEX_TOL_OPT"
#define MSK_DPAR_OPTIMIZER_MAX_TIME_                        "MSK_DPAR_OPTIMIZER_MAX_TIME"
#define MSK_DPAR_PRESOLVE_TOL_AIJ_                          "MSK_DPAR_PRESOLVE_TOL_AIJ"
#define MSK_DPAR_PRESOLVE_TOL_LIN_DEP_                      "MSK_DPAR_PRESOLVE_TOL_LIN_DEP"
#define MSK_DPAR_PRESOLVE_TOL_S_                            "MSK_DPAR_PRESOLVE_TOL_S"
#define MSK_DPAR_PRESOLVE_TOL_X_                            "MSK_DPAR_PRESOLVE_TOL_X"
#define MSK_DPAR_QCQO_REFORMULATE_REL_DROP_TOL_             "MSK_DPAR_QCQO_REFORMULATE_REL_DROP_TOL"
#define MSK_DPAR_SIM_LU_TOL_REL_PIV_                        "MSK_DPAR_SIM_LU_TOL_REL_PIV"
#define MSK_DPAR_SIMPLEX_ABS_TOL_PIV_                       "MSK_DPAR_SIMPLEX_ABS_TOL_PIV"
#define MSK_DPAR_UPPER_OBJ_CUT_                             "MSK_DPAR_UPPER_OBJ_CUT"
#define MSK_DPAR_UPPER_OBJ_CUT_FINITE_TRH_                  "MSK_DPAR_UPPER_OBJ_CUT_FINITE_TRH"

#define MSK_IPAR_ALLOC_ADD_QNZ_                             "MSK_IPAR_ALLOC_ADD_QNZ"
#define MSK_IPAR_ANA_SOL_BASIS_                             "MSK_IPAR_ANA_SOL_BASIS"
#define MSK_IPAR_ANA_SOL_PRINT_VIOLATED_                    "MSK_IPAR_ANA_SOL_PRINT_VIOLATED"
#define MSK_IPAR_AUTO_SORT_A_BEFORE_OPT_                    "MSK_IPAR_AUTO_SORT_A_BEFORE_OPT"
#define MSK_IPAR_AUTO_UPDATE_SOL_INFO_                      "MSK_IPAR_AUTO_UPDATE_SOL_INFO"
#define MSK_IPAR_BASIS_SOLVE_USE_PLUS_ONE_                  "MSK_IPAR_BASIS_SOLVE_USE_PLUS_ONE"
#define MSK_IPAR_BI_CLEAN_OPTIMIZER_                        "MSK_IPAR_BI_CLEAN_OPTIMIZER"
#define MSK_IPAR_BI_IGNORE_MAX_ITER_                        "MSK_IPAR_BI_IGNORE_MAX_ITER"
#define MSK_IPAR_BI_IGNORE_NUM_ERROR_                       "MSK_IPAR_BI_IGNORE_NUM_ERROR"
#define MSK_IPAR_BI_MAX_ITERATIONS_                         "MSK_IPAR_BI_MAX_ITERATIONS"
#define MSK_IPAR_CACHE_LICENSE_                             "MSK_IPAR_CACHE_LICENSE"
#define MSK_IPAR_CACHE_SIZE_L1_                             "MSK_IPAR_CACHE_SIZE_L1"
#define MSK_IPAR_CACHE_SIZE_L2_                             "MSK_IPAR_CACHE_SIZE_L2"
#define MSK_IPAR_CHECK_CONVEXITY_                           "MSK_IPAR_CHECK_CONVEXITY"
#define MSK_IPAR_CHECK_TASK_DATA_                           "MSK_IPAR_CHECK_TASK_DATA"
#define MSK_IPAR_CONCURRENT_NUM_OPTIMIZERS_                 "MSK_IPAR_CONCURRENT_NUM_OPTIMIZERS"
#define MSK_IPAR_CONCURRENT_PRIORITY_DUAL_SIMPLEX_          "MSK_IPAR_CONCURRENT_PRIORITY_DUAL_SIMPLEX"
#define MSK_IPAR_CONCURRENT_PRIORITY_FREE_SIMPLEX_          "MSK_IPAR_CONCURRENT_PRIORITY_FREE_SIMPLEX"
#define MSK_IPAR_CONCURRENT_PRIORITY_INTPNT_                "MSK_IPAR_CONCURRENT_PRIORITY_INTPNT"
#define MSK_IPAR_CONCURRENT_PRIORITY_PRIMAL_SIMPLEX_        "MSK_IPAR_CONCURRENT_PRIORITY_PRIMAL_SIMPLEX"
#define MSK_IPAR_CPU_TYPE_                                  "MSK_IPAR_CPU_TYPE"
#define MSK_IPAR_DATA_CHECK_                                "MSK_IPAR_DATA_CHECK"
#define MSK_IPAR_FEASREPAIR_OPTIMIZE_                       "MSK_IPAR_FEASREPAIR_OPTIMIZE"
#define MSK_IPAR_INFEAS_GENERIC_NAMES_                      "MSK_IPAR_INFEAS_GENERIC_NAMES"
#define MSK_IPAR_INFEAS_PREFER_PRIMAL_                      "MSK_IPAR_INFEAS_PREFER_PRIMAL"
#define MSK_IPAR_INFEAS_REPORT_AUTO_                        "MSK_IPAR_INFEAS_REPORT_AUTO"
#define MSK_IPAR_INFEAS_REPORT_LEVEL_                       "MSK_IPAR_INFEAS_REPORT_LEVEL"
#define MSK_IPAR_INTPNT_BASIS_                              "MSK_IPAR_INTPNT_BASIS"
#define MSK_IPAR_INTPNT_DIFF_STEP_                          "MSK_IPAR_INTPNT_DIFF_STEP"
#define MSK_IPAR_INTPNT_FACTOR_DEBUG_LVL_                   "MSK_IPAR_INTPNT_FACTOR_DEBUG_LVL"
#define MSK_IPAR_INTPNT_FACTOR_METHOD_                      "MSK_IPAR_INTPNT_FACTOR_METHOD"
#define MSK_IPAR_INTPNT_MAX_ITERATIONS_                     "MSK_IPAR_INTPNT_MAX_ITERATIONS"
#define MSK_IPAR_INTPNT_MAX_NUM_COR_                        "MSK_IPAR_INTPNT_MAX_NUM_COR"
#define MSK_IPAR_INTPNT_MAX_NUM_REFINEMENT_STEPS_           "MSK_IPAR_INTPNT_MAX_NUM_REFINEMENT_STEPS"
#define MSK_IPAR_INTPNT_NUM_THREADS_                        "MSK_IPAR_INTPNT_NUM_THREADS"
#define MSK_IPAR_INTPNT_OFF_COL_TRH_                        "MSK_IPAR_INTPNT_OFF_COL_TRH"
#define MSK_IPAR_INTPNT_ORDER_METHOD_                       "MSK_IPAR_INTPNT_ORDER_METHOD"
#define MSK_IPAR_INTPNT_REGULARIZATION_USE_                 "MSK_IPAR_INTPNT_REGULARIZATION_USE"
#define MSK_IPAR_INTPNT_SCALING_                            "MSK_IPAR_INTPNT_SCALING"
#define MSK_IPAR_INTPNT_SOLVE_FORM_                         "MSK_IPAR_INTPNT_SOLVE_FORM"
#define MSK_IPAR_INTPNT_STARTING_POINT_                     "MSK_IPAR_INTPNT_STARTING_POINT"
#define MSK_IPAR_LIC_TRH_EXPIRY_WRN_                        "MSK_IPAR_LIC_TRH_EXPIRY_WRN"
#define MSK_IPAR_LICENSE_ALLOW_OVERUSE_                     "MSK_IPAR_LICENSE_ALLOW_OVERUSE"
#define MSK_IPAR_LICENSE_CACHE_TIME_                        "MSK_IPAR_LICENSE_CACHE_TIME"
#define MSK_IPAR_LICENSE_CHECK_TIME_                        "MSK_IPAR_LICENSE_CHECK_TIME"
#define MSK_IPAR_LICENSE_DEBUG_                             "MSK_IPAR_LICENSE_DEBUG"
#define MSK_IPAR_LICENSE_PAUSE_TIME_                        "MSK_IPAR_LICENSE_PAUSE_TIME"
#define MSK_IPAR_LICENSE_SUPPRESS_EXPIRE_WRNS_              "MSK_IPAR_LICENSE_SUPPRESS_EXPIRE_WRNS"
#define MSK_IPAR_LICENSE_WAIT_                              "MSK_IPAR_LICENSE_WAIT"
#define MSK_IPAR_LOG_                                       "MSK_IPAR_LOG"
#define MSK_IPAR_LOG_BI_                                    "MSK_IPAR_LOG_BI"
#define MSK_IPAR_LOG_BI_FREQ_                               "MSK_IPAR_LOG_BI_FREQ"
#define MSK_IPAR_LOG_CHECK_CONVEXITY_                       "MSK_IPAR_LOG_CHECK_CONVEXITY"
#define MSK_IPAR_LOG_CONCURRENT_                            "MSK_IPAR_LOG_CONCURRENT"
#define MSK_IPAR_LOG_CUT_SECOND_OPT_                        "MSK_IPAR_LOG_CUT_SECOND_OPT"
#define MSK_IPAR_LOG_FACTOR_                                "MSK_IPAR_LOG_FACTOR"
#define MSK_IPAR_LOG_FEASREPAIR_                            "MSK_IPAR_LOG_FEASREPAIR"
#define MSK_IPAR_LOG_FILE_                                  "MSK_IPAR_LOG_FILE"
#define MSK_IPAR_LOG_HEAD_                                  "MSK_IPAR_LOG_HEAD"
#define MSK_IPAR_LOG_INFEAS_ANA_                            "MSK_IPAR_LOG_INFEAS_ANA"
#define MSK_IPAR_LOG_INTPNT_                                "MSK_IPAR_LOG_INTPNT"
#define MSK_IPAR_LOG_MIO_                                   "MSK_IPAR_LOG_MIO"
#define MSK_IPAR_LOG_MIO_FREQ_                              "MSK_IPAR_LOG_MIO_FREQ"
#define MSK_IPAR_LOG_NONCONVEX_                             "MSK_IPAR_LOG_NONCONVEX"
#define MSK_IPAR_LOG_OPTIMIZER_                             "MSK_IPAR_LOG_OPTIMIZER"
#define MSK_IPAR_LOG_ORDER_                                 "MSK_IPAR_LOG_ORDER"
#define MSK_IPAR_LOG_PARAM_                                 "MSK_IPAR_LOG_PARAM"
#define MSK_IPAR_LOG_PRESOLVE_                              "MSK_IPAR_LOG_PRESOLVE"
#define MSK_IPAR_LOG_RESPONSE_                              "MSK_IPAR_LOG_RESPONSE"
#define MSK_IPAR_LOG_SENSITIVITY_                           "MSK_IPAR_LOG_SENSITIVITY"
#define MSK_IPAR_LOG_SENSITIVITY_OPT_                       "MSK_IPAR_LOG_SENSITIVITY_OPT"
#define MSK_IPAR_LOG_SIM_                                   "MSK_IPAR_LOG_SIM"
#define MSK_IPAR_LOG_SIM_FREQ_                              "MSK_IPAR_LOG_SIM_FREQ"
#define MSK_IPAR_LOG_SIM_MINOR_                             "MSK_IPAR_LOG_SIM_MINOR"
#define MSK_IPAR_LOG_SIM_NETWORK_FREQ_                      "MSK_IPAR_LOG_SIM_NETWORK_FREQ"
#define MSK_IPAR_LOG_STORAGE_                               "MSK_IPAR_LOG_STORAGE"
#define MSK_IPAR_LP_WRITE_IGNORE_INCOMPATIBLE_ITEMS_        "MSK_IPAR_LP_WRITE_IGNORE_INCOMPATIBLE_ITEMS"
#define MSK_IPAR_MAX_NUM_WARNINGS_                          "MSK_IPAR_MAX_NUM_WARNINGS"
#define MSK_IPAR_MIO_BRANCH_DIR_                            "MSK_IPAR_MIO_BRANCH_DIR"
#define MSK_IPAR_MIO_BRANCH_PRIORITIES_USE_                 "MSK_IPAR_MIO_BRANCH_PRIORITIES_USE"
#define MSK_IPAR_MIO_CONSTRUCT_SOL_                         "MSK_IPAR_MIO_CONSTRUCT_SOL"
#define MSK_IPAR_MIO_CONT_SOL_                              "MSK_IPAR_MIO_CONT_SOL"
#define MSK_IPAR_MIO_CUT_LEVEL_ROOT_                        "MSK_IPAR_MIO_CUT_LEVEL_ROOT"
#define MSK_IPAR_MIO_CUT_LEVEL_TREE_                        "MSK_IPAR_MIO_CUT_LEVEL_TREE"
#define MSK_IPAR_MIO_FEASPUMP_LEVEL_                        "MSK_IPAR_MIO_FEASPUMP_LEVEL"
#define MSK_IPAR_MIO_HEURISTIC_LEVEL_                       "MSK_IPAR_MIO_HEURISTIC_LEVEL"
#define MSK_IPAR_MIO_HOTSTART_                              "MSK_IPAR_MIO_HOTSTART"
#define MSK_IPAR_MIO_KEEP_BASIS_                            "MSK_IPAR_MIO_KEEP_BASIS"
#define MSK_IPAR_MIO_LOCAL_BRANCH_NUMBER_                   "MSK_IPAR_MIO_LOCAL_BRANCH_NUMBER"
#define MSK_IPAR_MIO_MAX_NUM_BRANCHES_                      "MSK_IPAR_MIO_MAX_NUM_BRANCHES"
#define MSK_IPAR_MIO_MAX_NUM_RELAXS_                        "MSK_IPAR_MIO_MAX_NUM_RELAXS"
#define MSK_IPAR_MIO_MAX_NUM_SOLUTIONS_                     "MSK_IPAR_MIO_MAX_NUM_SOLUTIONS"
#define MSK_IPAR_MIO_MODE_                                  "MSK_IPAR_MIO_MODE"
#define MSK_IPAR_MIO_NODE_OPTIMIZER_                        "MSK_IPAR_MIO_NODE_OPTIMIZER"
#define MSK_IPAR_MIO_NODE_SELECTION_                        "MSK_IPAR_MIO_NODE_SELECTION"
#define MSK_IPAR_MIO_OPTIMIZER_MODE_                        "MSK_IPAR_MIO_OPTIMIZER_MODE"
#define MSK_IPAR_MIO_PRESOLVE_AGGREGATE_                    "MSK_IPAR_MIO_PRESOLVE_AGGREGATE"
#define MSK_IPAR_MIO_PRESOLVE_PROBING_                      "MSK_IPAR_MIO_PRESOLVE_PROBING"
#define MSK_IPAR_MIO_PRESOLVE_USE_                          "MSK_IPAR_MIO_PRESOLVE_USE"
#define MSK_IPAR_MIO_ROOT_OPTIMIZER_                        "MSK_IPAR_MIO_ROOT_OPTIMIZER"
#define MSK_IPAR_MIO_STRONG_BRANCH_                         "MSK_IPAR_MIO_STRONG_BRANCH"
#define MSK_IPAR_NONCONVEX_MAX_ITERATIONS_                  "MSK_IPAR_NONCONVEX_MAX_ITERATIONS"
#define MSK_IPAR_OBJECTIVE_SENSE_                           "MSK_IPAR_OBJECTIVE_SENSE"
#define MSK_IPAR_OPF_MAX_TERMS_PER_LINE_                    "MSK_IPAR_OPF_MAX_TERMS_PER_LINE"
#define MSK_IPAR_OPF_WRITE_HEADER_                          "MSK_IPAR_OPF_WRITE_HEADER"
#define MSK_IPAR_OPF_WRITE_HINTS_                           "MSK_IPAR_OPF_WRITE_HINTS"
#define MSK_IPAR_OPF_WRITE_PARAMETERS_                      "MSK_IPAR_OPF_WRITE_PARAMETERS"
#define MSK_IPAR_OPF_WRITE_PROBLEM_                         "MSK_IPAR_OPF_WRITE_PROBLEM"
#define MSK_IPAR_OPF_WRITE_SOL_BAS_                         "MSK_IPAR_OPF_WRITE_SOL_BAS"
#define MSK_IPAR_OPF_WRITE_SOL_ITG_                         "MSK_IPAR_OPF_WRITE_SOL_ITG"
#define MSK_IPAR_OPF_WRITE_SOL_ITR_                         "MSK_IPAR_OPF_WRITE_SOL_ITR"
#define MSK_IPAR_OPF_WRITE_SOLUTIONS_                       "MSK_IPAR_OPF_WRITE_SOLUTIONS"
#define MSK_IPAR_OPTIMIZER_                                 "MSK_IPAR_OPTIMIZER"
#define MSK_IPAR_PARAM_READ_CASE_NAME_                      "MSK_IPAR_PARAM_READ_CASE_NAME"
#define MSK_IPAR_PARAM_READ_IGN_ERROR_                      "MSK_IPAR_PARAM_READ_IGN_ERROR"
#define MSK_IPAR_PRESOLVE_ELIM_FILL_                        "MSK_IPAR_PRESOLVE_ELIM_FILL"
#define MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES_         "MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES"
#define MSK_IPAR_PRESOLVE_ELIMINATOR_USE_                   "MSK_IPAR_PRESOLVE_ELIMINATOR_USE"
#define MSK_IPAR_PRESOLVE_LEVEL_                            "MSK_IPAR_PRESOLVE_LEVEL"
#define MSK_IPAR_PRESOLVE_LINDEP_USE_                       "MSK_IPAR_PRESOLVE_LINDEP_USE"
#define MSK_IPAR_PRESOLVE_LINDEP_WORK_LIM_                  "MSK_IPAR_PRESOLVE_LINDEP_WORK_LIM"
#define MSK_IPAR_PRESOLVE_USE_                              "MSK_IPAR_PRESOLVE_USE"
#define MSK_IPAR_QO_SEPARABLE_REFORMULATION_                "MSK_IPAR_QO_SEPARABLE_REFORMULATION"
#define MSK_IPAR_READ_ADD_ANZ_                              "MSK_IPAR_READ_ADD_ANZ"
#define MSK_IPAR_READ_ADD_CON_                              "MSK_IPAR_READ_ADD_CON"
#define MSK_IPAR_READ_ADD_CONE_                             "MSK_IPAR_READ_ADD_CONE"
#define MSK_IPAR_READ_ADD_QNZ_                              "MSK_IPAR_READ_ADD_QNZ"
#define MSK_IPAR_READ_ADD_VAR_                              "MSK_IPAR_READ_ADD_VAR"
#define MSK_IPAR_READ_ANZ_                                  "MSK_IPAR_READ_ANZ"
#define MSK_IPAR_READ_CON_                                  "MSK_IPAR_READ_CON"
#define MSK_IPAR_READ_CONE_                                 "MSK_IPAR_READ_CONE"
#define MSK_IPAR_READ_DATA_COMPRESSED_                      "MSK_IPAR_READ_DATA_COMPRESSED"
#define MSK_IPAR_READ_DATA_FORMAT_                          "MSK_IPAR_READ_DATA_FORMAT"
#define MSK_IPAR_READ_KEEP_FREE_CON_                        "MSK_IPAR_READ_KEEP_FREE_CON"
#define MSK_IPAR_READ_LP_DROP_NEW_VARS_IN_BOU_              "MSK_IPAR_READ_LP_DROP_NEW_VARS_IN_BOU"
#define MSK_IPAR_READ_LP_QUOTED_NAMES_                      "MSK_IPAR_READ_LP_QUOTED_NAMES"
#define MSK_IPAR_READ_MPS_FORMAT_                           "MSK_IPAR_READ_MPS_FORMAT"
#define MSK_IPAR_READ_MPS_KEEP_INT_                         "MSK_IPAR_READ_MPS_KEEP_INT"
#define MSK_IPAR_READ_MPS_OBJ_SENSE_                        "MSK_IPAR_READ_MPS_OBJ_SENSE"
#define MSK_IPAR_READ_MPS_QUOTED_NAMES_                     "MSK_IPAR_READ_MPS_QUOTED_NAMES"
#define MSK_IPAR_READ_MPS_RELAX_                            "MSK_IPAR_READ_MPS_RELAX"
#define MSK_IPAR_READ_MPS_WIDTH_                            "MSK_IPAR_READ_MPS_WIDTH"
#define MSK_IPAR_READ_Q_MODE_                               "MSK_IPAR_READ_Q_MODE"
#define MSK_IPAR_READ_QNZ_                                  "MSK_IPAR_READ_QNZ"
#define MSK_IPAR_READ_TASK_IGNORE_PARAM_                    "MSK_IPAR_READ_TASK_IGNORE_PARAM"
#define MSK_IPAR_READ_VAR_                                  "MSK_IPAR_READ_VAR"
#define MSK_IPAR_SENSITIVITY_ALL_                           "MSK_IPAR_SENSITIVITY_ALL"
#define MSK_IPAR_SENSITIVITY_OPTIMIZER_                     "MSK_IPAR_SENSITIVITY_OPTIMIZER"
#define MSK_IPAR_SENSITIVITY_TYPE_                          "MSK_IPAR_SENSITIVITY_TYPE"
#define MSK_IPAR_SIM_BASIS_FACTOR_USE_                      "MSK_IPAR_SIM_BASIS_FACTOR_USE"
#define MSK_IPAR_SIM_DEGEN_                                 "MSK_IPAR_SIM_DEGEN"
#define MSK_IPAR_SIM_DUAL_CRASH_                            "MSK_IPAR_SIM_DUAL_CRASH"
#define MSK_IPAR_SIM_DUAL_PHASEONE_METHOD_                  "MSK_IPAR_SIM_DUAL_PHASEONE_METHOD"
#define MSK_IPAR_SIM_DUAL_RESTRICT_SELECTION_               "MSK_IPAR_SIM_DUAL_RESTRICT_SELECTION"
#define MSK_IPAR_SIM_DUAL_SELECTION_                        "MSK_IPAR_SIM_DUAL_SELECTION"
#define MSK_IPAR_SIM_EXPLOIT_DUPVEC_                        "MSK_IPAR_SIM_EXPLOIT_DUPVEC"
#define MSK_IPAR_SIM_HOTSTART_                              "MSK_IPAR_SIM_HOTSTART"
#define MSK_IPAR_SIM_HOTSTART_LU_                           "MSK_IPAR_SIM_HOTSTART_LU"
#define MSK_IPAR_SIM_INTEGER_                               "MSK_IPAR_SIM_INTEGER"
#define MSK_IPAR_SIM_MAX_ITERATIONS_                        "MSK_IPAR_SIM_MAX_ITERATIONS"
#define MSK_IPAR_SIM_MAX_NUM_SETBACKS_                      "MSK_IPAR_SIM_MAX_NUM_SETBACKS"
#define MSK_IPAR_SIM_NETWORK_DETECT_                        "MSK_IPAR_SIM_NETWORK_DETECT"
#define MSK_IPAR_SIM_NETWORK_DETECT_HOTSTART_               "MSK_IPAR_SIM_NETWORK_DETECT_HOTSTART"
#define MSK_IPAR_SIM_NETWORK_DETECT_METHOD_                 "MSK_IPAR_SIM_NETWORK_DETECT_METHOD"
#define MSK_IPAR_SIM_NON_SINGULAR_                          "MSK_IPAR_SIM_NON_SINGULAR"
#define MSK_IPAR_SIM_PRIMAL_CRASH_                          "MSK_IPAR_SIM_PRIMAL_CRASH"
#define MSK_IPAR_SIM_PRIMAL_PHASEONE_METHOD_                "MSK_IPAR_SIM_PRIMAL_PHASEONE_METHOD"
#define MSK_IPAR_SIM_PRIMAL_RESTRICT_SELECTION_             "MSK_IPAR_SIM_PRIMAL_RESTRICT_SELECTION"
#define MSK_IPAR_SIM_PRIMAL_SELECTION_                      "MSK_IPAR_SIM_PRIMAL_SELECTION"
#define MSK_IPAR_SIM_REFACTOR_FREQ_                         "MSK_IPAR_SIM_REFACTOR_FREQ"
#define MSK_IPAR_SIM_REFORMULATION_                         "MSK_IPAR_SIM_REFORMULATION"
#define MSK_IPAR_SIM_SAVE_LU_                               "MSK_IPAR_SIM_SAVE_LU"
#define MSK_IPAR_SIM_SCALING_                               "MSK_IPAR_SIM_SCALING"
#define MSK_IPAR_SIM_SCALING_METHOD_                        "MSK_IPAR_SIM_SCALING_METHOD"
#define MSK_IPAR_SIM_SOLVE_FORM_                            "MSK_IPAR_SIM_SOLVE_FORM"
#define MSK_IPAR_SIM_STABILITY_PRIORITY_                    "MSK_IPAR_SIM_STABILITY_PRIORITY"
#define MSK_IPAR_SIM_SWITCH_OPTIMIZER_                      "MSK_IPAR_SIM_SWITCH_OPTIMIZER"
#define MSK_IPAR_SOL_FILTER_KEEP_BASIC_                     "MSK_IPAR_SOL_FILTER_KEEP_BASIC"
#define MSK_IPAR_SOL_FILTER_KEEP_RANGED_                    "MSK_IPAR_SOL_FILTER_KEEP_RANGED"
#define MSK_IPAR_SOL_QUOTED_NAMES_                          "MSK_IPAR_SOL_QUOTED_NAMES"
#define MSK_IPAR_SOL_READ_NAME_WIDTH_                       "MSK_IPAR_SOL_READ_NAME_WIDTH"
#define MSK_IPAR_SOL_READ_WIDTH_                            "MSK_IPAR_SOL_READ_WIDTH"
#define MSK_IPAR_SOLUTION_CALLBACK_                         "MSK_IPAR_SOLUTION_CALLBACK"
#define MSK_IPAR_TIMING_LEVEL_                              "MSK_IPAR_TIMING_LEVEL"
#define MSK_IPAR_WARNING_LEVEL_                             "MSK_IPAR_WARNING_LEVEL"
#define MSK_IPAR_WRITE_BAS_CONSTRAINTS_                     "MSK_IPAR_WRITE_BAS_CONSTRAINTS"
#define MSK_IPAR_WRITE_BAS_HEAD_                            "MSK_IPAR_WRITE_BAS_HEAD"
#define MSK_IPAR_WRITE_BAS_VARIABLES_                       "MSK_IPAR_WRITE_BAS_VARIABLES"
#define MSK_IPAR_WRITE_DATA_COMPRESSED_                     "MSK_IPAR_WRITE_DATA_COMPRESSED"
#define MSK_IPAR_WRITE_DATA_FORMAT_                         "MSK_IPAR_WRITE_DATA_FORMAT"
#define MSK_IPAR_WRITE_DATA_PARAM_                          "MSK_IPAR_WRITE_DATA_PARAM"
#define MSK_IPAR_WRITE_FREE_CON_                            "MSK_IPAR_WRITE_FREE_CON"
#define MSK_IPAR_WRITE_GENERIC_NAMES_                       "MSK_IPAR_WRITE_GENERIC_NAMES"
#define MSK_IPAR_WRITE_GENERIC_NAMES_IO_                    "MSK_IPAR_WRITE_GENERIC_NAMES_IO"
#define MSK_IPAR_WRITE_INT_CONSTRAINTS_                     "MSK_IPAR_WRITE_INT_CONSTRAINTS"
#define MSK_IPAR_WRITE_INT_HEAD_                            "MSK_IPAR_WRITE_INT_HEAD"
#define MSK_IPAR_WRITE_INT_VARIABLES_                       "MSK_IPAR_WRITE_INT_VARIABLES"
#define MSK_IPAR_WRITE_LP_LINE_WIDTH_                       "MSK_IPAR_WRITE_LP_LINE_WIDTH"
#define MSK_IPAR_WRITE_LP_QUOTED_NAMES_                     "MSK_IPAR_WRITE_LP_QUOTED_NAMES"
#define MSK_IPAR_WRITE_LP_STRICT_FORMAT_                    "MSK_IPAR_WRITE_LP_STRICT_FORMAT"
#define MSK_IPAR_WRITE_LP_TERMS_PER_LINE_                   "MSK_IPAR_WRITE_LP_TERMS_PER_LINE"
#define MSK_IPAR_WRITE_MPS_INT_                             "MSK_IPAR_WRITE_MPS_INT"
#define MSK_IPAR_WRITE_MPS_OBJ_SENSE_                       "MSK_IPAR_WRITE_MPS_OBJ_SENSE"
#define MSK_IPAR_WRITE_MPS_QUOTED_NAMES_                    "MSK_IPAR_WRITE_MPS_QUOTED_NAMES"
#define MSK_IPAR_WRITE_MPS_STRICT_                          "MSK_IPAR_WRITE_MPS_STRICT"
#define MSK_IPAR_WRITE_PRECISION_                           "MSK_IPAR_WRITE_PRECISION"
#define MSK_IPAR_WRITE_SOL_CONSTRAINTS_                     "MSK_IPAR_WRITE_SOL_CONSTRAINTS"
#define MSK_IPAR_WRITE_SOL_HEAD_                            "MSK_IPAR_WRITE_SOL_HEAD"
#define MSK_IPAR_WRITE_SOL_VARIABLES_                       "MSK_IPAR_WRITE_SOL_VARIABLES"
#define MSK_IPAR_WRITE_TASK_INC_SOL_                        "MSK_IPAR_WRITE_TASK_INC_SOL"
#define MSK_IPAR_WRITE_XML_MODE_                            "MSK_IPAR_WRITE_XML_MODE"

#define MSK_IINF_ANA_PRO_NUM_CON_                           "MSK_IINF_ANA_PRO_NUM_CON"
#define MSK_IINF_ANA_PRO_NUM_CON_EQ_                        "MSK_IINF_ANA_PRO_NUM_CON_EQ"
#define MSK_IINF_ANA_PRO_NUM_CON_FR_                        "MSK_IINF_ANA_PRO_NUM_CON_FR"
#define MSK_IINF_ANA_PRO_NUM_CON_LO_                        "MSK_IINF_ANA_PRO_NUM_CON_LO"
#define MSK_IINF_ANA_PRO_NUM_CON_RA_                        "MSK_IINF_ANA_PRO_NUM_CON_RA"
#define MSK_IINF_ANA_PRO_NUM_CON_UP_                        "MSK_IINF_ANA_PRO_NUM_CON_UP"
#define MSK_IINF_ANA_PRO_NUM_VAR_                           "MSK_IINF_ANA_PRO_NUM_VAR"
#define MSK_IINF_ANA_PRO_NUM_VAR_BIN_                       "MSK_IINF_ANA_PRO_NUM_VAR_BIN"
#define MSK_IINF_ANA_PRO_NUM_VAR_CONT_                      "MSK_IINF_ANA_PRO_NUM_VAR_CONT"
#define MSK_IINF_ANA_PRO_NUM_VAR_EQ_                        "MSK_IINF_ANA_PRO_NUM_VAR_EQ"
#define MSK_IINF_ANA_PRO_NUM_VAR_FR_                        "MSK_IINF_ANA_PRO_NUM_VAR_FR"
#define MSK_IINF_ANA_PRO_NUM_VAR_INT_                       "MSK_IINF_ANA_PRO_NUM_VAR_INT"
#define MSK_IINF_ANA_PRO_NUM_VAR_LO_                        "MSK_IINF_ANA_PRO_NUM_VAR_LO"
#define MSK_IINF_ANA_PRO_NUM_VAR_RA_                        "MSK_IINF_ANA_PRO_NUM_VAR_RA"
#define MSK_IINF_ANA_PRO_NUM_VAR_UP_                        "MSK_IINF_ANA_PRO_NUM_VAR_UP"
#define MSK_IINF_CACHE_SIZE_L1_                             "MSK_IINF_CACHE_SIZE_L1"
#define MSK_IINF_CACHE_SIZE_L2_                             "MSK_IINF_CACHE_SIZE_L2"
#define MSK_IINF_CONCURRENT_FASTEST_OPTIMIZER_              "MSK_IINF_CONCURRENT_FASTEST_OPTIMIZER"
#define MSK_IINF_CPU_TYPE_                                  "MSK_IINF_CPU_TYPE"
#define MSK_IINF_INTPNT_FACTOR_NUM_OFFCOL_                  "MSK_IINF_INTPNT_FACTOR_NUM_OFFCOL"
#define MSK_IINF_INTPNT_ITER_                               "MSK_IINF_INTPNT_ITER"
#define MSK_IINF_INTPNT_NUM_THREADS_                        "MSK_IINF_INTPNT_NUM_THREADS"
#define MSK_IINF_INTPNT_SOLVE_DUAL_                         "MSK_IINF_INTPNT_SOLVE_DUAL"
#define MSK_IINF_MIO_CONSTRUCT_SOLUTION_                    "MSK_IINF_MIO_CONSTRUCT_SOLUTION"
#define MSK_IINF_MIO_INITIAL_SOLUTION_                      "MSK_IINF_MIO_INITIAL_SOLUTION"
#define MSK_IINF_MIO_NUM_ACTIVE_NODES_                      "MSK_IINF_MIO_NUM_ACTIVE_NODES"
#define MSK_IINF_MIO_NUM_BRANCH_                            "MSK_IINF_MIO_NUM_BRANCH"
#define MSK_IINF_MIO_NUM_CUTS_                              "MSK_IINF_MIO_NUM_CUTS"
#define MSK_IINF_MIO_NUM_INT_SOLUTIONS_                     "MSK_IINF_MIO_NUM_INT_SOLUTIONS"
#define MSK_IINF_MIO_NUM_RELAX_                             "MSK_IINF_MIO_NUM_RELAX"
#define MSK_IINF_MIO_NUMCON_                                "MSK_IINF_MIO_NUMCON"
#define MSK_IINF_MIO_NUMINT_                                "MSK_IINF_MIO_NUMINT"
#define MSK_IINF_MIO_NUMVAR_                                "MSK_IINF_MIO_NUMVAR"
#define MSK_IINF_MIO_TOTAL_NUM_BASIS_CUTS_                  "MSK_IINF_MIO_TOTAL_NUM_BASIS_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_BRANCH_                      "MSK_IINF_MIO_TOTAL_NUM_BRANCH"
#define MSK_IINF_MIO_TOTAL_NUM_CARDGUB_CUTS_                "MSK_IINF_MIO_TOTAL_NUM_CARDGUB_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_CLIQUE_CUTS_                 "MSK_IINF_MIO_TOTAL_NUM_CLIQUE_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_COEF_REDC_CUTS_              "MSK_IINF_MIO_TOTAL_NUM_COEF_REDC_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_CONTRA_CUTS_                 "MSK_IINF_MIO_TOTAL_NUM_CONTRA_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_CUTS_                        "MSK_IINF_MIO_TOTAL_NUM_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_DISAGG_CUTS_                 "MSK_IINF_MIO_TOTAL_NUM_DISAGG_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_FLOW_COVER_CUTS_             "MSK_IINF_MIO_TOTAL_NUM_FLOW_COVER_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_GCD_CUTS_                    "MSK_IINF_MIO_TOTAL_NUM_GCD_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_GOMORY_CUTS_                 "MSK_IINF_MIO_TOTAL_NUM_GOMORY_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_GUB_COVER_CUTS_              "MSK_IINF_MIO_TOTAL_NUM_GUB_COVER_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_KNAPSUR_COVER_CUTS_          "MSK_IINF_MIO_TOTAL_NUM_KNAPSUR_COVER_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_LATTICE_CUTS_                "MSK_IINF_MIO_TOTAL_NUM_LATTICE_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_LIFT_CUTS_                   "MSK_IINF_MIO_TOTAL_NUM_LIFT_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_OBJ_CUTS_                    "MSK_IINF_MIO_TOTAL_NUM_OBJ_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_PLAN_LOC_CUTS_               "MSK_IINF_MIO_TOTAL_NUM_PLAN_LOC_CUTS"
#define MSK_IINF_MIO_TOTAL_NUM_RELAX_                       "MSK_IINF_MIO_TOTAL_NUM_RELAX"
#define MSK_IINF_MIO_USER_OBJ_CUT_                          "MSK_IINF_MIO_USER_OBJ_CUT"
#define MSK_IINF_OPT_NUMCON_                                "MSK_IINF_OPT_NUMCON"
#define MSK_IINF_OPT_NUMVAR_                                "MSK_IINF_OPT_NUMVAR"
#define MSK_IINF_OPTIMIZE_RESPONSE_                         "MSK_IINF_OPTIMIZE_RESPONSE"
#define MSK_IINF_RD_NUMCON_                                 "MSK_IINF_RD_NUMCON"
#define MSK_IINF_RD_NUMCONE_                                "MSK_IINF_RD_NUMCONE"
#define MSK_IINF_RD_NUMINTVAR_                              "MSK_IINF_RD_NUMINTVAR"
#define MSK_IINF_RD_NUMQ_                                   "MSK_IINF_RD_NUMQ"
#define MSK_IINF_RD_NUMVAR_                                 "MSK_IINF_RD_NUMVAR"
#define MSK_IINF_RD_PROTYPE_                                "MSK_IINF_RD_PROTYPE"
#define MSK_IINF_SIM_DUAL_DEG_ITER_                         "MSK_IINF_SIM_DUAL_DEG_ITER"
#define MSK_IINF_SIM_DUAL_HOTSTART_                         "MSK_IINF_SIM_DUAL_HOTSTART"
#define MSK_IINF_SIM_DUAL_HOTSTART_LU_                      "MSK_IINF_SIM_DUAL_HOTSTART_LU"
#define MSK_IINF_SIM_DUAL_INF_ITER_                         "MSK_IINF_SIM_DUAL_INF_ITER"
#define MSK_IINF_SIM_DUAL_ITER_                             "MSK_IINF_SIM_DUAL_ITER"
#define MSK_IINF_SIM_NETWORK_DUAL_DEG_ITER_                 "MSK_IINF_SIM_NETWORK_DUAL_DEG_ITER"
#define MSK_IINF_SIM_NETWORK_DUAL_HOTSTART_                 "MSK_IINF_SIM_NETWORK_DUAL_HOTSTART"
#define MSK_IINF_SIM_NETWORK_DUAL_HOTSTART_LU_              "MSK_IINF_SIM_NETWORK_DUAL_HOTSTART_LU"
#define MSK_IINF_SIM_NETWORK_DUAL_INF_ITER_                 "MSK_IINF_SIM_NETWORK_DUAL_INF_ITER"
#define MSK_IINF_SIM_NETWORK_DUAL_ITER_                     "MSK_IINF_SIM_NETWORK_DUAL_ITER"
#define MSK_IINF_SIM_NETWORK_PRIMAL_DEG_ITER_               "MSK_IINF_SIM_NETWORK_PRIMAL_DEG_ITER"
#define MSK_IINF_SIM_NETWORK_PRIMAL_HOTSTART_               "MSK_IINF_SIM_NETWORK_PRIMAL_HOTSTART"
#define MSK_IINF_SIM_NETWORK_PRIMAL_HOTSTART_LU_            "MSK_IINF_SIM_NETWORK_PRIMAL_HOTSTART_LU"
#define MSK_IINF_SIM_NETWORK_PRIMAL_INF_ITER_               "MSK_IINF_SIM_NETWORK_PRIMAL_INF_ITER"
#define MSK_IINF_SIM_NETWORK_PRIMAL_ITER_                   "MSK_IINF_SIM_NETWORK_PRIMAL_ITER"
#define MSK_IINF_SIM_NUMCON_                                "MSK_IINF_SIM_NUMCON"
#define MSK_IINF_SIM_NUMVAR_                                "MSK_IINF_SIM_NUMVAR"
#define MSK_IINF_SIM_PRIMAL_DEG_ITER_                       "MSK_IINF_SIM_PRIMAL_DEG_ITER"
#define MSK_IINF_SIM_PRIMAL_DUAL_DEG_ITER_                  "MSK_IINF_SIM_PRIMAL_DUAL_DEG_ITER"
#define MSK_IINF_SIM_PRIMAL_DUAL_HOTSTART_                  "MSK_IINF_SIM_PRIMAL_DUAL_HOTSTART"
#define MSK_IINF_SIM_PRIMAL_DUAL_HOTSTART_LU_               "MSK_IINF_SIM_PRIMAL_DUAL_HOTSTART_LU"
#define MSK_IINF_SIM_PRIMAL_DUAL_INF_ITER_                  "MSK_IINF_SIM_PRIMAL_DUAL_INF_ITER"
#define MSK_IINF_SIM_PRIMAL_DUAL_ITER_                      "MSK_IINF_SIM_PRIMAL_DUAL_ITER"
#define MSK_IINF_SIM_PRIMAL_HOTSTART_                       "MSK_IINF_SIM_PRIMAL_HOTSTART"
#define MSK_IINF_SIM_PRIMAL_HOTSTART_LU_                    "MSK_IINF_SIM_PRIMAL_HOTSTART_LU"
#define MSK_IINF_SIM_PRIMAL_INF_ITER_                       "MSK_IINF_SIM_PRIMAL_INF_ITER"
#define MSK_IINF_SIM_PRIMAL_ITER_                           "MSK_IINF_SIM_PRIMAL_ITER"
#define MSK_IINF_SIM_SOLVE_DUAL_                            "MSK_IINF_SIM_SOLVE_DUAL"
#define MSK_IINF_SOL_BAS_PROSTA_                            "MSK_IINF_SOL_BAS_PROSTA"
#define MSK_IINF_SOL_BAS_SOLSTA_                            "MSK_IINF_SOL_BAS_SOLSTA"
#define MSK_IINF_SOL_INT_PROSTA_                            "MSK_IINF_SOL_INT_PROSTA"
#define MSK_IINF_SOL_INT_SOLSTA_                            "MSK_IINF_SOL_INT_SOLSTA"
#define MSK_IINF_SOL_ITR_PROSTA_                            "MSK_IINF_SOL_ITR_PROSTA"
#define MSK_IINF_SOL_ITR_SOLSTA_                            "MSK_IINF_SOL_ITR_SOLSTA"
#define MSK_IINF_STO_NUM_A_CACHE_FLUSHES_                   "MSK_IINF_STO_NUM_A_CACHE_FLUSHES"
#define MSK_IINF_STO_NUM_A_REALLOC_                         "MSK_IINF_STO_NUM_A_REALLOC"
#define MSK_IINF_STO_NUM_A_TRANSPOSES_                      "MSK_IINF_STO_NUM_A_TRANSPOSES"

#define MSK_DINF_BI_CLEAN_DUAL_TIME_                        "MSK_DINF_BI_CLEAN_DUAL_TIME"
#define MSK_DINF_BI_CLEAN_PRIMAL_DUAL_TIME_                 "MSK_DINF_BI_CLEAN_PRIMAL_DUAL_TIME"
#define MSK_DINF_BI_CLEAN_PRIMAL_TIME_                      "MSK_DINF_BI_CLEAN_PRIMAL_TIME"
#define MSK_DINF_BI_CLEAN_TIME_                             "MSK_DINF_BI_CLEAN_TIME"
#define MSK_DINF_BI_DUAL_TIME_                              "MSK_DINF_BI_DUAL_TIME"
#define MSK_DINF_BI_PRIMAL_TIME_                            "MSK_DINF_BI_PRIMAL_TIME"
#define MSK_DINF_BI_TIME_                                   "MSK_DINF_BI_TIME"
#define MSK_DINF_CONCURRENT_TIME_                           "MSK_DINF_CONCURRENT_TIME"
#define MSK_DINF_INTPNT_DUAL_FEAS_                          "MSK_DINF_INTPNT_DUAL_FEAS"
#define MSK_DINF_INTPNT_DUAL_OBJ_                           "MSK_DINF_INTPNT_DUAL_OBJ"
#define MSK_DINF_INTPNT_FACTOR_NUM_FLOPS_                   "MSK_DINF_INTPNT_FACTOR_NUM_FLOPS"
#define MSK_DINF_INTPNT_KAP_DIV_TAU_                        "MSK_DINF_INTPNT_KAP_DIV_TAU"
#define MSK_DINF_INTPNT_ORDER_TIME_                         "MSK_DINF_INTPNT_ORDER_TIME"
#define MSK_DINF_INTPNT_PRIMAL_FEAS_                        "MSK_DINF_INTPNT_PRIMAL_FEAS"
#define MSK_DINF_INTPNT_PRIMAL_OBJ_                         "MSK_DINF_INTPNT_PRIMAL_OBJ"
#define MSK_DINF_INTPNT_TIME_                               "MSK_DINF_INTPNT_TIME"
#define MSK_DINF_MIO_CONSTRUCT_SOLUTION_OBJ_                "MSK_DINF_MIO_CONSTRUCT_SOLUTION_OBJ"
#define MSK_DINF_MIO_HEURISTIC_TIME_                        "MSK_DINF_MIO_HEURISTIC_TIME"
#define MSK_DINF_MIO_OBJ_ABS_GAP_                           "MSK_DINF_MIO_OBJ_ABS_GAP"
#define MSK_DINF_MIO_OBJ_BOUND_                             "MSK_DINF_MIO_OBJ_BOUND"
#define MSK_DINF_MIO_OBJ_INT_                               "MSK_DINF_MIO_OBJ_INT"
#define MSK_DINF_MIO_OBJ_REL_GAP_                           "MSK_DINF_MIO_OBJ_REL_GAP"
#define MSK_DINF_MIO_OPTIMIZER_TIME_                        "MSK_DINF_MIO_OPTIMIZER_TIME"
#define MSK_DINF_MIO_ROOT_OPTIMIZER_TIME_                   "MSK_DINF_MIO_ROOT_OPTIMIZER_TIME"
#define MSK_DINF_MIO_ROOT_PRESOLVE_TIME_                    "MSK_DINF_MIO_ROOT_PRESOLVE_TIME"
#define MSK_DINF_MIO_TIME_                                  "MSK_DINF_MIO_TIME"
#define MSK_DINF_MIO_USER_OBJ_CUT_                          "MSK_DINF_MIO_USER_OBJ_CUT"
#define MSK_DINF_OPTIMIZER_TIME_                            "MSK_DINF_OPTIMIZER_TIME"
#define MSK_DINF_PRESOLVE_ELI_TIME_                         "MSK_DINF_PRESOLVE_ELI_TIME"
#define MSK_DINF_PRESOLVE_LINDEP_TIME_                      "MSK_DINF_PRESOLVE_LINDEP_TIME"
#define MSK_DINF_PRESOLVE_TIME_                             "MSK_DINF_PRESOLVE_TIME"
#define MSK_DINF_QCQO_REFORMULATE_TIME_                     "MSK_DINF_QCQO_REFORMULATE_TIME"
#define MSK_DINF_RD_TIME_                                   "MSK_DINF_RD_TIME"
#define MSK_DINF_SIM_DUAL_TIME_                             "MSK_DINF_SIM_DUAL_TIME"
#define MSK_DINF_SIM_FEAS_                                  "MSK_DINF_SIM_FEAS"
#define MSK_DINF_SIM_NETWORK_DUAL_TIME_                     "MSK_DINF_SIM_NETWORK_DUAL_TIME"
#define MSK_DINF_SIM_NETWORK_PRIMAL_TIME_                   "MSK_DINF_SIM_NETWORK_PRIMAL_TIME"
#define MSK_DINF_SIM_NETWORK_TIME_                          "MSK_DINF_SIM_NETWORK_TIME"
#define MSK_DINF_SIM_OBJ_                                   "MSK_DINF_SIM_OBJ"
#define MSK_DINF_SIM_PRIMAL_DUAL_TIME_                      "MSK_DINF_SIM_PRIMAL_DUAL_TIME"
#define MSK_DINF_SIM_PRIMAL_TIME_                           "MSK_DINF_SIM_PRIMAL_TIME"
#define MSK_DINF_SIM_TIME_                                  "MSK_DINF_SIM_TIME"
#define MSK_DINF_SOL_BAS_DUAL_OBJ_                          "MSK_DINF_SOL_BAS_DUAL_OBJ"
#define MSK_DINF_SOL_BAS_MAX_DBI_                           "MSK_DINF_SOL_BAS_MAX_DBI"
#define MSK_DINF_SOL_BAS_MAX_DEQI_                          "MSK_DINF_SOL_BAS_MAX_DEQI"
#define MSK_DINF_SOL_BAS_MAX_PBI_                           "MSK_DINF_SOL_BAS_MAX_PBI"
#define MSK_DINF_SOL_BAS_MAX_PEQI_                          "MSK_DINF_SOL_BAS_MAX_PEQI"
#define MSK_DINF_SOL_BAS_MAX_PINTI_                         "MSK_DINF_SOL_BAS_MAX_PINTI"
#define MSK_DINF_SOL_BAS_PRIMAL_OBJ_                        "MSK_DINF_SOL_BAS_PRIMAL_OBJ"
#define MSK_DINF_SOL_INT_MAX_PBI_                           "MSK_DINF_SOL_INT_MAX_PBI"
#define MSK_DINF_SOL_INT_MAX_PEQI_                          "MSK_DINF_SOL_INT_MAX_PEQI"
#define MSK_DINF_SOL_INT_MAX_PINTI_                         "MSK_DINF_SOL_INT_MAX_PINTI"
#define MSK_DINF_SOL_INT_PRIMAL_OBJ_                        "MSK_DINF_SOL_INT_PRIMAL_OBJ"
#define MSK_DINF_SOL_ITR_DUAL_OBJ_                          "MSK_DINF_SOL_ITR_DUAL_OBJ"
#define MSK_DINF_SOL_ITR_MAX_DBI_                           "MSK_DINF_SOL_ITR_MAX_DBI"
#define MSK_DINF_SOL_ITR_MAX_DCNI_                          "MSK_DINF_SOL_ITR_MAX_DCNI"
#define MSK_DINF_SOL_ITR_MAX_DEQI_                          "MSK_DINF_SOL_ITR_MAX_DEQI"
#define MSK_DINF_SOL_ITR_MAX_PBI_                           "MSK_DINF_SOL_ITR_MAX_PBI"
#define MSK_DINF_SOL_ITR_MAX_PCNI_                          "MSK_DINF_SOL_ITR_MAX_PCNI"
#define MSK_DINF_SOL_ITR_MAX_PEQI_                          "MSK_DINF_SOL_ITR_MAX_PEQI"
#define MSK_DINF_SOL_ITR_MAX_PINTI_                         "MSK_DINF_SOL_ITR_MAX_PINTI"
#define MSK_DINF_SOL_ITR_PRIMAL_OBJ_                        "MSK_DINF_SOL_ITR_PRIMAL_OBJ"

#define MSK_LIINF_BI_CLEAN_DUAL_DEG_ITER_                   "MSK_LIINF_BI_CLEAN_DUAL_DEG_ITER"
#define MSK_LIINF_BI_CLEAN_DUAL_ITER_                       "MSK_LIINF_BI_CLEAN_DUAL_ITER"
#define MSK_LIINF_BI_CLEAN_PRIMAL_DEG_ITER_                 "MSK_LIINF_BI_CLEAN_PRIMAL_DEG_ITER"
#define MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_DEG_ITER_            "MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_DEG_ITER"
#define MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_ITER_                "MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_ITER"
#define MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_SUB_ITER_            "MSK_LIINF_BI_CLEAN_PRIMAL_DUAL_SUB_ITER"
#define MSK_LIINF_BI_CLEAN_PRIMAL_ITER_                     "MSK_LIINF_BI_CLEAN_PRIMAL_ITER"
#define MSK_LIINF_BI_DUAL_ITER_                             "MSK_LIINF_BI_DUAL_ITER"
#define MSK_LIINF_BI_PRIMAL_ITER_                           "MSK_LIINF_BI_PRIMAL_ITER"
#define MSK_LIINF_INTPNT_FACTOR_NUM_NZ_                     "MSK_LIINF_INTPNT_FACTOR_NUM_NZ"
#define MSK_LIINF_MIO_INTPNT_ITER_                          "MSK_LIINF_MIO_INTPNT_ITER"
#define MSK_LIINF_MIO_SIMPLEX_ITER_                         "MSK_LIINF_MIO_SIMPLEX_ITER"
#define MSK_LIINF_RD_NUMANZ_                                "MSK_LIINF_RD_NUMANZ"
#define MSK_LIINF_RD_NUMQNZ_                                "MSK_LIINF_RD_NUMQNZ"



/* Typedefs */

typedef char       MSKchart;
typedef void     * MSKvoid_t;


#ifdef  MSKUINT64
typedef MSKUINT64 __mskuint64;
#else
typedef unsigned long long __mskuint64;
#endif
#ifdef  MSKINT64
typedef MSKINT64 __mskint64;
#else
typedef long long __mskint64;
#endif

#if defined(LLONG_MAX) && LLONG_MAX <= INT_MAX
#warning "Expected (long long) to be a 64bit type. MOSEK API functions may not work."
#endif
typedef int          __mskint32;
typedef unsigned int __mskuint32;

/*
typedef unsigned int       __mskuint32;
typedef signed   int       __mskint32;
typedef unsigned long long __mskuint64;
typedef signed   long long __mskint64;
*/

/* Enumeration typedefs */
#ifndef MSK_NO_ENUMS
typedef int                     MSKsolveforme;
typedef enum MSKaccmode_enum         MSKaccmodee;
typedef int                     MSKsensitivitytypee;
typedef int                     MSKqreadtypee;
typedef enum MSKiparam_enum          MSKiparame;
typedef enum MSKadopcode_enum        MSKadopcodee;
typedef enum MSKsolsta_enum          MSKsolstae;
typedef enum MSKobjsense_enum        MSKobjsensee;
typedef enum MSKsolitem_enum         MSKsoliteme;
typedef enum MSKboundkey_enum        MSKboundkeye;
typedef int                     MSKbasindtypee;
typedef int                     MSKbranchdire;
typedef enum MSKliinfitem_enum       MSKliinfiteme;
typedef enum MSKstreamtype_enum      MSKstreamtypee;
typedef enum MSKsimhotstart_enum     MSKsimhotstarte;
typedef enum MSKcallbackcode_enum    MSKcallbackcodee;
typedef enum MSKproblemitem_enum     MSKproblemiteme;
typedef enum MSKfeature_enum         MSKfeaturee;
typedef enum MSKsparam_enum          MSKsparame;
typedef enum MSKmark_enum            MSKmarke;
typedef enum MSKconetype_enum        MSKconetypee;
typedef int                     MSKfeasrepairtypee;
typedef int                     MSKiomodee;
typedef enum MSKadoptype_enum        MSKadoptypee;
typedef int                     MSKsimseltypee;
typedef enum MSKmsgkey_enum          MSKmsgkeye;
typedef int                     MSKmiomodee;
typedef enum MSKdinfitem_enum        MSKdinfiteme;
typedef enum MSKparametertype_enum   MSKparametertypee;
typedef enum MSKrescodetype_enum     MSKrescodetypee;
typedef enum MSKprosta_enum          MSKprostae;
typedef int                     MSKscalingtypee;
typedef enum MSKrescode_enum         MSKrescodee;
typedef int                     MSKmionodeseltypee;
typedef int                     MSKonoffkeye;
typedef enum MSKsimdegen_enum        MSKsimdegene;
typedef int                     MSKdataformate;
typedef int                     MSKorderingtypee;
typedef enum MSKproblemtype_enum     MSKproblemtypee;
typedef enum MSKinftype_enum         MSKinftypee;
typedef int                     MSKpresolvemodee;
typedef enum MSKdparam_enum          MSKdparame;
typedef enum MSKsimdupvec_enum       MSKsimdupvece;
typedef int                     MSKnetworkdetecte;
typedef int                     MSKcompresstypee;
typedef int                     MSKmpsformate;
typedef enum MSKvariabletype_enum    MSKvariabletypee;
typedef int                     MSKcheckconvexitytypee;
typedef enum MSKlanguage_enum        MSKlanguagee;
typedef int                     MSKstartpointtypee;
typedef enum MSKsoltype_enum         MSKsoltypee;
typedef int                     MSKscalingmethode;
typedef int                     MSKvaluee;
typedef enum MSKstakey_enum          MSKstakeye;
typedef enum MSKsimreform_enum       MSKsimreforme;
typedef enum MSKiinfitem_enum        MSKiinfiteme;
typedef enum MSKxmlwriteroutputtype_enum MSKxmlwriteroutputtypee;
typedef int                     MSKoptimizertypee;
typedef int                     MSKcputypee;
typedef int                     MSKmiocontsoltypee;
#else
typedef int                     MSKsolveforme;
typedef int                     MSKaccmodee;
typedef int                     MSKsensitivitytypee;
typedef int                     MSKqreadtypee;
typedef int                     MSKiparame;
typedef int                     MSKadopcodee;
typedef int                     MSKsolstae;
typedef int                     MSKobjsensee;
typedef int                     MSKsoliteme;
typedef int                     MSKboundkeye;
typedef int                     MSKbasindtypee;
typedef int                     MSKbranchdire;
typedef int                     MSKliinfiteme;
typedef int                     MSKstreamtypee;
typedef int                     MSKsimhotstarte;
typedef int                     MSKcallbackcodee;
typedef int                     MSKproblemiteme;
typedef int                     MSKfeaturee;
typedef int                     MSKsparame;
typedef int                     MSKmarke;
typedef int                     MSKconetypee;
typedef int                     MSKfeasrepairtypee;
typedef int                     MSKiomodee;
typedef int                     MSKadoptypee;
typedef int                     MSKsimseltypee;
typedef int                     MSKmsgkeye;
typedef int                     MSKmiomodee;
typedef int                     MSKdinfiteme;
typedef int                     MSKparametertypee;
typedef int                     MSKrescodetypee;
typedef int                     MSKprostae;
typedef int                     MSKscalingtypee;
typedef int                     MSKrescodee;
typedef int                     MSKmionodeseltypee;
typedef int                     MSKonoffkeye;
typedef int                     MSKsimdegene;
typedef int                     MSKdataformate;
typedef int                     MSKorderingtypee;
typedef int                     MSKproblemtypee;
typedef int                     MSKinftypee;
typedef int                     MSKpresolvemodee;
typedef int                     MSKdparame;
typedef int                     MSKsimdupvece;
typedef int                     MSKnetworkdetecte;
typedef int                     MSKcompresstypee;
typedef int                     MSKmpsformate;
typedef int                     MSKvariabletypee;
typedef int                     MSKcheckconvexitytypee;
typedef int                     MSKlanguagee;
typedef int                     MSKstartpointtypee;
typedef int                     MSKsoltypee;
typedef int                     MSKscalingmethode;
typedef int                     MSKvaluee;
typedef int                     MSKstakeye;
typedef int                     MSKsimreforme;
typedef int                     MSKiinfiteme;
typedef int                     MSKxmlwriteroutputtypee;
typedef int                     MSKoptimizertypee;
typedef int                     MSKcputypee;
typedef int                     MSKmiocontsoltypee;
#endif

/* Simple typedefs */
typedef void * MSKenv_t;

typedef void * MSKtask_t;

typedef void * MSKuserhandle_t;

typedef int MSKbooleant;

typedef int MSKoprt;

typedef int MSKintt;

typedef int MSKlintt;

typedef int MSKidxt;

typedef int MSKlidxt;

typedef __mskuint32 MSKuint32t;

typedef __mskint32 MSKint32t;

typedef __mskuint64 MSKuint64t;

typedef __mskint64 MSKint64t;

typedef wchar_t MSKwchart;

typedef double MSKrealt;

typedef char * MSKstring_t;

/* Function typedefs */
typedef MSKintt  (MSKAPI * MSKcallbackfunc) (
	MSKtask_t task,
	MSKuserhandle_t usrptr,
	MSKcallbackcodee caller);

typedef void  (MSKAPI * MSKexitfunc) (
	MSKuserhandle_t usrptr,
	MSKCONST char * file,
	MSKintt line,
	MSKCONST char * msg);

typedef void  (MSKAPI * MSKfreefunc) (
	MSKuserhandle_t usrptr,
	void * buffer);

typedef void *  (MSKAPI * MSKmallocfunc) (
	MSKuserhandle_t usrptr,
	MSKCONST size_t size);

typedef MSKintt  (MSKAPI * MSKnlgetspfunc) (
	MSKuserhandle_t nlhandle,
	MSKintt * numgrdobjnz,
	MSKidxt * grdobjsub,
	MSKidxt i,
	MSKbooleant * convali,
	MSKintt * grdconinz,
	MSKidxt * grdconisub,
	MSKintt yo,
	MSKintt numycnz,
	MSKCONST MSKidxt * ycsub,
	MSKintt maxnumhesnz,
	MSKintt * numhesnz,
	MSKidxt * hessubi,
	MSKidxt * hessubj);

typedef MSKintt  (MSKAPI * MSKnlgetvafunc) (
	MSKuserhandle_t nlhandle,
	MSKCONST MSKrealt * xx,
	MSKrealt yo,
	MSKCONST MSKrealt * yc,
	MSKrealt * objval,
	MSKintt * numgrdobjnz,
	MSKidxt * grdobjsub,
	MSKrealt * grdobjval,
	MSKintt numi,
	MSKCONST MSKidxt * subi,
	MSKrealt * conval,
	MSKCONST MSKintt * grdconptrb,
	MSKCONST MSKintt * grdconptre,
	MSKCONST MSKidxt * grdconsub,
	MSKrealt * grdconval,
	MSKrealt * grdlag,
	MSKintt maxnumhesnz,
	MSKintt * numhesnz,
	MSKidxt * hessubi,
	MSKidxt * hessubj,
	MSKrealt * hesval);

typedef void  (MSKAPI * MSKstreamfunc) (
	MSKuserhandle_t handle,
	MSKCONST char * str);

typedef MSKrescodee  (MSKAPI * MSKresponsefunc) (
	MSKuserhandle_t handle,
	MSKrescodee r,
	MSKCONST char * msg);




/* Functions */

/* using __cplusplus */
#ifdef __cplusplus
extern "C" {
#endif

/* MSK_analyzeproblem */
MSKrescodee (MSKAPI MSK_analyzeproblem) (
	MSKtask_t task,
	MSKstreamtypee whichstream);

/* MSK_analyzesolution */
MSKrescodee (MSKAPI MSK_analyzesolution) (
	MSKtask_t task,
	MSKstreamtypee whichstream,
	MSKsoltypee whichsol);

/* MSK_initbasissolve */
MSKrescodee (MSKAPI MSK_initbasissolve) (
	MSKtask_t task,
	MSKidxt * basis);

/* MSK_solvewithbasis */
MSKrescodee (MSKAPI MSK_solvewithbasis) (
	MSKtask_t task,
	MSKintt transp,
	MSKintt * numnz,
	MSKidxt * sub,
	MSKrealt * val);

/* MSK_basiscond */
MSKrescodee (MSKAPI MSK_basiscond) (
	MSKtask_t task,
	MSKrealt * nrmbasis,
	MSKrealt * nrminvbasis);

/* MSK_append */
MSKrescodee (MSKAPI MSK_append) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKintt num);

/* MSK_remove */
MSKrescodee (MSKAPI MSK_remove) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKintt num,
	MSKCONST MSKintt * sub);

/* MSK_appendcone */
MSKrescodee (MSKAPI MSK_appendcone) (
	MSKtask_t task,
	MSKconetypee conetype,
	MSKrealt conepar,
	MSKintt nummem,
	MSKCONST MSKidxt * submem);

/* MSK_removecone */
MSKrescodee (MSKAPI MSK_removecone) (
	MSKtask_t task,
	MSKidxt k);

/* MSK_bktostr */
MSKrescodee (MSKAPI MSK_bktostr) (
	MSKtask_t task,
	MSKboundkeye bk,
	char * str);

/* MSK_callbackcodetostr */
MSKrescodee (MSKAPI MSK_callbackcodetostr) (
	MSKcallbackcodee code,
	char * callbackcodestr);

/* MSK_calloctask */
void * (MSKAPI MSK_calloctask) (
	MSKtask_t task,
	MSKCONST size_t number,
	MSKCONST size_t size);

/* MSK_callocdbgtask */
void * (MSKAPI MSK_callocdbgtask) (
	MSKtask_t task,
	MSKCONST size_t number,
	MSKCONST size_t size,
	MSKCONST char * file,
	MSKCONST unsigned line);

/* MSK_chgbound */
MSKrescodee (MSKAPI MSK_chgbound) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKintt lower,
	MSKintt finite,
	MSKrealt value);

/* MSK_conetypetostr */
MSKrescodee (MSKAPI MSK_conetypetostr) (
	MSKtask_t task,
	MSKconetypee conetype,
	char * str);

/* MSK_deletetask */
MSKrescodee (MSKAPI MSK_deletetask) (
	MSKtask_t * task);

/* MSK_exceptiontask */
MSKrescodee (MSKAPIVA MSK_exceptiontask) (
	MSKtask_t task,
	MSKrescodee code,
	...);

/* MSK_echotask */
MSKrescodee (MSKAPIVA MSK_echotask) (
	MSKtask_t task,
	MSKstreamtypee whichstream,
	MSKCONST char * format,
	...);

/* MSK_freetask */
void (MSKAPI MSK_freetask) (
	MSKtask_t task,
	MSKCONST void * buffer);

/* MSK_freedbgtask */
void (MSKAPI MSK_freedbgtask) (
	MSKtask_t task,
	MSKCONST void * buffer,
	MSKCONST char * file,
	MSKCONST unsigned line);

/* MSK_getaij */
MSKrescodee (MSKAPI MSK_getaij) (
	MSKtask_t task,
	MSKidxt i,
	MSKidxt j,
	MSKrealt * aij);

/* MSK_getapiecenumnz */
MSKrescodee (MSKAPI MSK_getapiecenumnz) (
	MSKtask_t task,
	MSKidxt firsti,
	MSKidxt lasti,
	MSKidxt firstj,
	MSKidxt lastj,
	MSKintt * numnz);

/* MSK_getavecnumnz */
MSKrescodee (MSKAPI MSK_getavecnumnz) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKintt * nzj);

/* MSK_getavec */
MSKrescodee (MSKAPI MSK_getavec) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKintt * nzi,
	MSKidxt * subi,
	MSKrealt * vali);

/* MSK_getaslicenumnz */
MSKrescodee (MSKAPI MSK_getaslicenumnz) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt first,
	MSKidxt last,
	MSKintt * numnz);

/* MSK_getaslicenumnz64 */
MSKrescodee (MSKAPI MSK_getaslicenumnz64) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt first,
	MSKidxt last,
	MSKint64t * numnz);

/* MSK_getaslice */
MSKrescodee (MSKAPI MSK_getaslice) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt first,
	MSKidxt last,
	MSKintt maxnumnz,
	MSKintt * surp,
	MSKintt * ptrb,
	MSKlidxt * ptre,
	MSKidxt * sub,
	MSKrealt * val);

/* MSK_getaslice64 */
MSKrescodee (MSKAPI MSK_getaslice64) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt first,
	MSKidxt last,
	MSKint64t maxnumnz,
	MSKint64t * surp,
	MSKint64t * ptrb,
	MSKint64t * ptre,
	MSKidxt * sub,
	MSKrealt * val);

/* MSK_getaslicetrip */
MSKrescodee (MSKAPI MSK_getaslicetrip) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt first,
	MSKidxt last,
	MSKintt maxnumnz,
	MSKintt * surp,
	MSKidxt * subi,
	MSKidxt * subj,
	MSKrealt * val);

/* MSK_getbound */
MSKrescodee (MSKAPI MSK_getbound) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKboundkeye * bk,
	MSKrealt * bl,
	MSKrealt * bu);

/* MSK_getboundslice */
MSKrescodee (MSKAPI MSK_getboundslice) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt first,
	MSKidxt last,
	MSKboundkeye * bk,
	MSKrealt * bl,
	MSKrealt * bu);

/* MSK_putboundslice */
MSKrescodee (MSKAPI MSK_putboundslice) (
	MSKtask_t task,
	MSKaccmodee con,
	MSKidxt first,
	MSKidxt last,
	MSKCONST MSKboundkeye * bk,
	MSKCONST MSKrealt * bl,
	MSKCONST MSKrealt * bu);

/* MSK_getc */
MSKrescodee (MSKAPI MSK_getc) (
	MSKtask_t task,
	MSKrealt * c);

/* MSK_getcallbackfunc */
MSKrescodee (MSKAPI MSK_getcallbackfunc) (
	MSKtask_t task,
	MSKcallbackfunc * func,
	MSKuserhandle_t * handle);

/* MSK_getsolutionincallback */
MSKrescodee (MSKAPI MSK_getsolutionincallback) (
	MSKtask_t task,
	MSKcallbackcodee where,
	MSKsoltypee whichsol,
	MSKprostae * prosta,
	MSKsolstae * solsta,
	MSKstakeye * skc,
	MSKstakeye * skx,
	MSKstakeye * skn,
	MSKrealt * xc,
	MSKrealt * xx,
	MSKrealt * y,
	MSKrealt * slc,
	MSKrealt * suc,
	MSKrealt * slx,
	MSKrealt * sux,
	MSKrealt * snx);

/* MSK_getcfix */
MSKrescodee (MSKAPI MSK_getcfix) (
	MSKtask_t task,
	MSKrealt * cfix);

/* MSK_getcone */
MSKrescodee (MSKAPI MSK_getcone) (
	MSKtask_t task,
	MSKidxt k,
	MSKconetypee * conetype,
	MSKrealt * conepar,
	MSKintt * nummem,
	MSKidxt * submem);

/* MSK_getconeinfo */
MSKrescodee (MSKAPI MSK_getconeinfo) (
	MSKtask_t task,
	MSKidxt k,
	MSKconetypee * conetype,
	MSKrealt * conepar,
	MSKintt * nummem);

/* MSK_getcslice */
MSKrescodee (MSKAPI MSK_getcslice) (
	MSKtask_t task,
	MSKidxt first,
	MSKidxt last,
	MSKrealt * c);

/* MSK_getdouinf */
MSKrescodee (MSKAPI MSK_getdouinf) (
	MSKtask_t task,
	MSKdinfiteme whichdinf,
	MSKrealt * dvalue);

/* MSK_getdouparam */
MSKrescodee (MSKAPI MSK_getdouparam) (
	MSKtask_t task,
	MSKdparame param,
	MSKrealt * parvalue);

/* MSK_getdualobj */
MSKrescodee (MSKAPI MSK_getdualobj) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKrealt * dualobj);

/* MSK_getenv */
MSKrescodee (MSKAPI MSK_getenv) (
	MSKtask_t task,
	MSKenv_t * env);

/* MSK_getinfindex */
MSKrescodee (MSKAPI MSK_getinfindex) (
	MSKtask_t task,
	MSKinftypee inftype,
	MSKCONST char * infname,
	MSKintt * infindex);

/* MSK_getinfmax */
MSKrescodee (MSKAPI MSK_getinfmax) (
	MSKtask_t task,
	MSKinftypee inftype,
	MSKintt * infmax);

/* MSK_getinfname */
MSKrescodee (MSKAPI MSK_getinfname) (
	MSKtask_t task,
	MSKinftypee inftype,
	MSKintt whichinf,
	char * infname);

/* MSK_getintinf */
MSKrescodee (MSKAPI MSK_getintinf) (
	MSKtask_t task,
	MSKiinfiteme whichiinf,
	MSKintt * ivalue);

/* MSK_getlintinf */
MSKrescodee (MSKAPI MSK_getlintinf) (
	MSKtask_t task,
	MSKliinfiteme whichliinf,
	MSKint64t * ivalue);

/* MSK_getintparam */
MSKrescodee (MSKAPI MSK_getintparam) (
	MSKtask_t task,
	MSKiparame param,
	MSKintt * parvalue);

/* MSK_getmaxnamelen */
MSKrescodee (MSKAPI MSK_getmaxnamelen) (
	MSKtask_t task,
	size_t * maxlen);

/* MSK_getmaxnumanz */
MSKrescodee (MSKAPI MSK_getmaxnumanz) (
	MSKtask_t task,
	MSKintt * maxnumanz);

/* MSK_getmaxnumanz64 */
MSKrescodee (MSKAPI MSK_getmaxnumanz64) (
	MSKtask_t task,
	MSKint64t * maxnumanz);

/* MSK_getmaxnumcon */
MSKrescodee (MSKAPI MSK_getmaxnumcon) (
	MSKtask_t task,
	MSKintt * maxnumcon);

/* MSK_getmaxnumvar */
MSKrescodee (MSKAPI MSK_getmaxnumvar) (
	MSKtask_t task,
	MSKintt * maxnumvar);

/* MSK_getnadouinf */
MSKrescodee (MSKAPI MSK_getnadouinf) (
	MSKtask_t task,
	MSKCONST char * whichdinf,
	MSKrealt * dvalue);

/* MSK_getnadouparam */
MSKrescodee (MSKAPI MSK_getnadouparam) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKrealt * parvalue);

/* MSK_getnaintinf */
MSKrescodee (MSKAPI MSK_getnaintinf) (
	MSKtask_t task,
	MSKCONST char * infitemname,
	MSKintt * ivalue);

/* MSK_getnaintparam */
MSKrescodee (MSKAPI MSK_getnaintparam) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKintt * parvalue);

/* MSK_getnamelen64 */
MSKrescodee (MSKAPI MSK_getnamelen64) (
	MSKtask_t task,
	MSKproblemiteme whichitem,
	MSKidxt i,
	MSKint64t * len);

/* MSK_getname */
MSKrescodee (MSKAPI MSK_getname) (
	MSKtask_t task,
	MSKproblemiteme whichitem,
	MSKidxt i,
	MSKCONST size_t maxlen,
	size_t * len,
	char * name);

/* MSK_getname64 */
MSKrescodee (MSKAPI MSK_getname64) (
	MSKtask_t task,
	MSKproblemiteme whichitem,
	MSKidxt i,
	MSKint64t maxlen,
	MSKint64t * len,
	char * name);

/* MSK_getnameapi64 */
MSKrescodee (MSKAPI MSK_getnameapi64) (
	MSKtask_t task,
	MSKproblemiteme whichitem,
	MSKidxt i,
	MSKint64t maxlen,
	char * name);

/* MSK_getvarname */
MSKrescodee (MSKAPI MSK_getvarname) (
	MSKtask_t task,
	MSKidxt i,
	MSKCONST size_t maxlen,
	char * name);

/* MSK_getvarname64 */
MSKrescodee (MSKAPI MSK_getvarname64) (
	MSKtask_t task,
	MSKidxt i,
	MSKint64t maxlen,
	char * name);

/* MSK_getconname */
MSKrescodee (MSKAPI MSK_getconname) (
	MSKtask_t task,
	MSKidxt i,
	MSKCONST size_t maxlen,
	char * name);

/* MSK_getconname64 */
MSKrescodee (MSKAPI MSK_getconname64) (
	MSKtask_t task,
	MSKidxt i,
	MSKint64t maxlen,
	char * name);

/* MSK_getnameindex */
MSKrescodee (MSKAPI MSK_getnameindex) (
	MSKtask_t task,
	MSKproblemiteme whichitem,
	MSKCONST char * name,
	MSKintt * asgn,
	MSKidxt * index);

/* MSK_getnastrparam */
MSKrescodee (MSKAPI MSK_getnastrparam) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKCONST size_t maxlen,
	size_t * len,
	char * parvalue);

/* MSK_getnumanz */
MSKrescodee (MSKAPI MSK_getnumanz) (
	MSKtask_t task,
	MSKintt * numanz);

/* MSK_getnumanz64 */
MSKrescodee (MSKAPI MSK_getnumanz64) (
	MSKtask_t task,
	MSKint64t * numanz);

/* MSK_getnumcon */
MSKrescodee (MSKAPI MSK_getnumcon) (
	MSKtask_t task,
	MSKintt * numcon);

/* MSK_getnumcone */
MSKrescodee (MSKAPI MSK_getnumcone) (
	MSKtask_t task,
	MSKintt * numcone);

/* MSK_getnumconemem */
MSKrescodee (MSKAPI MSK_getnumconemem) (
	MSKtask_t task,
	MSKidxt k,
	MSKintt * nummem);

/* MSK_getnumintvar */
MSKrescodee (MSKAPI MSK_getnumintvar) (
	MSKtask_t task,
	MSKintt * numintvar);

/* MSK_getnumparam */
MSKrescodee (MSKAPI MSK_getnumparam) (
	MSKtask_t task,
	MSKparametertypee partype,
	MSKintt * numparam);

/* MSK_getnumqconknz */
MSKrescodee (MSKAPI MSK_getnumqconknz) (
	MSKtask_t task,
	MSKidxt k,
	MSKintt * numqcnz);

/* MSK_getnumqconknz64 */
MSKrescodee (MSKAPI MSK_getnumqconknz64) (
	MSKtask_t task,
	MSKidxt k,
	MSKint64t * numqcnz);

/* MSK_getnumqobjnz */
MSKrescodee (MSKAPI MSK_getnumqobjnz) (
	MSKtask_t task,
	MSKintt * numqonz);

/* MSK_getnumqobjnz64 */
MSKrescodee (MSKAPI MSK_getnumqobjnz64) (
	MSKtask_t task,
	MSKint64t * numqonz);

/* MSK_getnumvar */
MSKrescodee (MSKAPI MSK_getnumvar) (
	MSKtask_t task,
	MSKintt * numvar);

/* MSK_getobjname */
MSKrescodee (MSKAPI MSK_getobjname) (
	MSKtask_t task,
	MSKCONST size_t maxlen,
	size_t * len,
	char * objname);

/* MSK_getobjname64 */
MSKrescodee (MSKAPI MSK_getobjname64) (
	MSKtask_t task,
	MSKint64t maxlen,
	MSKint64t * len,
	char * objname);

/* MSK_getparamname */
MSKrescodee (MSKAPI MSK_getparamname) (
	MSKtask_t task,
	MSKparametertypee partype,
	MSKintt param,
	char * parname);

/* MSK_getparammax */
MSKrescodee (MSKAPI MSK_getparammax) (
	MSKtask_t task,
	MSKparametertypee partype,
	MSKCONST MSKintt * parammax);

/* MSK_getprimalobj */
MSKrescodee (MSKAPI MSK_getprimalobj) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKrealt * primalobj);

/* MSK_getprobtype */
MSKrescodee (MSKAPI MSK_getprobtype) (
	MSKtask_t task,
	MSKproblemtypee * probtype);

/* MSK_getqconk64 */
MSKrescodee (MSKAPI MSK_getqconk64) (
	MSKtask_t task,
	MSKidxt k,
	MSKint64t maxnumqcnz,
	MSKint64t * qcsurp,
	MSKint64t * numqcnz,
	MSKidxt * qcsubi,
	MSKidxt * qcsubj,
	MSKrealt * qcval);

/* MSK_getqconk */
MSKrescodee (MSKAPI MSK_getqconk) (
	MSKtask_t task,
	MSKidxt k,
	MSKintt maxnumqcnz,
	MSKintt * qcsurp,
	MSKintt * numqcnz,
	MSKidxt * qcsubi,
	MSKidxt * qcsubj,
	MSKrealt * qcval);

/* MSK_getqobj */
MSKrescodee (MSKAPI MSK_getqobj) (
	MSKtask_t task,
	MSKintt maxnumqonz,
	MSKintt * qosurp,
	MSKintt * numqonz,
	MSKidxt * qosubi,
	MSKidxt * qosubj,
	MSKrealt * qoval);

/* MSK_getqobj64 */
MSKrescodee (MSKAPI MSK_getqobj64) (
	MSKtask_t task,
	MSKint64t maxnumqonz,
	MSKint64t * qosurp,
	MSKint64t * numqonz,
	MSKidxt * qosubi,
	MSKidxt * qosubj,
	MSKrealt * qoval);

/* MSK_getqobjij */
MSKrescodee (MSKAPI MSK_getqobjij) (
	MSKtask_t task,
	MSKidxt i,
	MSKidxt j,
	MSKrealt * qoij);

/* MSK_getsolution */
MSKrescodee (MSKAPI MSK_getsolution) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKprostae * prosta,
	MSKsolstae * solsta,
	MSKstakeye * skc,
	MSKstakeye * skx,
	MSKstakeye * skn,
	MSKrealt * xc,
	MSKrealt * xx,
	MSKrealt * y,
	MSKrealt * slc,
	MSKrealt * suc,
	MSKrealt * slx,
	MSKrealt * sux,
	MSKrealt * snx);

/* MSK_getpbi */
MSKrescodee (MSKAPI MSK_getpbi) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKaccmodee accmode,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * pbi,
	MSKintt normalize);

/* MSK_getdbi */
MSKrescodee (MSKAPI MSK_getdbi) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKaccmodee accmode,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * dbi);

/* MSK_getdeqi */
MSKrescodee (MSKAPI MSK_getdeqi) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKaccmodee accmode,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * deqi,
	MSKintt normalize);

/* MSK_getpeqi */
MSKrescodee (MSKAPI MSK_getpeqi) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * peqi,
	MSKintt normalize);

/* MSK_getinti */
MSKrescodee (MSKAPI MSK_getinti) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * inti);

/* MSK_getpcni */
MSKrescodee (MSKAPI MSK_getpcni) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * pcni);

/* MSK_getdcni */
MSKrescodee (MSKAPI MSK_getdcni) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST MSKidxt * sub,
	MSKintt len,
	MSKrealt * dcni);

/* MSK_getsolutioni */
MSKrescodee (MSKAPI MSK_getsolutioni) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKsoltypee whichsol,
	MSKstakeye * sk,
	MSKrealt * x,
	MSKrealt * sl,
	MSKrealt * su,
	MSKrealt * sn);

/* MSK_getsolutioninf */
MSKrescodee (MSKAPI MSK_getsolutioninf) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKprostae * prosta,
	MSKsolstae * solsta,
	MSKrealt * primalobj,
	MSKrealt * maxpbi,
	MSKrealt * maxpcni,
	MSKrealt * maxpeqi,
	MSKrealt * maxinti,
	MSKrealt * dualobj,
	MSKrealt * maxdbi,
	MSKrealt * maxdcni,
	MSKrealt * maxdeqi);

/* MSK_getsolutionstatus */
MSKrescodee (MSKAPI MSK_getsolutionstatus) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKprostae * prosta,
	MSKsolstae * solsta);

/* MSK_getsolutionslice */
MSKrescodee (MSKAPI MSK_getsolutionslice) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKsoliteme solitem,
	MSKidxt first,
	MSKidxt last,
	MSKrealt * values);

/* MSK_getsolutionstatuskeyslice */
MSKrescodee (MSKAPI MSK_getsolutionstatuskeyslice) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKsoltypee whichsol,
	MSKidxt first,
	MSKidxt last,
	MSKstakeye * sk);

/* MSK_getreducedcosts */
MSKrescodee (MSKAPI MSK_getreducedcosts) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKidxt first,
	MSKidxt last,
	MSKrealt * redcosts);

/* MSK_getstrparam */
MSKrescodee (MSKAPI MSK_getstrparam) (
	MSKtask_t task,
	MSKsparame param,
	MSKCONST size_t maxlen,
	size_t * len,
	char * parvalue);

/* MSK_getstrparam64 */
MSKrescodee (MSKAPI MSK_getstrparam64) (
	MSKtask_t task,
	MSKsparame param,
	MSKint64t maxlen,
	MSKint64t * len,
	char * parvalue);

/* MSK_getstrparamal */
MSKrescodee (MSKAPI MSK_getstrparamal) (
	MSKtask_t task,
	MSKsparame param,
	MSKCONST size_t numaddchr,
	MSKstring_t * value);

/* MSK_getnastrparamal */
MSKrescodee (MSKAPI MSK_getnastrparamal) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKCONST size_t numaddchr,
	MSKstring_t * value);

/* MSK_getsymbcon */
MSKrescodee (MSKAPI MSK_getsymbcon) (
	MSKtask_t task,
	MSKidxt i,
	MSKCONST size_t maxlen,
	char * name,
	MSKintt * value);

/* MSK_gettaskname */
MSKrescodee (MSKAPI MSK_gettaskname) (
	MSKtask_t task,
	MSKCONST size_t maxlen,
	size_t * len,
	char * taskname);

/* MSK_gettaskname64 */
MSKrescodee (MSKAPI MSK_gettaskname64) (
	MSKtask_t task,
	MSKint64t maxlen,
	MSKint64t * len,
	char * taskname);

/* MSK_getintpntnumthreads */
MSKrescodee (MSKAPI MSK_getintpntnumthreads) (
	MSKtask_t task,
	MSKintt * numthreads);

/* MSK_getvartype */
MSKrescodee (MSKAPI MSK_getvartype) (
	MSKtask_t task,
	MSKidxt j,
	MSKvariabletypee * vartype);

/* MSK_getvartypelist */
MSKrescodee (MSKAPI MSK_getvartypelist) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKidxt * subj,
	MSKvariabletypee * vartype);

/* MSK_inputdata */
MSKrescodee (MSKAPI MSK_inputdata) (
	MSKtask_t task,
	MSKintt maxnumcon,
	MSKintt maxnumvar,
	MSKintt numcon,
	MSKintt numvar,
	MSKCONST MSKrealt * c,
	MSKrealt cfix,
	MSKCONST MSKintt * aptrb,
	MSKCONST MSKintt * aptre,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval,
	MSKCONST MSKboundkeye * bkc,
	MSKCONST MSKrealt * blc,
	MSKCONST MSKrealt * buc,
	MSKCONST MSKboundkeye * bkx,
	MSKCONST MSKrealt * blx,
	MSKCONST MSKrealt * bux);

/* MSK_inputdata64 */
MSKrescodee (MSKAPI MSK_inputdata64) (
	MSKtask_t task,
	MSKintt maxnumcon,
	MSKintt maxnumvar,
	MSKintt numcon,
	MSKintt numvar,
	MSKCONST MSKrealt * c,
	MSKrealt cfix,
	MSKCONST MSKint64t * aptrb,
	MSKCONST MSKint64t * aptre,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval,
	MSKCONST MSKboundkeye * bkc,
	MSKCONST MSKrealt * blc,
	MSKCONST MSKrealt * buc,
	MSKCONST MSKboundkeye * bkx,
	MSKCONST MSKrealt * blx,
	MSKCONST MSKrealt * bux);

/* MSK_isdouparname */
MSKrescodee (MSKAPI MSK_isdouparname) (
	MSKtask_t task,
	MSKCONST char * parname,
	MSKdparame * param);

/* MSK_isintparname */
MSKrescodee (MSKAPI MSK_isintparname) (
	MSKtask_t task,
	MSKCONST char * parname,
	MSKiparame * param);

/* MSK_isstrparname */
MSKrescodee (MSKAPI MSK_isstrparname) (
	MSKtask_t task,
	MSKCONST char * parname,
	MSKsparame * param);

/* MSK_linkfiletotaskstream */
MSKrescodee (MSKAPI MSK_linkfiletotaskstream) (
	MSKtask_t task,
	MSKstreamtypee whichstream,
	MSKCONST char * filename,
	MSKintt append);

/* MSK_linkfunctotaskstream */
MSKrescodee (MSKAPI MSK_linkfunctotaskstream) (
	MSKtask_t task,
	MSKstreamtypee whichstream,
	MSKuserhandle_t handle,
	MSKstreamfunc func);

/* MSK_unlinkfuncfromtaskstream */
MSKrescodee (MSKAPI MSK_unlinkfuncfromtaskstream) (
	MSKtask_t task,
	MSKstreamtypee whichstream);

/* MSK_clonetask */
MSKrescodee (MSKAPI MSK_clonetask) (
	MSKtask_t task,
	MSKtask_t * clonedtask);

/* MSK_relaxprimal */
MSKrescodee (MSKAPI MSK_relaxprimal) (
	MSKtask_t task,
	MSKtask_t * relaxedtask,
	MSKrealt * wlc,
	MSKrealt * wuc,
	MSKrealt * wlx,
	MSKrealt * wux);

/* MSK_optimizeconcurrent */
MSKrescodee (MSKAPI MSK_optimizeconcurrent) (
	MSKtask_t task,
	MSKCONST MSKtask_t * taskarray,
	MSKintt num);

/* MSK_checkdata */
MSKrescodee (MSKAPI MSK_checkdata) (
	MSKtask_t task);

/* MSK_optimize */
MSKrescodee (MSKAPI MSK_optimize) (
	MSKtask_t task);

/* MSK_netextraction */
MSKrescodee (MSKAPI MSK_netextraction) (
	MSKtask_t task,
	MSKintt * numcon,
	MSKintt * numvar,
	MSKidxt * netcon,
	MSKidxt * netvar,
	MSKrealt * scalcon,
	MSKrealt * scalvar,
	MSKrealt * cx,
	MSKboundkeye * bkc,
	MSKrealt * blc,
	MSKrealt * buc,
	MSKboundkeye * bkx,
	MSKrealt * blx,
	MSKrealt * bux,
	MSKidxt * from,
	MSKidxt * to);

/* MSK_netoptimize */
MSKrescodee (MSKAPI MSK_netoptimize) (
	MSKtask_t task,
	MSKintt numcon,
	MSKintt numvar,
	MSKCONST MSKrealt * cc,
	MSKCONST MSKrealt * cx,
	MSKCONST MSKboundkeye * bkc,
	MSKCONST MSKrealt * blc,
	MSKCONST MSKrealt * buc,
	MSKCONST MSKboundkeye * bkx,
	MSKCONST MSKrealt * blx,
	MSKCONST MSKrealt * bux,
	MSKCONST MSKidxt * from,
	MSKCONST MSKidxt * to,
	MSKprostae * prosta,
	MSKsolstae * solsta,
	MSKbooleant hotstart,
	MSKstakeye * skc,
	MSKstakeye * skx,
	MSKrealt * xc,
	MSKrealt * xx,
	MSKrealt * y,
	MSKrealt * slc,
	MSKrealt * suc,
	MSKrealt * slx,
	MSKrealt * sux);

/* MSK_optimizetrm */
MSKrescodee (MSKAPI MSK_optimizetrm) (
	MSKtask_t task,
	MSKrescodee * trmcode);

/* MSK_printdata */
MSKrescodee (MSKAPI MSK_printdata) (
	MSKtask_t task,
	MSKstreamtypee whichstream,
	MSKidxt firsti,
	MSKidxt lasti,
	MSKidxt firstj,
	MSKidxt lastj,
	MSKidxt firstk,
	MSKidxt lastk,
	MSKintt c,
	MSKintt qo,
	MSKintt a,
	MSKintt qc,
	MSKintt bc,
	MSKintt bx,
	MSKintt vartype,
	MSKintt cones);

/* MSK_printparam */
MSKrescodee (MSKAPI MSK_printparam) (
	MSKtask_t task);

/* MSK_probtypetostr */
MSKrescodee (MSKAPI MSK_probtypetostr) (
	MSKtask_t task,
	MSKproblemtypee probtype,
	char * str);

/* MSK_prostatostr */
MSKrescodee (MSKAPI MSK_prostatostr) (
	MSKtask_t task,
	MSKprostae prosta,
	char * str);

/* MSK_putresponsefunc */
MSKrescodee (MSKAPI MSK_putresponsefunc) (
	MSKtask_t task,
	MSKresponsefunc responsefunc,
	MSKuserhandle_t handle);

/* MSK_commitchanges */
MSKrescodee (MSKAPI MSK_commitchanges) (
	MSKtask_t task);

/* MSK_putaij */
MSKrescodee (MSKAPI MSK_putaij) (
	MSKtask_t task,
	MSKidxt i,
	MSKidxt j,
	MSKrealt aij);

/* MSK_putaijlist */
MSKrescodee (MSKAPI MSK_putaijlist) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKidxt * subi,
	MSKCONST MSKidxt * subj,
	MSKCONST MSKrealt * valij);

/* MSK_putavec */
MSKrescodee (MSKAPI MSK_putavec) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKintt nzi,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval);

/* MSK_putaveclist */
MSKrescodee (MSKAPI MSK_putaveclist) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKintt num,
	MSKCONST MSKidxt * sub,
	MSKCONST MSKintt * ptrb,
	MSKCONST MSKintt * ptre,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval);

/* MSK_putaveclist64 */
MSKrescodee (MSKAPI MSK_putaveclist64) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKintt num,
	MSKCONST MSKidxt * sub,
	MSKCONST MSKint64t * ptrb,
	MSKCONST MSKint64t * ptre,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval);

/* MSK_putbound */
MSKrescodee (MSKAPI MSK_putbound) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKboundkeye bk,
	MSKrealt bl,
	MSKrealt bu);

/* MSK_putboundlist */
MSKrescodee (MSKAPI MSK_putboundlist) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKintt num,
	MSKCONST MSKidxt * sub,
	MSKCONST MSKboundkeye * bk,
	MSKCONST MSKrealt * bl,
	MSKCONST MSKrealt * bu);

/* MSK_putcallbackfunc */
MSKrescodee (MSKAPI MSK_putcallbackfunc) (
	MSKtask_t task,
	MSKcallbackfunc func,
	MSKuserhandle_t handle);

/* MSK_putcfix */
MSKrescodee (MSKAPI MSK_putcfix) (
	MSKtask_t task,
	MSKrealt cfix);

/* MSK_putcj */
MSKrescodee (MSKAPI MSK_putcj) (
	MSKtask_t task,
	MSKidxt j,
	MSKrealt cj);

/* MSK_putobjsense */
MSKrescodee (MSKAPI MSK_putobjsense) (
	MSKtask_t task,
	MSKobjsensee sense);

/* MSK_getobjsense */
MSKrescodee (MSKAPI MSK_getobjsense) (
	MSKtask_t task,
	MSKobjsensee * sense);

/* MSK_putclist */
MSKrescodee (MSKAPI MSK_putclist) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKidxt * subj,
	MSKCONST MSKrealt * val);

/* MSK_putcone */
MSKrescodee (MSKAPI MSK_putcone) (
	MSKtask_t task,
	MSKidxt k,
	MSKconetypee conetype,
	MSKrealt conepar,
	MSKintt nummem,
	MSKCONST MSKidxt * submem);

/* MSK_putdouparam */
MSKrescodee (MSKAPI MSK_putdouparam) (
	MSKtask_t task,
	MSKdparame param,
	MSKrealt parvalue);

/* MSK_putintparam */
MSKrescodee (MSKAPI MSK_putintparam) (
	MSKtask_t task,
	MSKiparame param,
	MSKintt parvalue);

/* MSK_putmaxnumcon */
MSKrescodee (MSKAPI MSK_putmaxnumcon) (
	MSKtask_t task,
	MSKintt maxnumcon);

/* MSK_putmaxnumcone */
MSKrescodee (MSKAPI MSK_putmaxnumcone) (
	MSKtask_t task,
	MSKintt maxnumcone);

/* MSK_getmaxnumcone */
MSKrescodee (MSKAPI MSK_getmaxnumcone) (
	MSKtask_t task,
	MSKintt * maxnumcone);

/* MSK_putmaxnumvar */
MSKrescodee (MSKAPI MSK_putmaxnumvar) (
	MSKtask_t task,
	MSKintt maxnumvar);

/* MSK_putmaxnumanz */
MSKrescodee (MSKAPI MSK_putmaxnumanz) (
	MSKtask_t task,
	MSKintt maxnumanz);

/* MSK_putmaxnumanz64 */
MSKrescodee (MSKAPI MSK_putmaxnumanz64) (
	MSKtask_t task,
	MSKint64t maxnumanz);

/* MSK_putmaxnumqnz */
MSKrescodee (MSKAPI MSK_putmaxnumqnz) (
	MSKtask_t task,
	MSKintt maxnumqnz);

/* MSK_putmaxnumqnz64 */
MSKrescodee (MSKAPI MSK_putmaxnumqnz64) (
	MSKtask_t task,
	MSKint64t maxnumqnz);

/* MSK_getmaxnumqnz */
MSKrescodee (MSKAPI MSK_getmaxnumqnz) (
	MSKtask_t task,
	MSKintt * maxnumqnz);

/* MSK_getmaxnumqnz64 */
MSKrescodee (MSKAPI MSK_getmaxnumqnz64) (
	MSKtask_t task,
	MSKint64t * maxnumqnz);

/* MSK_putnadouparam */
MSKrescodee (MSKAPI MSK_putnadouparam) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKrealt parvalue);

/* MSK_putnaintparam */
MSKrescodee (MSKAPI MSK_putnaintparam) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKintt parvalue);

/* MSK_putname */
MSKrescodee (MSKAPI MSK_putname) (
	MSKtask_t task,
	MSKproblemiteme whichitem,
	MSKidxt i,
	MSKCONST char * name);

/* MSK_putnastrparam */
MSKrescodee (MSKAPI MSK_putnastrparam) (
	MSKtask_t task,
	MSKCONST char * paramname,
	MSKCONST char * parvalue);

/* MSK_putnlfunc */
MSKrescodee (MSKAPI MSK_putnlfunc) (
	MSKtask_t task,
	MSKuserhandle_t nlhandle,
	MSKnlgetspfunc nlgetsp,
	MSKnlgetvafunc nlgetva);

/* MSK_getnlfunc */
MSKrescodee (MSKAPI MSK_getnlfunc) (
	MSKtask_t task,
	MSKuserhandle_t * nlhandle,
	MSKnlgetspfunc * nlgetsp,
	MSKnlgetvafunc * nlgetva);

/* MSK_putobjname */
MSKrescodee (MSKAPI MSK_putobjname) (
	MSKtask_t task,
	MSKCONST char * objname);

/* MSK_putparam */
MSKrescodee (MSKAPI MSK_putparam) (
	MSKtask_t task,
	MSKCONST char * parname,
	MSKCONST char * parvalue);

/* MSK_putqcon */
MSKrescodee (MSKAPI MSK_putqcon) (
	MSKtask_t task,
	MSKintt numqcnz,
	MSKCONST MSKidxt * qcsubk,
	MSKCONST MSKidxt * qcsubi,
	MSKCONST MSKidxt * qcsubj,
	MSKCONST MSKrealt * qcval);

/* MSK_putqconk */
MSKrescodee (MSKAPI MSK_putqconk) (
	MSKtask_t task,
	MSKidxt k,
	MSKintt numqcnz,
	MSKCONST MSKidxt * qcsubi,
	MSKCONST MSKintt * qcsubj,
	MSKCONST MSKrealt * qcval);

/* MSK_putqobj */
MSKrescodee (MSKAPI MSK_putqobj) (
	MSKtask_t task,
	MSKintt numqonz,
	MSKCONST MSKidxt * qosubi,
	MSKCONST MSKidxt * qosubj,
	MSKCONST MSKrealt * qoval);

/* MSK_putqobjij */
MSKrescodee (MSKAPI MSK_putqobjij) (
	MSKtask_t task,
	MSKidxt i,
	MSKidxt j,
	MSKrealt qoij);

/* MSK_makesolutionstatusunknown */
MSKrescodee (MSKAPI MSK_makesolutionstatusunknown) (
	MSKtask_t task,
	MSKsoltypee whichsol);

/* MSK_putsolution */
MSKrescodee (MSKAPI MSK_putsolution) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST MSKstakeye * skc,
	MSKCONST MSKstakeye * skx,
	MSKCONST MSKstakeye * skn,
	MSKCONST MSKrealt * xc,
	MSKCONST MSKrealt * xx,
	MSKCONST MSKrealt * y,
	MSKCONST MSKrealt * slc,
	MSKCONST MSKrealt * suc,
	MSKCONST MSKrealt * slx,
	MSKCONST MSKrealt * sux,
	MSKCONST MSKrealt * snx);

/* MSK_putsolutioni */
MSKrescodee (MSKAPI MSK_putsolutioni) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKidxt i,
	MSKsoltypee whichsol,
	MSKstakeye sk,
	MSKrealt x,
	MSKrealt sl,
	MSKrealt su,
	MSKrealt sn);

/* MSK_putsolutionyi */
MSKrescodee (MSKAPI MSK_putsolutionyi) (
	MSKtask_t task,
	MSKidxt i,
	MSKsoltypee whichsol,
	MSKrealt y);

/* MSK_putstrparam */
MSKrescodee (MSKAPI MSK_putstrparam) (
	MSKtask_t task,
	MSKsparame param,
	MSKCONST char * parvalue);

/* MSK_puttaskname */
MSKrescodee (MSKAPI MSK_puttaskname) (
	MSKtask_t task,
	MSKCONST char * taskname);

/* MSK_putvartype */
MSKrescodee (MSKAPI MSK_putvartype) (
	MSKtask_t task,
	MSKidxt j,
	MSKvariabletypee vartype);

/* MSK_putvartypelist */
MSKrescodee (MSKAPI MSK_putvartypelist) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKidxt * subj,
	MSKCONST MSKvariabletypee * vartype);

/* MSK_putvarbranchorder */
MSKrescodee (MSKAPI MSK_putvarbranchorder) (
	MSKtask_t task,
	MSKidxt j,
	MSKintt priority,
	int direction);

/* MSK_getvarbranchorder */
MSKrescodee (MSKAPI MSK_getvarbranchorder) (
	MSKtask_t task,
	MSKidxt j,
	MSKintt * priority,
	MSKbranchdire * direction);

/* MSK_getvarbranchpri */
MSKrescodee (MSKAPI MSK_getvarbranchpri) (
	MSKtask_t task,
	MSKidxt j,
	MSKintt * priority);

/* MSK_getvarbranchdir */
MSKrescodee (MSKAPI MSK_getvarbranchdir) (
	MSKtask_t task,
	MSKidxt j,
	MSKbranchdire * direction);

/* MSK_readdata */
MSKrescodee (MSKAPI MSK_readdata) (
	MSKtask_t task,
	MSKCONST char * filename);

/* MSK_readparamfile */
MSKrescodee (MSKAPI MSK_readparamfile) (
	MSKtask_t task);

/* MSK_readsolution */
MSKrescodee (MSKAPI MSK_readsolution) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST char * filename);

/* MSK_readsummary */
MSKrescodee (MSKAPI MSK_readsummary) (
	MSKtask_t task,
	MSKstreamtypee whichstream);

/* MSK_resizetask */
MSKrescodee (MSKAPI MSK_resizetask) (
	MSKtask_t task,
	MSKintt maxnumcon,
	MSKintt maxnumvar,
	MSKintt maxnumcone,
	MSKintt maxnumanz,
	MSKintt maxnumqnz);

/* MSK_checkmemtask */
MSKrescodee (MSKAPI MSK_checkmemtask) (
	MSKtask_t task,
	MSKCONST char * file,
	MSKintt line);

/* MSK_getmemusagetask */
MSKrescodee (MSKAPI MSK_getmemusagetask) (
	MSKtask_t task,
	size_t * meminuse,
	size_t * maxmemuse);

/* MSK_getmemusagetask64 */
MSKrescodee (MSKAPI MSK_getmemusagetask64) (
	MSKtask_t task,
	MSKint64t * meminuse,
	MSKint64t * maxmemuse);

/* MSK_setdefaults */
MSKrescodee (MSKAPI MSK_setdefaults) (
	MSKtask_t task);

/* MSK_sktostr */
MSKrescodee (MSKAPI MSK_sktostr) (
	MSKtask_t task,
	MSKintt sk,
	char * str);

/* MSK_solstatostr */
MSKrescodee (MSKAPI MSK_solstatostr) (
	MSKtask_t task,
	MSKsolstae solsta,
	char * str);

/* MSK_solutiondef */
MSKrescodee (MSKAPI MSK_solutiondef) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKintt * isdef);

/* MSK_deletesolution */
MSKrescodee (MSKAPI MSK_deletesolution) (
	MSKtask_t task,
	MSKsoltypee whichsol);

/* MSK_undefsolution */
MSKrescodee (MSKAPI MSK_undefsolution) (
	MSKtask_t task,
	MSKsoltypee whichsol);

/* MSK_solutionsummary */
MSKrescodee (MSKAPI MSK_solutionsummary) (
	MSKtask_t task,
	MSKstreamtypee whichstream);

/* MSK_optimizersummary */
MSKrescodee (MSKAPI MSK_optimizersummary) (
	MSKtask_t task,
	MSKstreamtypee whichstream);

/* MSK_strduptask */
char * (MSKAPI MSK_strduptask) (
	MSKtask_t task,
	MSKCONST char * str);

/* MSK_strdupdbgtask */
char * (MSKAPI MSK_strdupdbgtask) (
	MSKtask_t task,
	MSKCONST char * str,
	MSKCONST char * file,
	MSKCONST unsigned line);

/* MSK_strtoconetype */
MSKrescodee (MSKAPI MSK_strtoconetype) (
	MSKtask_t task,
	MSKCONST char * str,
	MSKconetypee * conetype);

/* MSK_strtosk */
MSKrescodee (MSKAPI MSK_strtosk) (
	MSKtask_t task,
	MSKCONST char * str,
	MSKintt * sk);

/* MSK_whichparam */
MSKrescodee (MSKAPI MSK_whichparam) (
	MSKtask_t task,
	MSKCONST char * parname,
	MSKparametertypee * partype,
	MSKintt * param);

/* MSK_writedata */
MSKrescodee (MSKAPI MSK_writedata) (
	MSKtask_t task,
	MSKCONST char * filename);

/* MSK_readbranchpriorities */
MSKrescodee (MSKAPI MSK_readbranchpriorities) (
	MSKtask_t task,
	MSKCONST char * filename);

/* MSK_writebranchpriorities */
MSKrescodee (MSKAPI MSK_writebranchpriorities) (
	MSKtask_t task,
	MSKCONST char * filename);

/* MSK_writeparamfile */
MSKrescodee (MSKAPI MSK_writeparamfile) (
	MSKtask_t task,
	MSKCONST char * filename);

/* MSK_getinfeasiblesubproblem */
MSKrescodee (MSKAPI MSK_getinfeasiblesubproblem) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKtask_t * inftask);

/* MSK_writesolution */
MSKrescodee (MSKAPI MSK_writesolution) (
	MSKtask_t task,
	MSKsoltypee whichsol,
	MSKCONST char * filename);

/* MSK_primalsensitivity */
MSKrescodee (MSKAPI MSK_primalsensitivity) (
	MSKtask_t task,
	MSKintt numi,
	MSKCONST MSKidxt * subi,
	MSKCONST MSKmarke * marki,
	MSKintt numj,
	MSKCONST MSKidxt * subj,
	MSKCONST MSKmarke * markj,
	MSKrealt * leftpricei,
	MSKrealt * rightpricei,
	MSKrealt * leftrangei,
	MSKrealt * rightrangei,
	MSKrealt * leftpricej,
	MSKrealt * rightpricej,
	MSKrealt * leftrangej,
	MSKrealt * rightrangej);

/* MSK_sensitivityreport */
MSKrescodee (MSKAPI MSK_sensitivityreport) (
	MSKtask_t task,
	MSKstreamtypee whichstream);

/* MSK_dualsensitivity */
MSKrescodee (MSKAPI MSK_dualsensitivity) (
	MSKtask_t task,
	MSKintt numj,
	MSKCONST MSKidxt * subj,
	MSKrealt * leftpricej,
	MSKrealt * rightpricej,
	MSKrealt * leftrangej,
	MSKrealt * rightrangej);

/* MSK_checkconvexity */
MSKrescodee (MSKAPI MSK_checkconvexity) (
	MSKtask_t task);

/* MSK_getlasterror */
MSKrescodee (MSKAPI MSK_getlasterror) (
	MSKtask_t task,
	MSKrescodee * lastrescode,
	MSKCONST size_t maxlen,
	size_t * lastmsglen,
	char * lastmsg);

/* MSK_getlasterror64 */
MSKrescodee (MSKAPI MSK_getlasterror64) (
	MSKtask_t task,
	MSKrescodee * lastrescode,
	MSKint64t maxlen,
	MSKint64t * lastmsglen,
	char * lastmsg);

/* MSK_appendvars */
MSKrescodee (MSKAPI MSK_appendvars) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKrealt * cval,
	MSKCONST MSKintt * aptrb,
	MSKCONST MSKintt * aptre,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval,
	MSKCONST MSKboundkeye * bkx,
	MSKCONST MSKrealt * blx,
	MSKCONST MSKrealt * bux);

/* MSK_appendcons */
MSKrescodee (MSKAPI MSK_appendcons) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKintt * aptrb,
	MSKCONST MSKintt * aptre,
	MSKCONST MSKidxt * asub,
	MSKCONST MSKrealt * aval,
	MSKCONST MSKboundkeye * bkc,
	MSKCONST MSKrealt * blc,
	MSKCONST MSKrealt * buc);

/* MSK_startstat */
MSKrescodee (MSKAPI MSK_startstat) (
	MSKtask_t task);

/* MSK_stopstat */
MSKrescodee (MSKAPI MSK_stopstat) (
	MSKtask_t task);

/* MSK_appendstat */
MSKrescodee (MSKAPI MSK_appendstat) (
	MSKtask_t task);

/* MSK_core_appendcones */
MSKrescodee (MSKAPI MSK_core_appendcones) (
	MSKtask_t task,
	MSKconetypee conetype,
	MSKrealt conepar,
	MSKintt nummem,
	MSKintt numsub,
	MSKCONST MSKidxt * submem,
	MSKidxt * coneidx);

/* MSK_core_removecones */
MSKrescodee (MSKAPI MSK_core_removecones) (
	MSKtask_t task,
	MSKintt num,
	MSKCONST MSKidxt * subk);

/* MSK_core_append */
MSKrescodee (MSKAPI MSK_core_append) (
	MSKtask_t task,
	MSKaccmodee accmode,
	MSKintt num,
	MSKintt * first);

/* MSK_isinfinity */
MSKbooleant (MSKAPI MSK_isinfinity) (
	MSKrealt value);

/* MSK_checkoutlicense */
MSKrescodee (MSKAPI MSK_checkoutlicense) (
	MSKenv_t env,
	MSKfeaturee feature);

/* MSK_checkinlicense */
MSKrescodee (MSKAPI MSK_checkinlicense) (
	MSKenv_t env,
	MSKfeaturee feature);

/* MSK_getbuildinfo */
MSKrescodee (MSKAPI MSK_getbuildinfo) (
	char * buildstate,
	char * builddate,
	char * buildtool);

/* MSK_getresponseclass */
MSKrescodee (MSKAPI MSK_getresponseclass) (
	MSKrescodee r,
	MSKrescodetypee * rc);

/* MSK_callocenv */
void * (MSKAPI MSK_callocenv) (
	MSKenv_t env,
	MSKCONST size_t number,
	MSKCONST size_t size);

/* MSK_callocdbgenv */
void * (MSKAPI MSK_callocdbgenv) (
	MSKenv_t env,
	MSKCONST size_t number,
	MSKCONST size_t size,
	MSKCONST char * file,
	MSKCONST unsigned line);

/* MSK_deleteenv */
MSKrescodee (MSKAPI MSK_deleteenv) (
	MSKenv_t * env);

/* MSK_echoenv */
MSKrescodee (MSKAPIVA MSK_echoenv) (
	MSKenv_t env,
	MSKstreamtypee whichstream,
	MSKCONST char * format,
	...);

/* MSK_echointro */
MSKrescodee (MSKAPI MSK_echointro) (
	MSKenv_t env,
	MSKintt longver);

/* MSK_freeenv */
void (MSKAPI MSK_freeenv) (
	MSKenv_t env,
	MSKCONST void * buffer);

/* MSK_freedbgenv */
void (MSKAPI MSK_freedbgenv) (
	MSKenv_t env,
	MSKCONST void * buffer,
	MSKCONST char * file,
	MSKCONST unsigned line);

/* MSK_getcodedisc */
MSKrescodee (MSKAPI MSK_getcodedisc) (
	MSKrescodee code,
	char * symname,
	char * str);

/* MSK_getcodedesc */
MSKrescodee (MSKAPI MSK_getcodedesc) (
	MSKrescodee code,
	char * symname,
	char * str);

/* MSK_getsymbcondim */
MSKrescodee (MSKAPI MSK_getsymbcondim) (
	MSKenv_t env,
	MSKintt * num,
	size_t * maxlen);

/* MSK_getversion */
MSKrescodee (MSKAPI MSK_getversion) (
	MSKintt * major,
	MSKintt * minor,
	MSKintt * build,
	MSKintt * revision);

/* MSK_checkversion */
MSKrescodee (MSKAPI MSK_checkversion) (
	MSKenv_t env,
	MSKintt major,
	MSKintt minor,
	MSKintt build,
	MSKintt revision);

/* MSK_iparvaltosymnam */
MSKrescodee (MSKAPI MSK_iparvaltosymnam) (
	MSKenv_t env,
	MSKiparame whichparam,
	MSKintt whichvalue,
	char * symbolicname);

/* MSK_linkfiletoenvstream */
MSKrescodee (MSKAPI MSK_linkfiletoenvstream) (
	MSKenv_t env,
	MSKstreamtypee whichstream,
	MSKCONST char * filename,
	MSKintt append);

/* MSK_linkfunctoenvstream */
MSKrescodee (MSKAPI MSK_linkfunctoenvstream) (
	MSKenv_t env,
	MSKstreamtypee whichstream,
	MSKuserhandle_t handle,
	MSKstreamfunc func);

/* MSK_unlinkfuncfromenvstream */
MSKrescodee (MSKAPI MSK_unlinkfuncfromenvstream) (
	MSKenv_t env,
	MSKstreamtypee whichstream);

/* MSK_makeenv */
MSKrescodee (MSKAPI MSK_makeenv) (
	MSKenv_t * env,
	MSKuserhandle_t usrptr,
	MSKmallocfunc usrmalloc,
	MSKfreefunc usrfree,
	MSKCONST char * dbgfile);

/* MSK_initenv */
MSKrescodee (MSKAPI MSK_initenv) (
	MSKenv_t env);

/* MSK_getglbdllname */
MSKrescodee (MSKAPI MSK_getglbdllname) (
	MSKenv_t env,
	MSKCONST size_t sizedllname,
	char * dllname);

/* MSK_putdllpath */
MSKrescodee (MSKAPI MSK_putdllpath) (
	MSKenv_t env,
	MSKCONST char * dllpath);

/* MSK_putlicensedefaults */
MSKrescodee (MSKAPI MSK_putlicensedefaults) (
	MSKenv_t env,
	MSKCONST char * licensefile,
	MSKCONST MSKintt * licensebuf,
	MSKintt licwait,
	MSKintt licdebug);

/* MSK_putkeepdlls */
MSKrescodee (MSKAPI MSK_putkeepdlls) (
	MSKenv_t env,
	MSKintt keepdlls);

/* MSK_putcpudefaults */
MSKrescodee (MSKAPI MSK_putcpudefaults) (
	MSKenv_t env,
	int cputype,
	MSKintt sizel1,
	MSKintt sizel2);

/* MSK_maketask */
MSKrescodee (MSKAPI MSK_maketask) (
	MSKenv_t env,
	MSKintt maxnumcon,
	MSKintt maxnumvar,
	MSKtask_t * task);

/* MSK_makeemptytask */
MSKrescodee (MSKAPI MSK_makeemptytask) (
	MSKenv_t env,
	MSKtask_t * task);

/* MSK_putexitfunc */
MSKrescodee (MSKAPI MSK_putexitfunc) (
	MSKenv_t env,
	MSKexitfunc exitfunc,
	MSKuserhandle_t handle);

/* MSK_replacefileext */
void (MSKAPI MSK_replacefileext) (
	char * filename,
	MSKCONST char * newextension);

/* MSK_utf8towchar */
MSKrescodee (MSKAPI MSK_utf8towchar) (
	MSKCONST size_t outputlen,
	size_t * len,
	size_t * conv,
	MSKwchart * output,
	MSKCONST char * input);

/* MSK_wchartoutf8 */
MSKrescodee (MSKAPI MSK_wchartoutf8) (
	MSKCONST size_t outputlen,
	size_t * len,
	size_t * conv,
	char * output,
	MSKCONST MSKwchart * input);

/* MSK_checkmemenv */
MSKrescodee (MSKAPI MSK_checkmemenv) (
	MSKenv_t env,
	MSKCONST char * file,
	MSKintt line);

/* MSK_strdupenv */
char * (MSKAPI MSK_strdupenv) (
	MSKenv_t env,
	MSKCONST char * str);

/* MSK_strdupdbgenv */
char * (MSKAPI MSK_strdupdbgenv) (
	MSKenv_t env,
	MSKCONST char * str,
	MSKCONST char * file,
	MSKCONST unsigned line);

/* MSK_symnamtovalue */
MSKbooleant (MSKAPI MSK_symnamtovalue) (
	MSKCONST char * name,
	char * value);



#ifdef __cplusplus
}
#endif


#endif


