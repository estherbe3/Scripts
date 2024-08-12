#!/bin/bash

#running a transition run at Iskoras
# $1 name of the current case
# $2 Name of the Case, of the Accelerated spinup run
# $3 Date of the last restore  file of the accelerated spinnup run

cd ~/CTSM_ExcessIce/cime/scripts


echo  "create case" $1 $2 $3


./create_newcase --machine fram --case ~/cases/$1 --res CLM_USRDAT  --compset 1850_DATM%GSWP3v1_CLM50%BGC_SICE_SOCN_SROF_SGLC_SWAV \
--run-unsupported --user-mods-dirs /cluster/projects/nn2806k/estherbe/Input_Data/1x1Iskoras --project nn2806k \
 --compiler intel --handle-preexisting-dirs r --walltime 01:00:00  -q normal  
#--queue devel


cd ~/cases/$1

cp /cluster/projects/nn2806k/estherbe/Input_Data/1x1Iskoras/user_mods/user_nl_datm_streams ~/cases/$1

./case.setup

cp /cluster/work/users/estherbe/archive/$2/rest/$3/$2.clm2.h0.$3.nc /cluster/work/users/estherbe/noresm/$1/run
cp /cluster/work/users/estherbe/archive/$2/rest/$3/$2.clm2.r.$3.nc /cluster/work/users/estherbe/noresm/$1/run
cp /cluster/work/users/estherbe/archive/$2/rest/$3/$2.clm2.rh0.$3.nc /cluster/work/users/estherbe/noresm/$1/run



#change long and lat parameters 
#for samalovy

./xmlchange STOP_N=25
./xmlchange STOP_OPTION=nyears
./xmlchange PTS_LON=24.250
./xmlchange PTS_LAT=69.383  
./xmlchange RESUBMIT=3
./xmlchange NTASKS=10
./xmlchange RUN_TYPE=startup
./xmlchange JOB_WALLCLOCK_TIME="04:00:00"
./xmlchange PROJECT=nn2806k
./xmlchange RUN_STARTDATE="1901-01-01"
./xmlchange DATM_YR_ALIGN="1901"
./xmlchange DATM_YR_START="1901"
./xmlchange DATM_YR_END="1910"
./xmlchange CLM_ACCELERATED_SPINUP="off"
#./xmlchange CLM_FORCE_COLDSTART="off"
./xmlchange CLM_USRDAT_DIR=/cluster/projects/nn2806k/estherbe/Input_Data/1x1Iskoras
./xmlchange CLM_USRDAT_NAME=1x1Iskoras
./xmlchange DEBUG=FALSE
./xmlchange LND_DOMAIN_PATH=/cluster/projects/nn2806k/estherbe/Data_new/1x1Iskoras
./xmlchange LND_DOMAIN_FILE="domain.lnd.fv0.9x1.25_gx1v7_Iskoras_c240325.nc"
./xmlchange DIN_LOC_ROOT_CLMFORC=/cluster/projects/nn2806k/estherbe/Input_data/1x1Iskoras


cat > user_nl_clm << EOF
use_excess_ice = .true.
use_excess_ice_tiles = .true.
use_excess_ice_streams = .true.
use_tiles_snow=.true.
use_tiles_lateral_water=.true.
excess_ice_split_factor=0.9
soil_layerstruct_predefined = '49SL_10m'
use_tiles_lateral_heat=.true.
fsurdat =  '/cluster/home/estherbe/Input_data/Iskoras_geo_ORG_neu_cdf5.nc'
stream_meshfile_exice = '/cluster/shared/noresm/inputdata/lnd/clm2/paramdata/exice_init_0.125x0.125_ESMFmesh_cdf5_c20220802.nc'
paramfile = '/cluster/projects/nn2806k/estherbe/ParaFiles/clm50_params_kac04_Slopem08_cdf5.nc'
finidat="$2.clm2.r.$3.nc"
hist_dov2xy=.false.
hist_nhtfrq=-0
hist_mfilt=12
hist_fincl1="H2OSOI", "TSOI", "SOILICE", "EXCESS_ICE", "SUBSIDENCE", "QDRAI_PERCH","FROST_TABLE","ZWT_PERCH", \
 "ZWT",  "H2OSNO", "SNOWDP", "SNOW_5D", "SNOW_ICE", "H2OSFC", "QFLX_LIQ_GRND", "QFLX_SNOW_GRND", "QFLX_EVAP_VEG",\
 "QSOIL", "QOVER", "QRGWL", "QSNWCPICE", "FH2OSFC_NOSNOW", "CONC_CH4_SAT", "CONC_CH4_UNSAT",\
  "TSOI_10CM",  "TG", "QDRAI", "QDRAI_XS", "QICE", "QICE_MELT", "TBOT","TH2OSFC","THBOT","TOTEXICE_VOL",\
"TOTSOILICE","TOTSOILLIQ", "SNOW_DEPTH", "SNOW", "SNOWLIQ", "FSAT", "QH2OSFC", "QOVER", \
 "SOILLIQ" , "TWS", "H2OSFC","FGEV" ,"FH2OSFC_NOSNOW", "QFLX_LIQ_GRND", "QFLX_SNOW_GRND", "QFLX_EVAP_VEG",\
 "QSOIL", "QOVER", "QRGWL", "QSNWCPICE", "SNOWLIQ", "FSNO", "FSNO_EFF", "FH2OSFC",  "FSAT", "H2OSFC", \
"QH2OSFC", "EXCESS_ICE", "TSA","SUBSACC","RAIN", "SNOW","QFLOOD","QIRRIG_FROM_SURFACE",'RAIN_FROM_ATM',\
 "QFLX_EVAP_TOT", "NEE", "NEP", "NPP", "GPP", "TWS", "TLAI", "TOTCOLC", "TOTECOSYSC", "TOTSOMC", "TOTVEGC",\
"TOTCOLCH4", "CH4PROD", "CH4_SURF_DIFF_SAT", "CH4_SURF_DIFF_UNSAT", "CONC_CH4_SAT", "CONC_CH4_SAT", "CONC_CH4_UNSAT",\
"FCH4TOCO2", "PCH4", "PCO2", "ZWT_CH4_UNSAT"
EOF






./case.setup --reset
./case.setup

echo "BUILDING CASE"

./case.build

./preview_namelists

./xmlchange CLM_FORCE_COLDSTART="off"


./case.submit
