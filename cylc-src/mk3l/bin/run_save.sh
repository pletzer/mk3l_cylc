cd $rundir

year=`cat year`
yr=`expr $year + 0`

# Archive daily output of model every year
for month in 01 02 03 04 05 06 07 08 09 10 11 12; do
  gzip hist${year}${month}.${run}.nc
  chmod 444 hist${year}${month}.${run}.nc.gz
done
tar cf hist.${run}.${year}.tar hist${year}??.${run}.nc.gz
chmod 444 hist.${run}.${year}.tar
mv hist.${run}.${year}.tar $tmpdir
cd $tmpdir
mv hist.${run}.${year}.tar $histdir
cd $rundir
chmod 600 hist${year}??.${run}.nc.gz
rm hist${year}??.${run}.nc.gz

# Save restart files every REST_INTERVAL years
if [ `expr $yr % $REST_INTERVAL` -eq 0 ]; then
  cp -p oflux.nc oflux.nc_${run}_$year
  cp -p orest.nc orest.nc_${run}_$year
  cp -p rest.end rest.start_${run}_$year
  chmod 444 oflux.nc_${run}_$year orest.nc_${run}_$year rest.start_${run}_$year
  gzip oflux.nc_${run}_$year orest.nc_${run}_$year rest.start_${run}_$year
  mv oflux.nc_${run}_${year}.gz orest.nc_${run}_${year}.gz \
          rest.start_${run}_${year}.gz $tmpdir
fi

# Rename output atmosphere model restart file as new input restart file
mv rest.end rest.start

# Save standard output of model
gzip out.$year
chmod 444 out.${year}.gz
mv out.${year}.gz $tmpdir

# Convert ocean model output to netCDF
./convert_averages fort.40 com.${run}.${year}.nc
rm fort.40

# Save output of ocean model
chmod 444 com.${run}.${year}.nc
mv com.${run}.${year}.nc $tmpdir

# Every SAVE_INTERVAL years, calculate annual means of ocean model output and
# then archive all model output
if [ `expr $yr % $SAVE_INTERVAL` -eq 0 ]; then
  yr2=$year
  year1=`expr $yr - $SAVE_INTERVAL + 1`
  yr1=`printf "%05d" $year1`

  # Compress and tar atmosphere model output, and then archive it
  gzip s*${run}.nc
  chmod 444 s*${run}.nc.gz
  tar cf netcdf.${run}.${yr1}-${yr2}.tar s*${run}.nc.gz
  mv netcdf.${run}.${yr1}-${yr2}.tar $tmpdir
  chmod 600 s*${run}.nc.gz
  rm s*${run}.nc.gz
  cd $tmpdir
  chmod 444 netcdf.${run}.${yr1}-${yr2}.tar
  mv netcdf.${run}.${yr1}-${yr2}.tar $atdir

  # Calculate annual means of ocean model output, compress them and then
  # archive them
  ./annual_averages $run $yr1 $yr2
  chmod 444 com.ann.${run}.${yr1}-${yr2}.nc
  gzip com.ann.${run}.${yr1}-${yr2}.nc
  mv com.ann.${run}.${yr1}-${yr2}.nc.gz $comdir

  # Compress and tar ocean model output, and then archive it
  chmod 444 com.${run}.?????.nc
  gzip com.${run}.?????.nc
  comtar=com.${run}.${yr1}-${yr2}.tar
  tar cf $comtar com.${run}.?????.nc.gz
  chmod 444 $comtar
  mv com.$run $comtar $comdir
  chmod 600 com.${run}.?????.nc.gz
  rm com.${run}.?????.nc.gz

  # Tar restart files, and then archive them
  tar cf restart.${run}.${yr2}.tar oflux.nc_${run}_?????.gz \
         orest.nc_${run}_?????.gz rest.start_${run}_?????.gz
  chmod 444 restart.${run}.${yr2}.tar
  mv restart.${run}.${yr2}.tar $restdir
  chmod 600 oflux.nc_${run}_?????.gz orest.nc_${run}_?????.gz \
            rest.start_${run}_?????.gz
  rm oflux.nc_${run}_?????.gz orest.nc_${run}_?????.gz \
          rest.start_${run}_?????.gz

  # Tar standard output of model, and then archive it
  tar cf out.${run}.${yr1}-${yr2}.tar out.?????.gz
  chmod 444 out.${run}.${yr1}-${yr2}.tar
  mv out.${run}.${yr1}-${yr2}.tar $outdir
  chmod 600 out.?????.gz
  rm out.?????.gz

  # Change back to run directory
  cd $rundir

fi

# Finalise log entry for this year
echo "" >> $logfile

# Increment year number
yrnext=`expr $year + 1`
yrp1=$yrnext
yrp1=`printf "%05d" $yrnext`
rm year
echo $yrp1 > year

