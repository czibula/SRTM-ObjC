//
//  SRTM.m
//  SRTM
//
//  Created by Tracy Harton on 10/18/12.
//  Copyright (c) 2012 Amphibious Technologies LLC. All rights reserved.
//

#import "SRTM.h"

@implementation SRTM

static SRTM *sharedSingleton = nil;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[SRTM alloc] init];
    }
}

+ (SRTM *)sharedSingleton
{
    return sharedSingleton;
}

const unsigned kMaxCol = 1201;
const unsigned kMaxRow = 1201;

- (uint16_t) elevationFrom:(FILE*)file X:(unsigned)x Y:(unsigned)y
{
    fseek(file, (kMaxCol*y)+x, SEEK_SET);

    uint16_t data;
    fread(&data, sizeof(uint16_t), 1, file);


    data = CFSwapInt16BigToHost(data);
    
    uint16_t elevation;
    memcpy(&elevation, &data, sizeof(int16_t));
    
    return elevation;
}

- (CLLocationDistance) elevationForCoordinate:(CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D lowerLeftCoordinate = CLLocationCoordinate2DMake(floor(coordinate.latitude), floor(coordinate.longitude));
    
    NSString *hgtName = [NSString stringWithFormat:@"%c%02d%c%03d.hgt",
                          (lowerLeftCoordinate.latitude < 0.0) ? 'S' : 'N',
                          (int)abs(lowerLeftCoordinate.latitude),
                          (lowerLeftCoordinate.longitude < 0.0) ? 'W' : 'E',
                          (int)abs(lowerLeftCoordinate.longitude)];
    
    
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSString *hgtPath = [rootPath stringByAppendingPathComponent:hgtName];
                           
    FILE *file = fopen([hgtPath UTF8String], "r");
    
    int16_t elevation = INT16_MIN; // standard for void

    if(file)
    {
        unsigned x = (unsigned)((coordinate.longitude - lowerLeftCoordinate.longitude)*(kMaxCol-1));
        unsigned y = (unsigned)((coordinate.latitude - lowerLeftCoordinate.latitude)*(kMaxRow-1));
        
        elevation = [self elevationFrom:file X:x Y:y];
        fclose(file);
    }
    else
    {
        NSLog(@"ERROR: Cannot load elevation data from %@", hgtPath);
    }
    
    //NSLog(@"elevation: %f,%f -> %d", coordinate.latitude, coordinate.longitude, elevation);
    
    return((CLLocationDistance)elevation);
}

@end
