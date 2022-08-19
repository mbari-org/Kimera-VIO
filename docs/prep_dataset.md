# Preparing a dataset for Kimera-VIO

This document outlines the steps required to prepare a dataset for Kimera-VIO. These are specific to the MBARI fork: [mbari-org/Kimera-VIO](https://github.com/mbari-org/Kimera-VIO).

These steps assume stereo camera + IMU setup; mono camera + IMU can be used as well by omitting the `cam1`-related data.

There are two primary data products needed by Kimera-VIO:
1. A EuRoC-formatted __dataset__
2. The corresponding set of __parameters__

## Dataset

At a minimum, the provided Kimera-VIO "data provider" expects a directory with the following structure:

```
dataset_name/
    mav0/
        cam0/
            data/
                image_1.png
                image_2.png
                ...
            data.csv
        cam1/
            ...  # same as cam0
        imu0/
            data.csv
        state_groundtruth_estimate0/
            data.csv
            sensor.yaml
```

Though a `sensor.yaml` definition for intrinsics and extrinsics (for `cam0`, `cam1`, and `imu0`) is normally provided alonside the data, Kimera-VIO does not use these. Instead, intrinsics and extrinsics are read from the __parameters__ files, see next section.

### `cam0` and `cam1`

The `cam0` and `cam1` directories must contain a `data` directory containing the images and a `data.csv` file with the corresponding timestamp (in nanoseconds) to filename mapping. For example, `data.csv` might look like:

```csv
#timestamp [ns],filename
1658795922109211000,image_1.png
1658795923709211000,image_2.png
...
```

### `imu0`

The `imu0` directory must contain a `data.csv` file with the following values, in order:
1. timestamp (in nanoseconds)
2. angular velocity in x (rad/s)
3. angular velocity in y (rad/s)
4. angular velocity in z (rad/s)
5. linear acceleration in x (m/s^2)
6. linear acceleration in y (m/s^2)
7. linear acceleration in z (m/s^2)

For example, `data.csv` might look like:

```csv
#timestamp [ns],w_RS_S_x [rad s^-1],w_RS_S_y [rad s^-1],w_RS_S_z [rad s^-1],a_RS_S_x [m s^-2],a_RS_S_y [m s^-2],a_RS_S_z [m s^-2]
1658795920709000192,0.0004940138314850628,-7.207201269920915e-05,-0.0002978252596221864,-0.2648468613624573,-0.12753811478614807,-9.802435874938965
1658795920808999936,0.0008812274900265038,-0.00013994742766954005,-0.00028165793628431857,-0.2649853229522705,-0.12829948961734772,-9.802414894104004
1658795920908999936,0.0011960502015426755,-0.00020373320148792118,-0.0002691674162633717,-0.2651831805706024,-0.12931610643863678,-9.802389144897461
```

### `state_groundtruth_estimate0`

The MBARI fork skips parsing the `state_groundtruth_estimate0` directory, but the included files must be present. The `state_groundtruth_estimate0/data.csv` may be empty, but the `state_groundtruth_estimate0/sensor.yaml` must include at least:
```yaml
%YAML:1.0
```

## Parameters

The parameters directory (can have any name/location) must contain the following files:

1. `PipelineParams.yaml`: Selects which frontend, backend, and display type to use. Enables/disables parallelization.
2. `FrontendParams.yaml`: Parameters for the VIO frontend.
3. `BackendParams.yaml`: Parameters for the VIO backend.
4. `DisplayParams.yaml`: Parameters for the visualization. Enables/disables holding of the 2D and 3D displays between updates.
5. `LcdParams.yaml`: Parameters for loop closure detection.
6. `ImuParams.yaml`: Extrinsic parameters and noise model parameters for the IMU. Selects IMU preintegration type.
7. `LeftCameraParams.yaml`: Intrinsic and extrinsic parameters for the left camera.
8. `RightCameraParams.yaml`: Intrinsic and extrinsic parameters for the right camera.

Out of all of these, the dataset-specific parameters are represented by `ImuParams.yaml`, `LeftCameraParams.yaml`, and `RightCameraParams.yaml`.

### `ImuParams.yaml`

The IMU must have identity pose w.r.t. the body frame; i.e., the `ImuParams.yaml` file must include the following:
```yaml
T_BS:
  cols: 4
  rows: 4
  data: [1.0, 0.0, 0.0, 0.0, 
         0.0, 1.0, 0.0, 0.0, 
         0.0, 0.0, 1.0, 0.0, 
         0.0, 0.0, 0.0, 1.0]
```

Set the rate in Hz, e.g.:

```yaml
rate_hz: 10
```

### `LeftCameraParams.yaml` / `RightCameraParams.yaml`

The left and right camera extrinsics must be specified, e.g.:

```yaml
T_BS:
  cols: 4
  rows: 4
  data: [3.316125576970338e-07, -6.12323399573643e-17, 0.999999999999945, 0, 
         0.999999999999945, 2.0305412867036972e-23, -3.316125576970338e-07, -0.1, 
         0.0, 1.0, 6.123233995736766e-17, 0.05, 
         0.0, 0.0, 0.0, 1.0]
```

Then, specify the intrinsics, e.g.
```yaml
rate_hz: 0.333
resolution: [1920, 1080]
camera_model: pinhole
intrinsics: [1.14408345e+03, 1.14408345e+03, 9.60000000e+02, 5.40000000e+02] #fu, fv, cu, cv
distortion_model: radial-tangential
distortion_coefficients: [0, 0, 0, 0]
```

## Running the pipeline

To point the Kimera-VIO executable to the appropriate directories, the `--dataset_path` and `--params_folder_path` flags must be set, e.g.:

```bash
./stereoVIOEuroc \
    --dataset_path=/path/to/dataset_name \
    --params_folder_path=/path/to/params_folder_name
```

For an example usage of additional flags, see the `scripts/stereoVIOEuroc.bash` script.
