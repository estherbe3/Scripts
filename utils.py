import xarray as xr
import numpy as np
from glob import glob



def trans_z(ds,varname,col,depth,timevar):
    
    exice=np.squeeze(ds['EXCESS_ICE'].values[:,:,col])  
    var=np.squeeze(ds[varname].values[:,:,col])
    zsoi=np.squeeze(ds['ZSOI'].values[:,:,col])[0,:]
    zd=np.where(zsoi<=depth)[0][-1]

    exice_full=exice
    exice=exice[:,:zd]

    zsoi=zsoi[:zd]
    var=var[:,:zd]


    # make zsoi 2D repeating every timeslice
    zsoi=np.expand_dims(zsoi,0)
    
    
    ex_dz=zsoi+exice/917
    subs=np.sum(exice_full[0,:]/917-exice_full/917,axis=1) #surface subcidence
    
    z=ex_dz+ np.repeat(np.expand_dims(subs,axis=1),zd,axis=1) # move the whole coordinate down according to surface elev

    ti=ds[timevar].data # get time variable

    ti=np.expand_dims(ti,1)
    t2=np.repeat(ti,zd,axis=1)
    return t2, z, var

def subset_vars(hist_dir,out_file,vars=None):
    if vars is None:
        vars=['EXCESS_ICE','DZSOI','ZSOI','TSOI','SUBSIDENCE','SUBSACC', 'WATSAT', 'SNOW_DEPTH', 'FCH4','TBOT']
    flpth=glob(hist_dir + '/*h0.*.nc')
    ds = xr.open_mfdataset(flpth,decode_times=True)
    varlist=list(ds.variables.keys())
    for var in vars:
        if var not in varlist:
            print("Variable " + var + "is not on dataset, skipping")
            vars.remove(var)
            
    ds_out=ds[vars]
    ds_out.to_netcdf(path=out_file,mode='a',format='NETCDF4',compute=True)


# this one makes ticks with srf at surface, but I would not recommend it.
def make_yticks(ylim,z_srf,space):
    yticks=np.concatenate((np.append(np.arange(ylim[0],z_srf,-space),z_srf),np.arange(np.ceil(z_srf/space)*space,ylim[1],-space)))
    i_ticks=np.where((abs(yticks-z_srf)>space/3) | (yticks==z_srf))[0]
    yticks=yticks[i_ticks]
    ytick_lbl=[str(x) for x in yticks]
    ytick_lbl[np.where(yticks == z_srf)[0][0]]='srf'
    return yticks, ytick_lbl
