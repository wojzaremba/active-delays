/*
   Copyright: Copyright (c) 1998-2012 MOSEK ApS, Denmark. All rights reserved.

   File:      msktsp.c

   Purpose:   Demonstrates the difference between weak
              and strong formulations when solving MIP's.
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#include "mosek.h"

#define MAXCUTROUNDS 2
#define MAXADDPERROUND 1000

static void MSKAPI printstr(void *handle, char str[])
{
    printf("MOSEK: %s",str);
} /* printstr */


/* conversion from n x n tsp city matrix indices to array index */
#define IJ(i,j) (n*(i)+(j))

/* mallocs and returns costmatrix, returns number of cities in ncities */
int* readtspfromfile(char* filename, int* ncities)
{
    FILE *tspfile;
    char sbuf[21];
    tspfile = fopen(filename,"r");
    if (!tspfile) return NULL;
    do
    {
        if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
    } while (strncmp(sbuf,"DIMENSION",9) != 0);
    if (1 != fscanf(tspfile,"%d ",ncities)) return NULL;
    do
    {
        if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
    } while (strncmp(sbuf,"EDGE_WEIGHT_TYPE",16) != 0);
    if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
    if (strcmp(sbuf,"EXPLICIT") == 0)
    {
        do
        {
            if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
        } while (strncmp(sbuf,"EDGE_WEIGHT_FORMAT",18) != 0);
        if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
        if (strcmp(sbuf,"FULL_MATRIX") == 0)
        {
            int* cost;
            int ij, n2;
            do
            {
                if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
            } while (strncmp(sbuf,"EDGE_WEIGHT_SECTION",19) != 0);
            n2 = *ncities;
            n2 *= n2;
            cost = (int*) malloc(n2*sizeof(int));
            assert(cost);
            for (ij = 0; ij<n2; ij++)
            {
                if (1 != fscanf(tspfile,"%d ",&cost[ij]))
                {
                    free(cost);
                    return NULL;
                }
            }
            return cost;
        }
        else if (strcmp(sbuf,"LOWER_DIAG_ROW") == 0)
        {
            int* cost;
            int i, j, n;
            do
            {
                if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
            } while (strncmp(sbuf,"EDGE_WEIGHT_SECTION",19) != 0);
            n = *ncities;
            cost = (int*) malloc(n*n*sizeof(int));
            assert(cost);
            for (i=0; i<n; i++) for (j=0; j<=i; j++)
            {
                int c;
                if (1 != fscanf(tspfile,"%d ",&c))
                {
                    free(cost);
                    return NULL;
                }
                cost[IJ(i,j)] = c;
                cost[IJ(j,i)] = c;
            }
            return cost;
        }
        else
        {
            printf("Format not supported\n");
            return NULL;
        }
    }
    else if (strcmp(sbuf,"EUC_2D") == 0)
    {
        int* cost;
        double *xcoord, *ycoord;
        int i, j, n;
        do
        {
            if (1 != fscanf(tspfile,"%20s ",sbuf)) return NULL;
        } while (strncmp(sbuf,"NODE_COORD_SECTION",18) != 0);
        n = *ncities;
        xcoord = (double*) malloc(n*sizeof(double));
        ycoord = (double*) malloc(n*sizeof(double));
        cost = (int*) malloc(n*n*sizeof(int));
        assert(xcoord); assert(ycoord); assert(cost);
        for (i = 0; i<n; i++)
        {
            int dummy;
            if (3 != fscanf(tspfile,"%d %lf %lf ",&dummy,&xcoord[i],&ycoord[i]))
            {
                free(cost);
                return NULL;
            }
        }
        for (i = 0; i<n; i++) for (j=0; j<n; j++)
        {
            double xd = xcoord[i] - xcoord[j];
            double yd = ycoord[i] - ycoord[j];
            cost[IJ(i,j)] = (int) (0.5 + sqrt(xd*xd + yd*yd));
        }
        return cost;
    }
    else
    {
        printf("E_W_Type not supported\n");
        return NULL;
    }
} /* readtspfromfile */

/* add the x_ij variables */
void add_vars(MSKtask_t task, int n)
{
    MSKrescodee r;
    int ij;
    int n2 = n*n;
    r = MSK_append(task,MSK_ACC_VAR,n2); assert(r==MSK_RES_OK);
    for(ij=0; ij<n2; ++ij)
    {
        r = MSK_putbound(task,MSK_ACC_VAR,ij,MSK_BK_RA,0,1);
        assert(r==MSK_RES_OK);
        r = MSK_putvartype(task,ij,MSK_VAR_TYPE_INT); assert(r==MSK_RES_OK);
    }
    for (ij=0; ij<n; ij++)
    {
        r = MSK_putbound(task,MSK_ACC_VAR,IJ(ij,ij),MSK_BK_FX,0,0);
        assert(r==MSK_RES_OK);
    }
} /* add_vars */

/* adds the tsp objective function and frees cost */
void add_objective_function(MSKtask_t task, int n, int* cost)
{
    MSKrescodee r;
    int ij;
    int n2 = n*n;
    r = MSK_putcfix(task,0.0); assert(r==MSK_RES_OK);
    for(ij=0; ij<n2; ++ij)
    {
        r = MSK_putcj(task,ij,cost[ij]); assert(r==MSK_RES_OK);
    }
    free(cost);
} /* add_objective_function */

/* adds the tsp assignment constraints */
void add_assignment_constraints(MSKtask_t task, int n)
{
    MSKrescodee r;
    int i, j;
    double* aval;
    int *asub;
    aval = (double*) malloc(n*sizeof(double)); assert(aval);
    asub = (int*) malloc(n*sizeof(int)); assert(asub);
    for (i=0; i<n; i++) aval[i] = 1;
    r = MSK_append(task,MSK_ACC_CON,n*2); assert(r==MSK_RES_OK);
    /* Constraint 0--(n-1) is \sum_j x_{ij} = 1 */
    for (i=0; i<n; i++)
    {
        r = MSK_putbound(task,MSK_ACC_CON,i,MSK_BK_FX,1,1);
        assert(r==MSK_RES_OK);
        for (j=0; j<n; j++)
            asub[j] = IJ(i,j);
        r = MSK_putavec(task,MSK_ACC_CON,i,n,asub,aval); assert(r==MSK_RES_OK);
    }
    /* Constraint n--(2n-1) is \sum_i x_{ij} = 1 */
    for (j=0; j<n; j++)
    {
        r = MSK_putbound(task,MSK_ACC_CON,j+n,MSK_BK_FX,1,1);
        assert(r==MSK_RES_OK);
        for (i=0; i<n; i++)
            asub[i] = IJ(i,j);
        r = MSK_putavec(task,MSK_ACC_CON,j+n,n,asub,aval);
        assert(r==MSK_RES_OK);
    }
    free(aval);
    free(asub);
} /* add_assignment_constraints */

/* adds the Miller-Tucker-Zemlin arc constraints */
void add_MTZ_arc_constraints(MSKtask_t task, int n)
{
    MSKrescodee r;
    int varidx, conidx, i, j;
    r = MSK_getnumvar(task,&varidx); assert(r==MSK_RES_OK);
    r = MSK_getnumcon(task,&conidx); assert(r==MSK_RES_OK);
    /* add the vars u_k for k=1..(n-1) getting index
     * from varidx to varidx+n-2 */
    r = MSK_append(task,MSK_ACC_VAR,n-1); assert(r==MSK_RES_OK);
    for(i=varidx; i<varidx+n-1; ++i)
    {
        /* set bound: 2 <= u_k <= n, k=1..(n-1) */
        r = MSK_putbound(task,MSK_ACC_VAR,i,MSK_BK_RA,2,n);
        assert(r==MSK_RES_OK);
    }
    /* add the (n-1)^2 constraints:
     * u_i - u_j + 1 <= (n - 1)(1 - x_ij) or equivalently
     * u_i - u_j + (n - 1)x_ij <= n - 2, for i,j != 0 */
    r = MSK_append(task,MSK_ACC_CON,(n-1)*(n-1)); assert(r==MSK_RES_OK);
    for (i=1; i<n; i++) for (j=1; j<n; j++)
    {
        double aval[3];
        int asub[3];
        aval[0] = 1; aval[1] = -1; aval[2] = n-1;
        asub[0] = varidx + i - 1; /* u_i */
        asub[1] = varidx + j - 1; /* u_j */
        asub[2] = IJ(i,j);        /* x_ij */
        r = MSK_putbound(task,MSK_ACC_CON,conidx,MSK_BK_UP,-MSK_INFINITY,n-2);
        assert(r==MSK_RES_OK);
        r = MSK_putavec(task,MSK_ACC_CON,conidx,3,asub,aval);
        assert(r==MSK_RES_OK);
        conidx++;
    }
} /* add_MTZ_arc_constraints */

/* construct the list of cities in the chosen subtours */
int* subtourstolist(MSKtask_t task, int n, int nextnode[],
        int subtour[], int chosen[], int k, int* size)
{
    int ncities, i, j;
    int *cities;
    cities = (int*) malloc(n*sizeof(int));
    assert(cities);
    ncities = 0;
    for (i=0; i<k; i++)
    {
        int subtourstart = subtour[chosen[i]];
        j = subtourstart;
        do
        {
            cities[ncities] = j;
            ncities++;
            j = nextnode[j];
        } while (j != subtourstart);
    }
    *size = ncities;
    return cities;
} /* subtourstolist */

/* adds the subtour constraint given by the list cities S:
 * \sum_{i,j \in S} x_{ij} \leq |S|-1 */
void addcut(MSKtask_t task, int n, int citylist[], int size)
{
    MSKrescodee r;
    int i, j, asubidx, conidx;
    double* aval;
    int *asub;
    int size2 = size*size;
    aval = (double*) malloc(size2*sizeof(double)); assert(aval);
    asub = (int*) malloc(size2*sizeof(int)); assert(asub);
    for (i=0; i<size2; i++) aval[i] = 1;
    r = MSK_getnumcon(task,&conidx); assert(r==MSK_RES_OK);
    r = MSK_append(task,MSK_ACC_CON,1); assert(r==MSK_RES_OK);
    r = MSK_putbound(task,MSK_ACC_CON,conidx,MSK_BK_UP,-MSK_INFINITY,size-1);
    assert(r==MSK_RES_OK);
    asubidx = 0;
    for (i=0; i<size; i++) for (j=0; j<size; j++)
    {
        asub[asubidx] = IJ(citylist[i],citylist[j]);
        asubidx++;
    }
    r = MSK_putavec(task,MSK_ACC_CON,conidx,size2,asub,aval);
    assert(r==MSK_RES_OK);
    free(aval);
    free(asub);
} /* addcut */

/* identifies subtours and adds a number of violated cuts */
void addcuts(MSKtask_t task, int n, int maxcuts, int* nsubtours, int* ncuts)
{
    MSKrescodee r;
    int i, j, k;
    int n2 = n*n;
    double *xx;
    int *nextnode, *visited, *subtour, *chosen;
    int nsubt = 0;
    xx = (double*) malloc(n2*sizeof(double));
    nextnode = (int*) malloc(n*sizeof(int));
    assert(xx);
    assert(nextnode);
    r = MSK_getsolutionslice(task,MSK_SOL_ITG,MSK_SOL_ITEM_XX,0,n2,xx);
    assert(r==MSK_RES_OK);
    /* convert matrix representation of graph (xx) to
     * adjacency(-list) (nextnode) */
    for (i=0; i<n; i++) for (j=0; j<n; j++)
    {
        if (xx[IJ(i,j)]>0.5) /* i.e. x_ij = 1 */
            nextnode[i] = j;
    }
    free(xx); xx = NULL;
    visited = (int*) calloc(n,sizeof(int)); /* visited is initialized to 0 */
    subtour = (int*) malloc(n*sizeof(int));
    assert(visited);
    assert(subtour);
    /* identify subtours; keep count in nsubt, save starting
     * pointers in subtour[0..(nsubt-1)] */
    for (i=0; i<n; i++) if (!visited[i]) /* find an unvisited node;
                                          * this starts a new subtour */
    {
        subtour[nsubt] = i;
        nsubt++;
        j = i;
        do
        {
            assert(!visited[j]);
            visited[j] = 1;
            j = nextnode[j];
        } while (j!=i);
    }
    free(visited); visited = NULL;
    *nsubtours = nsubt;
    *ncuts = 0;
    chosen = (int*) malloc(nsubt*sizeof(int)); /* list of chosen subtours */
    for (k=1; k<=nsubt; k++) /* choose k of nsubt subtours */
    {
        int nchosen = 1;
        chosen[0] = nsubt - 1;
        while (*ncuts < maxcuts)
        {
            if (nchosen == k)
            {
                int *citylist;
                int size;
                citylist = subtourstolist(task,n,nextnode,subtour,
                                            chosen,k,&size);
                if (size <= n/2) /* add only subtour constraints
                                  * of size n/2 or less */
                {
                    addcut(task,n,citylist,size);
                    (*ncuts)++;
                }
                free(citylist);
                j=0;
                while (j<k && chosen[k - 1 - j] == j) j++;
                if (k==j) break; /* all k-size subsets done */
                nchosen = k - j;
                chosen[nchosen - 1]--;
            }
            else /* 0 < nchosen < k */
            {
                chosen[nchosen] = chosen[nchosen - 1] - 1;
                nchosen++;
            }
        }
    }
    free(nextnode);
    free(subtour);
    free(chosen);
} /* addcuts */

int main(int argc, char *argv[])
{
    int            *cost;     /* tsp cost matrix */
    int            n;         /* number of cities */
    MSKenv_t       env;       /* Mosek environment */
    MSKtask_t      task;      /* Mosek task */
    MSKrescodee    r;         /* Mosek return code */
    double         ObjVal;    /* Value of the objective function */
    int            maxrounds; /* number of cutting rounds */
    int            maxcuts;   /* maximum number of cuts added per round */
    int k;
    int nsubtours, ncuts;
    double t;
    double cuttime = 0;

    if (argc < 2)
    {
        printf("Usage: ./tsp filename.tsp [rounds] [maxcuts]\n\n"
               "rounds is the maximum number of cutting rounds (default = %d)\n"
               "maxcuts is the maximum number of cuts added per round "
               "(default = %d)\n",
                MAXCUTROUNDS,MAXADDPERROUND);
        return 1;
    }
    maxrounds = MAXCUTROUNDS;
    if (argc >= 3) maxrounds = atoi(argv[2]);
    maxcuts = MAXADDPERROUND;
    if (argc >= 4) maxcuts = atoi(argv[3]);

    cost = readtspfromfile(argv[1],&n);
    if (!cost)
    {
        printf("Bad tsp file\n");
        return 1;
    }

    r = MSK_makeenv(&env,NULL,NULL,NULL,NULL); assert(r==MSK_RES_OK);
    MSK_linkfunctoenvstream(env,MSK_STREAM_LOG,NULL,printstr);
    r = MSK_initenv(env);                      assert(r==MSK_RES_OK);
    r = MSK_makeemptytask(env,&task);          assert(r==MSK_RES_OK);
    MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

    add_vars(task,n);
    add_objective_function(task,n,cost);
    add_assignment_constraints(task,n);

    nsubtours = 2;
    for (k=0; k<maxrounds; k++)
    {
        r = MSK_optimize(task);                         assert(r==MSK_RES_OK);
        r = MSK_getprimalobj(task,MSK_SOL_ITG,&ObjVal); assert(r==MSK_RES_OK);
        MSK_getdouinf(task,MSK_DINF_OPTIMIZER_TIME,&t);
        cuttime += t;
        addcuts(task,n,maxcuts,&nsubtours,&ncuts);
        printf("\n"
               "Round: %d\n"
               "ObjValue: %e\n"
               "Number of subtours: %d\n"
               "Number of cuts added: %d\n\n",k+1,ObjVal,nsubtours,ncuts);
        if (nsubtours == 1) break; /* problem solved! */
    }

    t = 0;
    if (nsubtours > 1)
    {
        printf("Adding MTZ arc constraints\n\n");
        add_MTZ_arc_constraints(task,n);
        r = MSK_optimize(task);                         assert(r==MSK_RES_OK);
        r = MSK_getprimalobj(task,MSK_SOL_ITG,&ObjVal); assert(r==MSK_RES_OK);
        MSK_getdouinf(task,MSK_DINF_OPTIMIZER_TIME,&t);
    }

    printf("\n"
           "Done solving.\n"
           "Time spent cutting: %.2f\n"
           "Total time spent: %.2f\n"
           "ObjValue: %e\n",cuttime,cuttime+t,ObjVal);

    MSK_deletetask(&task);
    MSK_deleteenv(&env);
    return 0;
} /* main */

