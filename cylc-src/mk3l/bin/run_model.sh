ml purge
ml intel/2017a zlib/1.2.11-intel-2017a

ulimit -s unlimited
export KMP_STACKSIZE=10M
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

echo "===== run=$run rundir=$rundir copydir=$copydir ====="

# Set name of logfile
logfile=log.$run

echo "*** 1"

# Change to run directory
cd $rundir

# Set year number - $year may have leading zeroes, whereas $yr will not
year=`cat year`
yr=`expr $year + 0`

echo "*** 2"

# Save temporary copies of restart files
cp -p oflux.nc $copydir
cp -p orest.nc $copydir
cp -p rest.start $copydir

echo "*** 3"

# Initialise log entry for this year
echo "YEAR $year" >> $logfile
echo "----------" >> $logfile
echo "Running on node `hostname`, using $OMP_NUM_THREADS cores..." >> $logfile

# Run model for one year
echo "Running model..." >> $logfile
$model < input > out.$year

echo "*** 4"
 
# check that the run completed successfully
message=$(tail out.$year | grep termination)
if [ $message != "" ]; then
    # normal termination
    exit 0
fi
# error
exit 1

