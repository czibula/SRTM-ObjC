SRTM-ObjC
=========

Objective-C library for reading NASA SRTM elevations files

Usage:

Add project.
Add libSRTM.a dependency
Add $(SRC_ROOT)/SRTM-Objc (recursive) to Header/Include Path

#import "SRTM.h"

    CLLocationDistance elevation = [[SRTM sharedSingleton] elevationForCoordinate:location];

